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

public struct SpeakerAnnotationGroup {
    var rows: [AvRecordRow]
    var index: Int
    var id: String = ""
    var speakerName: String = ""
    var speakerInitials: String = ""
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
    
    func updateContext(context: NSManagedObjectContext) {
        self.viewContext = context
        loadSortedRows()
    }
    
    
    
    let userPrompt = """
    A speech-to-text transcript is provided formatted as `[Speaker]: Spoken text...`.
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
    
    private func generateQuery(record: AvRecord, useGpt4: Bool) -> ChatQuery {
        let userQuery = userPrompt + "Transcription:\n" + getTranscriptionText(record: record);
        let query = ChatQuery(model: useGpt4 ? .gpt4 : .gpt3_5Turbo, messages:
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
        for group in speakerGroups() {
            transcription += "[\(group.speakerName)]: "
            for row in group.rows {
                if let rowText = row.text {
                    transcription += rowText + "\n"
                }
            }
            transcription += "\n\n"
        }
        
        print("Got transcription:", transcription)
        return transcription
    }
    
    private func getDefaultSpeakerLetter(index: Int) -> String {
        let alphabet = "abcdefghijklmnopqrstuvwxyz"
        let char = alphabet[index % alphabet.count]
        return char.uppercased()
    }
    
    private func getDefaultSpeakerName(index: Int) -> String {
        return "Speaker \(getDefaultSpeakerLetter(index: index))"
    }
    
    func speakerGroups() -> [SpeakerAnnotationGroup] {
        // Enumerate Groups
        var groups: [SpeakerAnnotationGroup] = []
        var group = SpeakerAnnotationGroup(rows: [], index: 0, id: "g-init")
        
        sortedRows.forEach { item in
            if item.turn {
                groups.append(group)
                group = SpeakerAnnotationGroup(rows: [item], index: groups.count + 1, id: "g-\(item.id)")
            } else {
                group.rows.append(item)
            }
        }
        if group.rows.count > 0 {
            groups.append(group)
        }
        
        // Compute Group names
        for (index, group) in groups.enumerated() {
            if let name = group.rows.first?.speaker?.name {
                groups[index].speakerName = name
                groups[index].speakerInitials = name.first.map { String($0) } ?? ""
                
            } else {
                groups[index].speakerName = getDefaultSpeakerName(index: index)
                groups[index].speakerInitials = getDefaultSpeakerLetter(index: index)
            }
        }
        
        return groups
    }
    
    func summarize(context: NSManagedObjectContext, record: AvRecord, apiKey: String, useGpt4: Bool) async {
        
        let regulator = Task.throttle(dueTime: .milliseconds(200)) { (value: UpdateMessage) in
            self.updateSubject.send(value)
        } as! Throttler<UpdateMessage>
        
        // Make sure the rows are up to date
        updateContextAndRecord(context: context, record: record)
        let openAI = OpenAI(apiToken: apiKey)
        let query = generateQuery(record: record, useGpt4: useGpt4)
        
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
                break
            case "Sentiment":
                memorySummary.sentiment = content.joined(separator: " ")
                break
            case "Summary":
                memorySummary.summary = content.joined(separator: " ")
                break
            case "Action Items":
                memorySummary.actionItems = content
                break
            case "Follow Up":
                memorySummary.followUp = content
                break
            case "Arguments":
                memorySummary.arguments = content
                break
            case "Related Topics":
                memorySummary.relatedTopics = content
                break
            case "Main Points":
                memorySummary.mainPoints = content
                break
            case "Stories":
                memorySummary.stories = content
                break
            default:
                break // Ignore headings that don't match any field
            }
        }

        return memorySummary
    }
    
    
    private func parseMarkdown(source: String) -> MemorySummaryStruct {
        let document = Document(parsing: source)
//        print(document.debugDescription())
        var headingBulletsExtractor = HeadingBulletsExtractor()
        headingBulletsExtractor.visit(document)
        headingBulletsExtractor.finalizeExtractedHeadings()
//        print("Extracted headings:", headingBulletsExtractor.extractedHeadings)

        let result = populateMemorySummary(from: headingBulletsExtractor.extractedHeadings)
//        print("Extracted MemorySummaryStruct:", result)
        return result
    }
    
    func createSection<T>(from set: Set<T>?, title: String, imageName: String, textSelector: @escaping (T) -> String, sortKey: KeyPath<T, Int32>) -> AnyView {
        if let itemSet = set {
            let sortedItems = itemSet.sorted { first, second in
                first[keyPath: sortKey] < second[keyPath: sortKey]
            }.map(textSelector)
            
            return AnyView(
                Section(header: summarySectionHeader(title: title, imageName: imageName)) {
                    BulletedListView(from: sortedItems)
                }
            )
        } else {
            return AnyView(EmptyView())
        }
    }
    
    public func getSections() -> some View {
        return Group {
            if let mySet = record?.memorySummary?.mainPoints as? Set<MemoryMainPoint> {
                createSection(
                    from: mySet,
                    title: "Main Points",
                    imageName: "hand.point.right",
                    textSelector: { $0.text ?? "" },
                    sortKey: \.delta
                )
            }

            if let actionItemsSet = record?.memorySummary?.actionItems as? Set<MemoryActionItem> {
                createSection(
                    from: actionItemsSet,
                    title: "Action Items",
                    imageName: "bolt",
                    textSelector: { $0.text ?? "" },
                    sortKey: \.delta
                )
            }

            if let followUpSet = record?.memorySummary?.followUp as? Set<MemoryFollowUp> {
                createSection(
                    from: followUpSet,
                    title: "Follow Up",
                    imageName: "mail",
                    textSelector: { $0.text ?? "" },
                    sortKey: \.delta
                )
            }

            if let argumentsSet = record?.memorySummary?.arguments as? Set<MemoryArgument> {
                createSection(
                    from: argumentsSet,
                    title: "Arguments",
                    imageName: "bolt",
                    textSelector: { $0.text ?? "" },
                    sortKey: \.delta
                )
            }

            if let topicsSet = record?.memorySummary?.topics as? Set<MemoryTopic> {
                createSection(
                    from: topicsSet,
                    title: "Related Topics",
                    imageName: "tag",
                    textSelector: { $0.text ?? "" },
                    sortKey: \.delta
                )
            }

            if let storiesSet = record?.memorySummary?.stories as? Set<MemoryStory> {
                createSection(
                    from: storiesSet,
                    title: "Stories",
                    imageName: "tag",
                    textSelector: { $0.text ?? "" },
                    sortKey: \.delta
                )
            }
        }
    }
    
}
