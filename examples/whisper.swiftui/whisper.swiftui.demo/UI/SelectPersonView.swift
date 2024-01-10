//
//  SelectPersonView.swift
//  attentional.swiftui
//
//  Created by Ryan Rapp on 1/9/24.
//

import SwiftUI
import CoreData

struct SelectPersonView: View {
    @Binding var isPresented: Bool
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Person.name, ascending: true)],
        animation: .default)
    private var persons: FetchedResults<Person>

    @State private var searchText = ""

    var body: some View {
        NavigationView {
            List {
                ForEach(persons.filter { person in
                    self.searchText.isEmpty || person.name!.contains(self.searchText)
                }) { person in
                    Text(person.name ?? "")
                }
            }
            .searchable(text: $searchText)
            .navigationTitle("Select a Person")
            .toolbar {
                Button("Done") {
                    isPresented = false
                }
            }
        }
    }
}
