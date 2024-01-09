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
    let groupColors = [Theme.Color.indigo700, Theme.Color.teal700, Theme.Color.orange700, Theme.Color.pink700, Theme.Color.blue700, Theme.Color.red700]
    let letters = ["A", "B", "C", "D", "E", "F", "G", "H", "I"]
    let transcribeButtonDisabled = false

    
    var body: some View {
        let missingApiKey = apiKey == ""
        let summarizeButtonDisabled = missingApiKey || summarizeInProgress
        
        let summaryExists = record.memorySummary != nil
        let title = record.memorySummary?.title != nil ? record.memorySummary?.title : record.title
        let groups = self.speakerGroups(rows: viewModel.sortedRows)
                
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
//                            Section(
//                                header: summarySectionHeader(title: "Summary", imageName: "doc.text")
//                            ) {
                            
                            Section( header: summarySectionHeader(title: "Sentiment", imageName: "thermometer.medium")) {
                                Text(record.memorySummary?.sentiment ?? "")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                        if record.memorySummary?.actionItems != nil {
                            if let actionItemsSet = record.memorySummary?.actionItems as? Set<MemoryActionItem> {
                                let actionItems = actionItemsSet.map { $0.text }
                                
                                Section( header: summarySectionHeader(title: "Action Items", imageName: "bolt")) {
                                    self.bulletedList(from: actionItems)
                                }
                            }
                        }
                        if record.memorySummary?.followUp != nil {
                            if let itemSet = record.memorySummary?.followUp as? Set<MemoryFollowUp> {
                                let items = itemSet.map { $0.text }
                                Section( header: summarySectionHeader(title: "Follow Up", imageName: "mail")) {
                                    self.bulletedList(from: items)
                                }
                            }
                        }
                        if record.memorySummary?.arguments != nil {
                            if let itemSet = record.memorySummary?.arguments as? Set<MemoryArgument> {
                                let items = itemSet.map { $0.text }
                                Section( header: summarySectionHeader(title: "Arguments", imageName: "bolt")) {
                                    self.bulletedList(from: items)
                                }
                            }
                        }
                        if record.memorySummary?.topics != nil {
                            if let itemSet = record.memorySummary?.arguments as? Set<MemoryArgument> {
                                let items = itemSet.map { $0.text }
                                Section( header: summarySectionHeader(title: "Related Topics", imageName: "tag")) {
                                    self.bulletedList(from: items)
                                }
                            }
                        }
                    }
                    
                    if viewModel.sortedRows.count > 0 {
                        Section(
                            header: SectionHeader(
                                title: "Transcription", 
                                icon: Image(systemName: "doc.text"),
                                content: {
                                    Menu{
                                        Button("Redo transcription", action: {
                                            
                                        })
                                        Button("Cancel", action: {
                                            
                                        })
                                    } label: {
                                        Label("", systemImage: "ellipsis")
                                    } primaryAction: {
                                        
                                    }
                                }
                            )
                        ) {
                            VStack(spacing: 20) {
                                ForEach(Array(zip(groups.indices, groups)), id: \.1) { index, group in
                                    VStack(spacing: 0) {
                                        
                                        Menu{
                                            //                                            Button("Choose user", action: {
                                            //
                                            //                                            })
                                            Button("Cancel", action: {
                                                
                                            })
                                        } label: {
                                            HStack(spacing: 4) {
                                                Text("\(letters[index % letters.count])")
                                                    .font(.footnote)
                                                    .foregroundColor(.white)
                                                    .padding(8)
                                                    .background(groupColors[index % groupColors.count])
                                                    .clipShape(Circle())
                                                    .font(.system(size: 20, weight: .semibold, design: .default))
                                                Text("Speaker \(letters[index % letters.count])")
                                                    .font(.system(size: 14, weight: .semibold, design: .default))
                                                    .foregroundColor(Color.black)
                                                    
                                                
                                            }
                                                .padding(8)
                                                .cornerRadius(4)
                                                
                                            
//                                            Label("Speaker \(index + 1)", systemImage: "person.crop.circle")
//                                                .padding(.vertical, 4)
//                                                .padding(.horizontal, 8)
//                                                .foregroundColor(Color.black)
//                                                .background(groupColors[index % groupColors.count])
//                                                .cornerRadius(4)
//                                                .shadow(radius: 1)
//                                                .disabled(summarizeButtonDisabled)
//                                                .font(.system(size: 14, weight: .semibold, design: .default))
//                                                .lineSpacing(14 * 0.3)
                                        } primaryAction: {
                                            
                                        }.frame(maxWidth: .infinity, alignment: .leading)
                                        
                                        
                                        ForEach(group) { transcriptRow in
                                            Text(transcriptRow.text?.trimmingCharacters(in:.whitespacesAndNewlines) ?? "No text")
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                            
                                        }
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
            
        } // end outer VStack
        
            
            .overlay(
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
                }.padding()
                , alignment: .bottom)
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
                                }
                                for item in messageSummary.followUp {
                                    let newItem = MemoryFollowUp(context: viewContext)
                                    newItem.parent = recordSummary
                                    newItem.text = item
                                }
                                for item in messageSummary.arguments {
                                    let newItem = MemoryArgument(context: viewContext)
                                    newItem.parent = recordSummary
                                    newItem.text = item
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
            
            
            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { notification in
                if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                    self.keyboardHeight = keyboardFrame.height
                    self.isKeyboardVisible = true
                }
            }

            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
                self.keyboardHeight = 0
                self.isKeyboardVisible = false
            }
        }
        .onDisappear {
            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        }
    }
    

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        return formatter
    }
    
//    private func getMarkdown() -> some View {
//        Markdown(record.summary ?? "")
//           .markdownBlockStyle(\.heading2) { configuration in
//               configuration.label
//                   .markdownTextStyle {
//                       FontSize(22)
//                       FontWeight(.bold)
//                       ForegroundColor(Theme.Color.gray500)
//                   }
//           }
//    }
    
    private func speakerFlag(rows: [AvRecordRow]) -> [Bool] {
        var i = 0;
        return rows.map { item in
            if item.turn {
                i += 1
            }
            return i % 2 == 0
        }
    }
    
    private func speakerGroups(rows: [AvRecordRow]) -> [[AvRecordRow]] {
        var groups: [[AvRecordRow]] = []
        var group: [AvRecordRow] = []
        rows.forEach { item in
            if item.turn {
                groups.append(group)
                group = [item]
            } else {
                group.append(item)
            }
        }
        if group.count > 0 {
            groups.append(group)
        }
        return groups
    }
    
    private func printAllSystemFonts() {
        for family in UIFont.familyNames.sorted() {
            print("\(family)")
            for name in UIFont.fontNames(forFamilyName: family).sorted() {
                print("   \(name)")
            }
        }
    }
    
    private func summarySectionHeader(title: String, imageName: String) -> some View {
        return SectionHeader(
            title: title,
            icon: Image(systemName: imageName),
            content: {
                Menu{
                    Button("Re-summarize", action: {
                        print("Summarize clicked")
                        summarizeInProgress = true
                        Task {
                            await viewModel.summarize(context: viewContext, record: record, apiKey: apiKey, useGpt4: useGpt4)
                        }
                    })
                    Button("Cancel", action: {
                        
                    })
                } label: {
                    Label("", systemImage: "ellipsis")
                } primaryAction: {
                    
                }
            }
        )
    }
    
    private func customHeader() -> some View {
        
        return HStack {
            Button(action: {
                self.presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "xmark") // Replace with your X icon
            }
            .padding(.leading) // Adds padding to the left side
            .frame(maxWidth: .infinity, alignment: .leading) // Left aligned

            Spacer() // Creates space between left and center content

            Text("Memory")
                .foregroundColor(Theme.Color.gray700) // Set the color as needed
                .textCase(nil)
                .font(.viewHeadingFont(ofSize: 20))
                .padding(.bottom, 14)
                .padding(.top, 18)
            .frame(maxWidth: .infinity, alignment: .center) // Center aligned

            Spacer() // Creates space between center and right content

            Menu{
                Button("E-mail", action: {  })
                Button("Message", action: {  })
                Button("Cancel", action: { })
            } label: {
                HStack {
                    Text("Share").font(.buttonFont(ofSize: 14))
                    Image(systemName: "square.and.arrow.up") // Replace with your Share icon
                }
            } primaryAction: {
                
            }
            .frame(maxWidth: .infinity, alignment: .trailing) // Right aligned
            
            
            Spacer()
        }
    }
    
    private func bulletedList(from: [String?]) -> some View {
        VStack {
            ForEach(Array(from.enumerated()), id: \.0) { index, item in
                let num = index + 1;
                HStack(alignment: .firstTextBaseline, spacing: 8) {
//                    Image(systemName: "circle.fill")
//                        .resizable()
//                        .scaledToFit()
//                        .frame(width: 6, height: 6, alignment: .centerFirstTextBaseline)
//                        .foregroundColor(Theme.Color.gray600)
//                        .padding(.top, 3)
//                        .padding(.trailing, 4)
                    Text("\(num, specifier: "%d").")
                        .frame(maxWidth: 30, alignment: .trailingFirstTextBaseline)
                        .padding(.leading, -6)
                        .foregroundColor(Theme.Color.gray600)
                    Text(item ?? "")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }.padding(.leading, 0)
            }
        }
    }
    
    private func deleteExistingRows(messageSummary: MemorySummary) {
        if let existingRows = messageSummary.actionItems as? Set<MemoryActionItem> {
            print("Deleting action items")
            for row in existingRows {
                viewContext.delete(row)
            }
        } else {
            print("Action items could not conform")
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
