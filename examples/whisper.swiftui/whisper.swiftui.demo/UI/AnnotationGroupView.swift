//
//  AnnotationGroupView.swift
//  attentional.swiftui
//
//  Created by Ryan Rapp on 1/11/24.
//

import SwiftUI

struct AnnotationGroupView: View {
    let group: SpeakerAnnotationGroup
    @Environment(\.managedObjectContext) private var viewContext
    
    @ObservedObject var peopleViewModel: PeopleViewModel
    @ObservedObject var recordViewModel: RecordViewModel
    
    var body: some View {
        let showRemoveSpeakerButton = group.index > 0
        
        VStack(spacing: 0) {
            Menu {
                Button(action: {
                    print("Showing Person Modal")
                    peopleViewModel.showingPersonSelector = true
                    peopleViewModel.selectingPersonRow = group.rows.first
                    peopleViewModel.selectedPerson = peopleViewModel.selectingPersonRow?.speaker
                    peopleViewModel.newPersonName = ""
                    
                }) {
                    Text("Select speaker")
                    Image(systemName: "person.and.arrow.left.and.arrow.right")
                }
                if showRemoveSpeakerButton {
                    Button(action: {
                        // Action for Menu Item 1
                        if let row = group.rows.first {
                            row.turn = false
                            saveAndRefresh()
                        }
                    }) {
                        Text("Remove speaker")
                            .foregroundColor(.red)
                        Image(systemName: "trash")
                    }
                }
                
                Button(action: {
                    peopleViewModel.selectingPersonRow = nil
                }) {
                    Text("Cancel")
                    Image(systemName: "xmark")
                }
            } label: {
                PersonTagView(group: group)
            } primaryAction: {
                
            }.frame(maxWidth: .infinity, alignment: .leading).padding(.bottom, 8)
            
            ForEach(group.rows) { transcriptRow in
                getTranscriptRowView(transcriptRow: transcriptRow)
            }
        }
    }
    
    private func getTranscriptRowView(transcriptRow: AvRecordRow) -> some View {
        Text(transcriptRow.text?.trimmingCharacters(in:.whitespacesAndNewlines) ?? "No text")
            .frame(maxWidth: .infinity, alignment: .leading)
            .contextMenu {
                
                if !transcriptRow.turn {
                    Button(action: {
                        transcriptRow.turn = true
                        saveAndRefresh()
                    }) {
                        Text("New speaker")
                        Image(systemName: "person.badge.plus")
                    }
                } else {
                    Button(action: {
                        // Action for Menu Item 1
                        transcriptRow.turn = false
                        saveAndRefresh()
                    }) {
                        Text("Remove speaker")
                        Image(systemName: "trash")
                    }
                }
                
                Button(action: {
                    // Action for Menu Item 2
                    print("Cancel")
                }) {
                    Text("Cancel")
                    Image(systemName: "xmark")
                }
            }
        
    }
    
    private func saveAndRefresh() {
        do {
            try viewContext.save()
        } catch {
            print("Could not add new person: \(error)")
        }
        // Refresh the rows
        recordViewModel.updateContext(context: viewContext)
    }
}

#Preview {
    AnnotationGroupView(group: SpeakerAnnotationGroup(rows: [], index: 0), peopleViewModel: PeopleViewModel(), recordViewModel: RecordViewModel())
}
