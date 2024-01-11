//
//  SelectOrNewPersonView.swift
//  attentional.swiftui
//
//  Created by Ryan Rapp on 1/11/24.
//

import SwiftUI
import TailwindCSS_SwiftUI

struct SelectOrNewPersonView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var selectedTab = 0
    
    @ObservedObject var peopleViewModel: PeopleViewModel
    @ObservedObject var recordViewModel: RecordViewModel
    
    private let buttonFontSize:CGFloat = 16
    
    init(selectedTab: Int = 0, peopleViewModel: PeopleViewModel, recordViewModel: RecordViewModel) {

        self.selectedTab = selectedTab
        self.peopleViewModel = peopleViewModel
        self.recordViewModel = recordViewModel
    }
    
    var body: some View {
        let showingPersonSelector = peopleViewModel.showingPersonSelector
        
        VStack {
            if showingPersonSelector {
                VStack {
                    Picker("Options", selection: $selectedTab) {
                        Text("Select").tag(0)
                        Text("Add").tag(1)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()
                    
                    if selectedTab == 0 {
                        // Tab 1 Content
                        getSelectPersonView()
                    } else {
                        // Tab 2 Content
                        getAddPersonView()
                    }
                    
                    //                    getSelectPersonView().tabItem {
                    //                        Label("Add", systemImage: "person.badge.plus")
                    //                    }
                    
                    
                }
                .padding()

                .background(Color.white)
                .cornerRadius(10)
                .shadow(radius: 10)
                .frame(width: 300) // Set width for the modal
            }
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
            .offset(y: -100) // Adjust this value to move the modal up
            .background(Color.black.opacity(showingPersonSelector ? 0.4 : 0))
            .edgesIgnoringSafeArea(.all)
            .animation(.easeInOut, value: showingPersonSelector)
            .onAppear() {
                peopleViewModel.updateContext(context: viewContext)
            }
    }
    
    private func getAddPersonView() -> some View {
        return VStack {
            if peopleViewModel.showingPersonSelector {
                VStack(spacing: 20) {
                    Text("Add a Person")
                        .font(.headline)
                    
                    TextField("Add new person", text: $peopleViewModel.newPersonName)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(5.0)

                    HStack(spacing: 16) {
                        Button(action: {
                            let newPerson = peopleViewModel.addPerson()
                            if let name = newPerson?.name {
                                print("Added person: \(name)")
                            }
                            else {
                                print("Cleared person")
                            }
                            peopleViewModel.showingPersonSelector = false
                        }) {
                            Image(systemName: "checkmark")
                            Text("Add")
                                .font(.system(size: buttonFontSize, weight: .semibold, design: .default))
                        }.disabled(peopleViewModel.newPersonName == "")
                            .padding()
                        Button(action: {
                            peopleViewModel.newPersonName = ""
                            peopleViewModel.showingPersonSelector = false
                        }) {
                            Image(systemName: "xmark")
                            Text("Cancel")
                                .font(.system(size: buttonFontSize, weight: .semibold, design: .default))
                        }.padding()
                    }
                }
            }
        }
    }
    
    private func getSelectPersonView() -> some View {
        return VStack {
            if peopleViewModel.showingPersonSelector {
                VStack(spacing: 20) {
                    Text("Select a Person")
                        .font(.headline)
                    
                    Picker("Person", selection: $peopleViewModel.selectedPerson) {
                        Text("None").tag(nil as Person?)  // Add this to allow no selection
                        ForEach(peopleViewModel.people, id: \.id) { person in
                            Text(person.name ?? "").tag(person as Person?)
                        }
                    }.padding(.vertical, 10)
                    
                    HStack(spacing: 16) {
                        Button(action: {
                            // Handle selection or adding new person
                            peopleViewModel.selectingPersonRow?.speaker = peopleViewModel.selectedPerson
                            do {
                                try viewContext.save()
                            } catch {
                                print("Could not add new person: \(error)")
                            }
                            peopleViewModel.updateContext(context: viewContext)
                        
                            peopleViewModel.showingPersonSelector = false
                        }) {
                            Image(systemName: "checkmark")
                            Text("Ok")
                                .font(.system(size: buttonFontSize, weight: .semibold, design: .default))
                        }.padding()
                        Button(action: {
                            peopleViewModel.newPersonName = ""
                            peopleViewModel.showingPersonSelector = false
                        }) {
                            Image(systemName: "xmark")
                            Text("Cancel")
                                .font(.system(size: buttonFontSize, weight: .semibold, design: .default))
                        }.padding()
                    }
                }
            }
        }
    }
}

#Preview {
    SelectOrNewPersonView(peopleViewModel: PeopleViewModel(), recordViewModel: RecordViewModel())
}
