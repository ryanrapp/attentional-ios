//
//  EditAvRecordView.swift
//  attentional.swiftui
//
//  Created by Ryan Rapp on 1/1/24.
//

import SwiftUI
import CoreData
import TailwindCSS_SwiftUI


struct EditAvRecordView: View {
    @ObservedObject var record: AvRecord
    @ObservedObject var whisperState = WhisperState.shared
    @StateObject var recordHandler = ActionHandler()
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewModel = RecordViewModel()
    @AppStorage("apiKey") var apiKey: String = ""
    @State var showingSectionTranscription = true
    @State var showingSectionSummary = true
    @State var showingSectionOverview = true
    
    let buttonFontSize = CGFloat(16)
    
    var body: some View {
        Form {
            Section(
                header: SectionHeader(
                    title: "Moment Info",
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
                    }
                }
            }
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
                            Button(action: {
                                print("Summarize clicked")
                                Task {
                                    await viewModel.summarize(context: viewContext, record: record, apiKey: apiKey)
                                }
                            }) {
                                HStack {
                                    Image(systemName: "sparkles")
                                    Text("Generate summary")
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity) // Make the button take the full width
                            .background(Theme.Color.indigo600)
                            .foregroundColor(.white)
                            .cornerRadius(4)
                            .shadow(radius: 1)
                            .disabled(apiKey != "")
                            .font(.system(size: buttonFontSize, weight: .semibold, design: .default))
                            .lineSpacing(buttonFontSize * 0.3)
                        }
                    }
                }
            }
        }.background(Color.gray)
       
//        VStack {
//            Text(verbatim: whisperState.messageLog).frame(maxWidth: .infinity, alignment: .leading)
//        }
        ZStack(alignment: .bottom) {
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
            }
            .padding()
        }
        .onAppear {
            viewModel.updateContextAndRecord(context: viewContext, record: record)
            // Compute the duration based on the transcription length
//            record.durationInMinutes = viewModel.durationInMinutes

            recordHandler.action = {
                print("Record clicked")
                Task {
                    await whisperState.toggleRecord()
                }
            }
        }
    }
    

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        return formatter
    }
}

#Preview {
    EditAvRecordView(record: AvRecord())
}
