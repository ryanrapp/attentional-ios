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

struct EditAvRecordView: View {
    @ObservedObject var record: AvRecord
    @ObservedObject var whisperState = WhisperState.shared
    @StateObject var recordHandler = ActionHandler()
    @Environment(\.managedObjectContext) private var viewContext
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
    
    var body: some View {
        let missingApiKey = apiKey == ""
        let summarizeButtonDisabled = missingApiKey || summarizeInProgress
        let summaryExists = record.memorySummary != nil
//        let summaryExists = (record.summary ?? "") != ""
        
        VStack(spacing: 0) {
            customHeader()
                        .frame(maxWidth: .infinity) // Adjust according to your design
            
            Divider() // This adds the line beneath your HeaderView

            Form {
                
                if viewModel.sortedRows.count > 0 {
                    Section(
                        header: SectionHeader(
                            title: "Summary",
                            isOn: $showingSectionSummary,
                            onLabel: "Hide",
                            offLabel: "Show"
                        )
                    ) {
                        if showingSectionSummary {
                            VStack {
                                if record.memorySummary?.summary != nil {
                                    SimpleHeading(title: "Overview")
                                    Text(record.memorySummary?.summary ?? "")
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                if record.memorySummary?.sentiment != nil {
                                    SimpleHeading(title: "Sentiment", icon: "thermometer.medium")
                                    Text(record.memorySummary?.sentiment ?? "")
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                if record.memorySummary?.actionItems != nil {
//                                    let actionItems = record.memorySummary!.actionItems.map { (myitem: MemoryActionItem) in
//                                        return myitem.text
//                                    };
                                    SimpleHeading(title: "Action Items", icon: "bolt.fill")
//                                    self.bulletedList(from: actionItems)
                                        
                                }
                                
                                
                                
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
                                .background(summarizeButtonDisabled ? Theme.Color.indigo500 : Theme.Color.indigo600)
                                .foregroundColor(summarizeButtonDisabled ? Theme.Color.gray200 : .white)
                                .cornerRadius(4)
                                .shadow(radius: 1)
                                .disabled(summarizeButtonDisabled)
                                .font(.system(size: buttonFontSize, weight: .semibold, design: .default))
                                .lineSpacing(buttonFontSize * 0.3)
                                (missingApiKey ? Text("Please add API key under settings to enable summarization").italic().foregroundColor( Theme.Color.gray800) : nil)
                                
                            }
                        }
                        
                    }
                }
                
                if viewModel.sortedRows.count > 0 {
                    Section(
                        header: SectionHeader(
                            title: "Transcription",
                            isOn: $showingSectionTranscription,
                            onLabel: "Hide",
                            offLabel: "Show"
                        )
                    ) {
                        if showingSectionTranscription {
                            List(viewModel.sortedRows, id: \.self) { transcriptRow in
                                Text(transcriptRow.text ?? "No text")
                            }
                            Button(action: {
                                print("Redo transcription clicked")
                                
                            }) {
                                HStack {
                                    Image(systemName: "sparkles")
                                    Text("Redo transcription")
                                }
                            }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .frame(maxWidth: .infinity) // Make the button take the full width
                                .background(summarizeButtonDisabled ? Theme.Color.indigo500 : Theme.Color.indigo600)
                                .foregroundColor(summarizeButtonDisabled ? Theme.Color.gray200 : .white)
                                .cornerRadius(4)
                                .shadow(radius: 1)
                                .disabled(summarizeButtonDisabled)
                                .font(.system(size: buttonFontSize, weight: .semibold, design: .default))
                                .lineSpacing(buttonFontSize * 0.3)
                        }
                    }
                }
                    
                Section(
                    header: SectionHeader(
                        title: "Details",
                        isOn: $showingSectionOverview,
                        onLabel: "Hide",
                        offLabel: "Show"
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
                        Text("Duration: \(self.record.durationInMinutes, specifier: "%.0f") minutes")
                        Text("Created Date: \(record.createdDate ?? Date(), formatter: dateFormatter)")
                    }
                }
                
                //        VStack {
                //            Text(verbatim: whisperState.messageLog).frame(maxWidth: .infinity, alignment: .leading)
                //        }
                
                FormSpacer().padding(.bottom, 100)
            }
            
        }
        .background(Theme.Color.gray100)
            
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
                        }
                        do {
                            try viewContext.save()
                        } catch {
                            print("Could not save transcription rows: \(error)")
                        }
                        // Save the duration in Minutes
                        record.durationInMinutes = viewModel.durationInMinutes
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
                // update memorySummary
                {
                    if let messageSummary = message.memorySummary,
                        let recordSummary = record.memorySummary {
                        for item in messageSummary.actionItems {
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
                        
                        // assign fields
                        recordSummary.summary = messageSummary.summary
                        recordSummary.title = messageSummary.title
                        recordSummary.sentiment = messageSummary.sentiment
                    }
                }()
                
                record.summary = message.body
                switch message.messageType {
                    case .CompleteMessage:
                        do {
                            try viewContext.save()
                        } catch {
                            print("Could not save summary: \(error)")
                        }
                    summarizeInProgress = false
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
    
    private func customHeader() -> some View {
        let title = record.memorySummary?.title != nil ? record.memorySummary?.title : record.title
        
        return HStack {
            Text((title ?? "Moment").capitalized)
                .foregroundColor(Theme.Color.gray700) // Set the color as needed
                .textCase(nil)
                .font(.system(size: 24, weight: .bold, design: .default))
//                .padding(.leading, 20)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity, alignment: .center)
            Spacer()
        }
    }
    
    private func bulletedList(from: [String]) -> some View {
        VStack {
            ForEach(from, id: \.self) { item in
                Label(title: {
                    Text(item)
                }, icon: {
                    Image(systemName: "circle.fill")
                })
            }
        }
    }
}

#Preview {
    EditAvRecordView(record: AvRecord())
}
