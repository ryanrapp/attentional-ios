//
//  ListView.swift
//  attentional.swiftui
//
//  Created by Ryan Rapp on 12/31/23.
//

import SwiftUI
import CoreData
import Foundation
import TailwindCSS_SwiftUI

//struct ListItem: Identifiable {
//    let id = UUID()
//    let title: String
//    let snippet: String
//    let iconName: String
//    let duration: String
//    }

struct ListView: View {
    @EnvironmentObject var actionHandler: ActionHandler
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
            sortDescriptors: [NSSortDescriptor(keyPath: \AvRecord.title, ascending: true)],
            animation: .default)
    private var items: FetchedResults<AvRecord>
    
    @State private var selection: AvRecord? = nil
    
    
    // Sample data
//    let items: [ListItem] = [
//        ListItem(title: "Discussion with Tom", snippet: "Preparing Q2 projections", iconName: "waveform.circle.fill", duration: "5 min"),
//        ListItem(title: "New quarter", snippet: "Roadmap discussion", iconName: "heart.fill", duration: "10 min")
//        // Add more items
//    ]
    
    private func customHeader() -> some View {
        HStack {
            Text("Memories".capitalized)
                .foregroundColor(.black) // Set the color as needed
                .textCase(nil)
                .font(.system(size: 24, weight: .bold, design: .default))
                .padding(.leading, 0)
                .padding(.vertical, 10)
            Spacer()
        }
        .listRowInsets(EdgeInsets()) // Remove default padding
    }
    
    private var images = ["Coffee", "Dog", "Casio", "Makeup", "Carnival"]
    
    var body: some View {
        List {
            Section(header: customHeader()
                
            ) {
                ForEach(Array(zip(items.indices, items)), id: \.1) { index, item in
                    HStack() {
//                        Image(systemName: item.iconName ?? "questionmark").padding(.trailing, 3) // Icon
                        Image(images[index % images.count]) // Reference the image from your assets
                            .resizable() // Make the image resizable
                            .scaledToFit() // Scale the image to fit its frame
                            .frame(width: 80, height: 80) // Set the frame of the image
                            .padding(0)
                        
                        VStack(alignment: .leading) {
                            Text(item.title ?? "").fontWeight(.bold) // Title
                            Text(formatMinutes(floatValue: item.durationInMinutes)) // Duration
//                            Text(item.snippet ?? "").font(.subheadline) // Text snippet
                        }
                        Spacer()
                        
                        Menu{
                            Button("View", action: { self.selection = item })
                            Button("Edit", action: {editAvRecord(item: item)})
                            Button("Delete", action: {
                                deleteAvRecord(item: item)
                            })
                            Button("Cancel", action: cancelAction)
                        } label: {
                            Label("", systemImage: "ellipsis")
                        } primaryAction: {
                            openMenu()
                        }
                    }.onTapGesture {
                        // Handle the tap here. For example, you can set 'selection' to this 'item'
                        self.selection = item
                    }.listRowInsets(EdgeInsets()) // Remove default padding to align image to the edge
                        
                }
            }
        }.sheet(
            item: $selection,
                onDismiss: {
                    do { 
                        try viewContext.save()
                    } catch {
                        print("Could not save the object on close: \(error)")
                    }
                },
                content: { selectedItem in EditAvRecordView(record: selectedItem).environment(\.managedObjectContext, self.viewContext)
         }).onAppear {
             // Log the state of the managed object context
             print("Managed Object Context: \(viewContext)")

             // Log if the context is connected to a persistent store
             if let coordinator = viewContext.persistentStoreCoordinator {
                 print("Persistent Store Coordinator is available.")
                 print("Persistent Stores: \(coordinator.persistentStores)")
             } else {
                 print("No Persistent Store Coordinator found.")
             }

             // Log the state of the fetch request
             print("Number of items fetched: \(items.count)")
 
             actionHandler.action = {
                 print("Creating new placeholder")
                 self.selection = newAvRecord()
             }
         }
    }
    
    func openMenu() {
        print("Button was tapped")
    }
    func newAvRecord()-> AvRecord {
        let newObject = AvRecord(context: viewContext)
        newObject.id = UUID()
        newObject.title = createPlaceholderName()
        newObject.snippet = ""
        newObject.iconName = "waveform.circle.fill"
        newObject.durationInMinutes = 0
        newObject.createdDate = Date()

        do {
            try viewContext.save()
        } catch {
            print("Could not save the new object: \(error)")
        }
        return newObject
    }
    func editAvRecord(item: AvRecord) {
        print("Edit item", item)
        self.selection = item
    }
    func formatMinutes(floatValue: Float) -> String {
        let roundedValue = Int(floatValue.rounded())
        let formattedString = "\(roundedValue) min"
        return formattedString
    }
    func deleteAvRecord(item: AvRecord) {
        viewContext.delete(item)
        do {
            try viewContext.save()
        } catch {
            print("Error saving context after deletion: \(error)")
        }
    }
    func cancelAction() { }
    
    func createPlaceholderName() -> String {
        let formatter = DateFormatter()
        // Set the date format according to your needs
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let timestamp = formatter.string(from: Date())
        return "New \(timestamp)"
    }
    
}

#Preview {
    ListView()
}
