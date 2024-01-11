//
//  EditAvRecordView.swift
//  attentional.swiftui
//
//  Created by Ryan Rapp on 1/1/24.
//

import SwiftUI
import CoreData
import TailwindCSS_SwiftUI
import Combine
import UIKit

struct EditAvRecordView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var record: AvRecord
    @ObservedObject var whisperState = WhisperState.shared
    @StateObject var recordHandler = ActionHandler()
    @StateObject private var viewModel = RecordViewModel()
    @StateObject private var peopleViewModel = PeopleViewModel()
    
    @AppStorage("apiKey") var apiKey: String = ""
    @AppStorage("useGpt4") var useGpt4: Bool = false
    @State var showingSectionTranscription = true
    @State var showingSectionSummary = true
    @State var showingSectionOverview = true
    
    @State private var isKeyboardVisible = false
    @State private var keyboardHeight: CGFloat = 0
    @State private var summarizeInProgress = false
    
    let buttonFontSize = CGFloat(16)
    let items = ["Item 1", "Item 2", "Item 3", "Item 4", "Item 5"]
    
    let transcribeButtonDisabled = false

    var body: some View {
        let missingApiKey = apiKey == ""
        let summarizeButtonDisabled = missingApiKey || summarizeInProgress
        
        let summaryExists = record.memorySummary != nil
        let title = record.memorySummary?.title != nil ? record.memorySummary?.title : record.title
        let groups = viewModel.speakerGroups()

//        let summaryExists = (record.summary ?? "") != ""
        
        VStack(spacing: 0) {
            customHeader()
                        .frame(maxWidth: .infinity) // Adjust according to your design
            
            Divider() // This adds the line beneath your HeaderView
            
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    
                    Text((title ?? "New Moment").capitalized)
                        .font(.titleFont(ofSize:  24))
                        .frame(maxWidth: .infinity, minHeight: 48, alignment: .leading)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 0)
                        .lineLimit(3)
                    
//                    TextEditor(text: Binding(
//                        get: { (title ?? "New Moment").capitalized },
//                        set: { self.record.title = $0 }))
//                        .font(.titleFont(ofSize:  24))
//                        .frame(maxWidth: .infinity, minHeight: 200, alignment: .leading)
//                        .padding(.vertical, 10)
//                        .padding(.horizontal, 0)
//                        .lineLimit(3)
//                    
                    
                    
                    if showingSectionSummary {
                        Section(
                            header: summarySectionHeader(title: "Summary", imageName: "note.text")
                        ) {
                            if summaryExists {
                                Text(record.memorySummary?.summary ?? "")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            } else if viewModel.sortedRows.count > 0 {
                                // show summary button if the transcription is done already
                                Button(action: {
                                    print("Summarize clicked")
                                    summarizeInProgress = true
                                    Task {
                                        await viewModel.summarize(context: viewContext, record: record, apiKey: apiKey, useGpt4: useGpt4)
                                    }
                                }) {
                                    HStack {
                                        Image(systemName: "sparkles")
                                        Text(summaryExists ? "Regenerate summary" : "Generate summary")
                                    }
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .frame(maxWidth: .infinity) // Make the button take the full width
                                .background(summarizeButtonDisabled ? Theme.Color.indigo400 : Theme.Color.indigo600)
                                .foregroundColor(summarizeButtonDisabled ? Theme.Color.gray200 : .white)
                                .cornerRadius(4)
                                .shadow(radius: 1)
                                .disabled(summarizeButtonDisabled)
                                .font(.system(size: buttonFontSize, weight: .semibold, design: .default))
                                .lineSpacing(buttonFontSize * 0.3)
                                (missingApiKey ? Text("Please add API key under settings to enable summarization").italic().foregroundColor( Theme.Color.gray800) : nil)
                            }
                            
                        }
                        if record.memorySummary?.sentiment != nil {
                            Section( header: summarySectionHeader(title: "Sentiment", imageName: "thermometer.medium")) {
                                Text(record.memorySummary?.sentiment ?? "")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                        
                        viewModel.getSections()
                        
                    }
                    
                    if viewModel.sortedRows.count > 0 {
                        Section(
                            header: SectionHeader(
                                title: "Transcription", 
                                icon: Image(systemName: "doc.text"),
                                content: {
//                                    Menu{
//                                        Button("Redo transcription", action: {
//                                            
//                                        })
//                                        Button("Cancel", action: {
//                                            
//                                        })
//                                    } label: {
//                                        Label("", systemImage: "ellipsis")
//                                    } primaryAction: {
//                                        
//                                    }
                                }
                            )
                        ) {
                            if showingSectionTranscription {
                                VStack(spacing: 20) {
                                    ForEach(groups, id: \.id) { group in
                                        AnnotationGroupView(group: group, peopleViewModel: peopleViewModel, recordViewModel: viewModel)
                                    }
                                }
                            }
                            
                        }
                        
                    }
                    
                    Section(
                        header: SectionHeader(
                            title: "Details",
                            icon: Image(systemName: "doc.text"),
                            content: {
                                
                            }
                        )
                    ) {
                        if showingSectionOverview {
                            TextField("Title", text: Binding(
                                get: { self.record.title ?? "" },
                                set: { self.record.title = $0 }
                            ))
                            //                TextField("Snippet", text: Binding(
                            //                    get: { self.record.snippet ?? "" },
                            //                    set: { self.record.snippet = $0 }
                            //                ))
                            //                TextField("Icon Name", text: Binding(
                            //                    get: { self.record.iconName ?? "" },
                            //                    set: { self.record.iconName = $0 }
                            //                ))
                            //                Slider(value: Binding(
                            //                    get: { Float(self.record.durationInMinutes) },
                            //                    set: { self.record.durationInMinutes = $0 }
                            //                ), in: 0...120, step: 1)
                            Text("Duration: \(viewModel.durationInMinutes, specifier: "%.0f") minutes")
                            Text("Created Date: \(record.createdDate ?? Date(), formatter: dateFormatter)")
                        }
                    }
                    
                    //        VStack {
                    //            Text(verbatim: whisperState.messageLog).frame(maxWidth: .infinity, alignment: .leading)
                    //        }
                    
                    FormSpacer().padding(.bottom, 100)
                    
                } // end inner VStack
                .padding()
            } // end ScrollView
                .overlay(
                    SelectOrNewPersonView(peopleViewModel: peopleViewModel, recordViewModel: viewModel)
                        .environment(\.managedObjectContext, self.viewContext)
                )
            
        } // end outer VStack
            .overlay(
                VStack {
                    if !peopleViewModel.showingPersonSelector {
                        Button(action: {
                            whisperState.transcriptionHandler = { transcriptions in
                                // Handle the transcription here
                                // Example: print the transcription or update some state
                                print("Foobar Transcription: \(transcriptions)")
                                if let existingRows = record.rows as? Set<AvRecordRow> {
                                    for row in existingRows {
                                        viewContext.delete(row)
                                    }
                                }
                                for row in transcriptions {
                                    let newRow = AvRecordRow(context: viewContext)
                                    newRow.parent = record
                                    newRow.t0 = row.t0
                                    newRow.t1 = row.t1
                                    newRow.text = row.text
                                    newRow.turn = row.turn
                                }
                                
                                // Save the duration in Minutes
                                record.durationInMinutes = viewModel.durationInMinutes
                                
                                do {
                                    try viewContext.save()
                                } catch {
                                    print("Could not save transcription rows: \(error)")
                                }
                                
                                // Refresh the rows
                                viewModel.updateContextAndRecord(context: viewContext, record: record)
                            }
                            recordHandler.performAction()
                        }) {
                            let buttonImage = whisperState.isRecording ? "stop.fill" : "mic.fill";
                            Image(systemName: buttonImage)
                                .font(.title.weight(.semibold))
                                .padding()
                                .background(Color.white)
                                .foregroundColor(.indigo)
                                .clipShape(Circle())
                                .shadow(radius: 4, x: 0, y: 4)
                                .disabled(!whisperState.canTranscribe)
                        }
                    }
                }.padding(), alignment: .bottom)
        .onAppear {
            viewModel.summaryCallback =  { (message: UpdateMemorySummary) in
                if (record.memorySummary) == nil {
                    record.memorySummary = MemorySummary(context: viewContext)
                }
                switch message.messageType {
                    case .NewMessage:
                        print("Deleting existing rows")
                        deleteExistingRows(messageSummary: record.memorySummary!)
                        do {
                            try viewContext.save()
                        } catch {
                            print("Could not delete existing rows: \(error)")
                        }
                        break;
                    default:
                        break;
                }
                
                record.summary = message.body
                // assign fields
                if let messageSummary = message.memorySummary,
                   let recordSummary = record.memorySummary {
                    recordSummary.summary = messageSummary.summary
                    recordSummary.title = messageSummary.title
                    recordSummary.sentiment = messageSummary.sentiment
                }
                
                switch message.messageType {
                    case .CompleteMessage:
                        // Add the list items which currently can't be added incrementally.
                        {
                            if let messageSummary = message.memorySummary,
                                let recordSummary = record.memorySummary {

                                for (index, item) in messageSummary.actionItems.enumerated() {
                                    let newItem = MemoryActionItem(context: viewContext)
                                    newItem.parent = recordSummary
                                    newItem.text = item
                                    newItem.delta = Int32(index)
                                    print("Created MemoryActionItem at index \(index): \(item)")
                                }

                                for (index, item) in messageSummary.followUp.enumerated() {
                                    let newItem = MemoryFollowUp(context: viewContext)
                                    newItem.parent = recordSummary
                                    newItem.text = item
                                    newItem.delta = Int32(index)
                                    print("Created MemoryFollowUp at index \(index): \(item)")
                                }

                                for (index, item) in messageSummary.arguments.enumerated() {
                                    let newItem = MemoryArgument(context: viewContext)
                                    newItem.parent = recordSummary
                                    newItem.text = item
                                    newItem.delta = Int32(index)
                                    print("Created MemoryArgument at index \(index): \(item)")
                                }

                                for (index, item) in messageSummary.relatedTopics.enumerated() {
                                    let newItem = MemoryTopic(context: viewContext)
                                    newItem.parent = recordSummary
                                    newItem.text = item
                                    newItem.delta = Int32(index)
                                    print("Created MemoryTopic at index \(index): \(item)")
                                }

                                for (index, item) in messageSummary.mainPoints.enumerated() {
                                    let newItem = MemoryMainPoint(context: viewContext)
                                    newItem.parent = recordSummary
                                    newItem.text = item
                                    newItem.delta = Int32(index)
                                    print("Created MemoryMainPoint at index \(index): \(item)")
                                }

                                for (index, item) in messageSummary.stories.enumerated() {
                                    let newItem = MemoryStory(context: viewContext)
                                    newItem.parent = recordSummary
                                    newItem.text = item
                                    newItem.delta = Int32(index)
                                    print("Created MemoryStory at index \(index): \(item)")
                                }
                                
                                // Overwrite the user title
                                record.title = messageSummary.title
                            }
                        }()

                        do {
                            try viewContext.save()
                        } catch {
                            print("Could not save summary: \(error)")
                        }
                        summarizeInProgress = false
                        break;
                    default:
                        break;
                }
            }

            viewModel.updateContextAndRecord(context: viewContext, record: record)
            // Compute the duration based on the transcription length
//            record.durationInMinutes = viewModel.durationInMinutes

            recordHandler.action = {
                print("Record clicked")
                Task {
                    await whisperState.toggleRecord()
                }
            }
            
            
//            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { notification in
//                if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
//                    self.keyboardHeight = keyboardFrame.height
//                    self.isKeyboardVisible = true
//                }
//            }
//
//            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
//                self.keyboardHeight = 0
//                self.isKeyboardVisible = false
//            }
        }
        .onDisappear {
//            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
//            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        }
    }
    

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        return formatter
    }
    
    private func saveAndRefresh() {
        do {
            try viewContext.save()
        } catch {
            print("Could not add new person: \(error)")
        }
        // Refresh the rows
        viewModel.updateContextAndRecord(context: viewContext, record: record)
    }
    
    private func speakerFlag(rows: [AvRecordRow]) -> [Bool] {
        var i = 0;
        return rows.map { item in
            if item.turn {
                i += 1
            }
            return i % 2 == 0
        }
    }

    private func printAllSystemFonts() {
        for family in UIFont.familyNames.sorted() {
            print("\(family)")
            for name in UIFont.fontNames(forFamilyName: family).sorted() {
                print("   \(name)")
            }
        }
    }

    private func customHeader() -> some View {
        
        return HStack {
            Button(action: {
                self.presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "xmark") // Replace with your X icon
            }
            Color.clear.frame(width: 30, height: 1) // Invisible spacer
            Spacer()

            Text("Memory")
                .foregroundColor(Theme.Color.gray700) // Set the color as needed
                .textCase(nil)
                .font(.viewHeadingFont(ofSize: 20))
                .padding(.bottom, 14)
                .padding(.top, 18)
            .frame(maxWidth: .infinity, alignment: .center) // Center aligned
            
            Spacer()

            HStack(spacing: 20) {
                Menu{
                    Button("E-mail", action: {  })
                    Button("Message", action: {  })
                    Button("Cancel", action: { })
                } label: {
                    HStack {
                        Image(systemName: "square.and.arrow.up") // Replace with your Share icon
                    }
                } primaryAction: {
                    
                }
                
                Menu{
                    Button("Re-do summary", action: {
                        print("Summarize clicked")
                        summarizeInProgress = true
                        Task {
                            await viewModel.summarize(context: viewContext, record: record, apiKey: apiKey, useGpt4: useGpt4)
                        }
                    })
                    Button("Cancel", action: { })
                } label: {
                    HStack {
                        Image(systemName: "ellipsis.circle") // Replace with your Share icon
                    }
                } primaryAction: {
                    
                }
            }
        }
        .frame(maxWidth: .infinity) // Takes up full width of the screen
        .padding(.horizontal)
        
    }
    
    private func bulletedList(from: [String?]) -> some View {
        return BulletedListView(from: from)
    }
    
    private func deleteExistingRows(messageSummary: MemorySummary) {
        if let existingRows = messageSummary.actionItems as? Set<MemoryActionItem> {
            print("Deleting action items")
            for row in existingRows {
                viewContext.delete(row)
            }
        }
        if let existingRows = messageSummary.arguments as? Set<MemoryArgument> {
            for row in existingRows {
                viewContext.delete(row)
            }
        }
        if let existingRows = messageSummary.followUp as? Set<MemoryFollowUp> {
            for row in existingRows {
                viewContext.delete(row)
            }
        }
        if let existingRows = messageSummary.topics as? Set<MemoryTopic> {
            for row in existingRows {
                viewContext.delete(row)
            }
        }
        if let existingRows = messageSummary.mainPoints as? Set<MemoryMainPoint> {
            for row in existingRows {
                viewContext.delete(row)
            }
        }
        if let existingRows = messageSummary.stories as? Set<MemoryStory> {
            for row in existingRows {
                viewContext.delete(row)
            }
        }
    }
    
    private func addListItems(recordSummary: MemorySummary, value: String, index: NSNumber) {
        let fetchRequest: NSFetchRequest<MemoryActionItem> = MemoryActionItem.fetchRequest()
        let parentPredicate = NSPredicate(format: "parent == %@", recordSummary)
        let deltaPredicate = NSPredicate(format: "delta == %@", index)

        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [parentPredicate, deltaPredicate])
        
        let results = try? viewContext.fetch(fetchRequest)
        if results?.isEmpty ?? true {
            // No existing item found, create a new one
            let newItem = MemoryActionItem(context: viewContext)
            newItem.parent = recordSummary
            newItem.text = value
            newItem.delta = Int32(truncating: index) // Assuming delta is of type Int32
        } else {
            // Item already exists, update it if necessary
            // For example, update `newItem.text` if it's different from `item`
        }

    }
    

}

#Preview {
    EditAvRecordView(record: AvRecord())
}
