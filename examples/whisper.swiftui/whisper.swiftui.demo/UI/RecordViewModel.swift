//
//  RecordViewModel.swift
//  attentional.swiftui
//
//  Created by Ryan Rapp on 1/2/24.
//
import SwiftUI
import CoreData
import OpenAI
import Combine
import Regulate
import Markdown


public enum MessageType {
    case NewMessage
    case ProgressMessage
    case CompleteMessage
}

public struct MemorySummaryStruct {
    var title: String? = nil
    var sentiment: String? = nil
    var summary: String? = nil
    var actionItems: [String] = []
    var followUp: [String] = []
    var arguments: [String] = []
    var relatedTopics: [String] = []
    var mainPoints: [String] = []
    var stories: [String] = []
}

public struct UpdateMemorySummary {
    var messageType: MessageType = MessageType.NewMessage
    var memorySummary: MemorySummaryStruct?
    var body: String = ""
}

private struct UpdateMessage {
    var messageType: MessageType = MessageType.NewMessage
    var body: String = ""
}

class RecordViewModel: ObservableObject {
    @Published var sortedRows: [AvRecordRow] = []
    @Published var durationInMinutes: Float = 0
    @Published var summaryCallback: ((UpdateMemorySummary) -> Void)?
    
    private let updateSubject = PassthroughSubject<UpdateMessage, Never>()
    
    private var cancellables = Set<AnyCancellable>()

    private var record: AvRecord?
    private var viewContext: NSManagedObjectContext?

    init(record: AvRecord? = nil, context: NSManagedObjectContext? = nil) {
        self.record = record
        self.viewContext = context
        loadSortedRows()
        
        // Subscribe to the subject on the main thread
        updateSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                // Handle the received value
                self?.handleUpdate(value)
            }
            .store(in: &cancellables)

    }
    
    private func handleUpdate(_ value: UpdateMessage) {
        // TODO: Add the parsed summary
        let memorySummary = parseMarkdown(source: value.body)
        let message = UpdateMemorySummary(messageType: value.messageType, memorySummary: memorySummary, body: value.body)
        summaryCallback?(message)
    }

    private func loadSortedRows() {
        guard let viewContext = viewContext, let record = record else { return }

        let fetchRequest: NSFetchRequest<AvRecordRow> = AvRecordRow.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "t0", ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "parent == %@", record)

        do {
            sortedRows = try viewContext.fetch(fetchRequest)
        } catch {
            print("Error fetching sorted AvRecordRows: \(error)")
        }
        var transcriptionDuration = 0
        for row in sortedRows {
            transcriptionDuration = max(Int(row.t1), transcriptionDuration)
        }
        durationInMinutes = Float(transcriptionDuration) / Float(60 * 100);
    }

    func updateContextAndRecord(context: NSManagedObjectContext, record: AvRecord) {
        self.viewContext = context
        self.record = record
        loadSortedRows()
    }
    
    let userPrompt = """
    Analyze the transcript provided below, then provide the following:
    "Title" - title for the meeting
    "Summary" - summary of meeting
    "Sentiment" - sentiment analysis
    "Action Items" - list of action items. Limit each item to 100 words, and limit the list to 5 items.
    "Follow Up" - list of follow-up questions. Limit each item to 100 words, and limit the list to 5 items.
    "Arguments" - list of potential arguments against the transcript. Limit each item to 100 words, and limit the list to 5 items.
    "Main Points" - list of the main points. Limit each item to 100 words, and limit the list to 10 items.
    "Stories" - list of an stories, examples, or cited works found in the transcript. Limit each item to 200 words, and limit the list to 5 items.
    "Related Topics" - list of topics related to the transcript. Limit each item to 100 words, and limit the list to 5 items.
    """
    
    let systemPrompt = """
    You are an assistant that only speaks Markdown. Use exact header names prefixed with "##" and do not add colons. Do not use backticks.
    Example formatting:

    ## Title
    Title for the meeting

    ## Summary
    Transcript summary

    ## Sentiment
    positive

    ## Action Items
    - item 1
    - item 2
    - item 3

    ## Follow Up
    - item 1
    - item 2
    - item 3

    ## Arguments
    - item 1
    - item 2
    - item 3

    ## Main Points
    - item 1
    - item 2
    - item 3

    ## Stories
    - item 1
    - item 2
    - item 3

    ## Related Topics
    - item 1
    - item 2
    - item 3
    """
    
    private func generateQuery(record: AvRecord) -> ChatQuery {
        let userQuery = userPrompt + "Transcription:\n" + getTranscriptionText(record: record);
        let query = ChatQuery(model: .gpt3_5Turbo, messages:
            [
                .init(role: .user, content: userQuery),
                .init(role: .system, content: systemPrompt)
            ]
        );
        print("Generated query:", query)
        return query
    }
    
    private func getTranscriptionText(record: AvRecord) -> String {
        var transcription = ""
        if let existingRows = record.rows as? Set<AvRecordRow> {
            for row in existingRows {
                if let rowText = row.text {
                    transcription += rowText + "\n\n"
                }
            }
        }
        print("Got transcription:", transcription)
        return transcription
    }
    
    func summarize(context: NSManagedObjectContext, record: AvRecord, apiKey: String, useGpt4: Bool) async {
        
        let regulator = Task.throttle(dueTime: .milliseconds(200)) { (value: UpdateMessage) in
            self.updateSubject.send(value)
        } as! Throttler<UpdateMessage>
        
        // Make sure the rows are up to date
        updateContextAndRecord(context: context, record: record)
        let openAI = OpenAI(apiToken: apiKey)
        let query = generateQuery(record: record)
        
        var summary: String = ""
        self.updateSubject.send(UpdateMessage(messageType: MessageType.NewMessage, body: summary))
        do {
            for try await result in openAI.chatsStream(query: query) {
                if let choice = result.choices.first, let content = choice.delta.content {
                    summary += content;
                    // Push incrementals via a regulator to avoid overwhelming the UI
                    regulator.push(UpdateMessage(messageType: MessageType.ProgressMessage, body: summary))
                }
            }
        } catch {
            let nserror = error as NSError
            print("Unresolved OpenAI error \(nserror), \(nserror.userInfo)")
        }
        self.updateSubject.send(UpdateMessage(messageType: MessageType.CompleteMessage, body: summary))
        print("Received final summary", summary)
    }
    
    private func populateMemorySummary(from extractedData: [String: [String]]) -> MemorySummaryStruct {
        var memorySummary = MemorySummaryStruct()

        for (heading, content) in extractedData {
            switch heading {
            case "Title":
                memorySummary.title = content.joined(separator: " ")
            case "Sentiment":
                memorySummary.sentiment = content.joined(separator: " ")
            case "Summary":
                memorySummary.summary = content.joined(separator: " ")
            case "Action Items":
                memorySummary.actionItems = content
            case "Follow Up":
                memorySummary.followUp = content
            case "Arguments":
                memorySummary.arguments = content
            case "Related Topics":
                memorySummary.relatedTopics = content
            case "Main Points":
                memorySummary.mainPoints = content
            case "Stories":
                memorySummary.stories = content
            default:
                break // Ignore headings that don't match any field
            }
        }

        return memorySummary
    }
    
    
    private func parseMarkdown(source: String) -> MemorySummaryStruct {
        let document = Document(parsing: source)
        print(document.debugDescription())
        var headingBulletsExtractor = HeadingBulletsExtractor()
        headingBulletsExtractor.visit(document)
        headingBulletsExtractor.finalizeExtractedHeadings()
        print("Extracted headings:", headingBulletsExtractor.extractedHeadings)

        let result = populateMemorySummary(from: headingBulletsExtractor.extractedHeadings)
        print("Extracted MemorySummaryStruct:", result)
        return result
    }
}
