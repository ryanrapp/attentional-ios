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
            sortDescriptors: [NSSortDescriptor(keyPath: \AvRecord.createdDate, ascending: false)],
            animation: .default)
    private var items: FetchedResults<AvRecord>
    
    @State private var selection: AvRecord? = nil
    
    private var images = ["Coffee", "Dog", "Casio", "Makeup", "Carnival"]
    
    var body: some View {
        
        List {
            Section(header: customHeader()) {
                ForEach(Array(zip(items.indices, items)), id: \.1) { index, item in
                    let title = item.memorySummary?.title != nil ? item.memorySummary?.title : item.title;
                    let duration = getDuration(record: item)
                    
                    VStack() {
                        
                        HStack(spacing: 10) {
                            VStack(alignment: .leading, spacing: 0) {
                                HStack(alignment: .top) {
                                    Image(images[index % images.count]) // Reference the image from your assets
                                        .resizable() // Make the image resizable
                                        .scaledToFit() // Scale the image to fit its frame
                                        .frame(maxWidth: 60, maxHeight: 60) // Set the frame of the image
                                        .cornerRadius(4)
                                }
                                Spacer()
                            }
                            VStack(alignment: .leading, spacing: 6) {
                                HStack(alignment: .top) {
                                    Text(title ?? "Untitled")
                                        .font(.cardTitleFont(ofSize: 16))
                                        .lineLimit(1)
                                        .frame(height: 20, alignment: .topLeading)
                                    
                                }
                                HStack(alignment: .top) {
                                    Text(item.memorySummary?.summary ?? "")
                                        .font(.cardSubTitleFont(ofSize: 14))
                                        .lineLimit(2)
                                        .frame(height: 34, alignment: .topLeading)
                                }
                                Spacer()
                                HStack(alignment: .bottom, spacing: 4) {
                                    
//                                    Image(systemName: "thermometer.medium").foregroundColor(Theme.Color.gray400)
//
//                                    Text(item.memorySummary?.sentiment ?? "")
//                                        .font(.cardSubTitleFont(ofSize: 16))// Duration
//                                        .lineLimit(1)
//                                        .frame(maxHeight: .infinity, alignment: .bottomLeading)
//
                                    
                                    
                                    Image(systemName: "clock").foregroundColor(Theme.Color.gray400)
                                    
                                    Text(formatMinutes(floatValue: duration))
                                        .font(.cardSubTitleFont(ofSize: 16))// Duration
                                        .lineLimit(1)
                                        .frame(maxHeight: .infinity, alignment: .bottomLeading)
                                    
                                    Spacer()
                                    
                                    
                                    Image(systemName: "calendar").foregroundColor(Theme.Color.gray400)
                                    
                                    Text(formatDate(date: item.createdDate ?? Date()))
                                        .font(.cardSubTitleFont(ofSize: 16))// Duration
                                        .lineLimit(1)
                                        .frame(maxHeight: .infinity, alignment: .bottomLeading)
                                    
                                    Spacer()
                                }
                            }
                        }
                        .padding(.horizontal, 0)
                        .padding(.vertical, 10)
                        .frame(maxWidth: .infinity, minHeight: 0, idealHeight: 100, maxHeight: .infinity)
                        .overlay(
                            Menu{
                                Button("View", action: { self.selection = item })
                                Button("Edit", action: {editAvRecord(item: item)})
                                Button("Delete", action: {
                                    deleteAvRecord(item: item)
                                })
                                Button("Cancel", action: cancelAction)
                            } label: {
                                Label("", systemImage: "ellipsis")
                                    .foregroundColor(Theme.Color.gray600)
                            } primaryAction: {
                                openMenu()
                            }
                                .padding(.bottom, 8)
                                .padding(.trailing, 0)
                                .background(Color.clear)
                            , alignment: .bottomTrailing)
                        
                        Spacer()
                        Divider().frame(maxWidth: .infinity).padding(.horizontal, -1)
                    }
                    
                    .onTapGesture {
                        // Handle the tap here. For example, you can set 'selection' to this 'item'
                        self.selection = item
                    }
                    //.listRowInsets(EdgeInsets()) // Remove default padding to align image to the edge
                    
                }.frame(maxWidth: .infinity)
                    .listRowSeparator(.hidden)
                    .padding(.horizontal, -5)
            }
        }.listStyle(PlainListStyle()) // Apply plain list style
         
         .sheet(
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
    
    private func formatDate(date: Date) -> String {
        let dateFormatter = DateFormatter()
        let calendar = Calendar.current
        let dayComponent = calendar.component(.day, from: date)
        
        // Format for month
        dateFormatter.dateFormat = "MMM" // e.g., Jan, Feb, Mar
        let month = dateFormatter.string(from: date)
        
        // Function to determine the ordinal suffix
        func ordinalSuffix(for day: Int) -> String {
            switch day {
                case 1, 21, 31: return "st"
                case 2, 22: return "nd"
                case 3, 23: return "rd"
                default: return "th"
            }
        }

        return "\(month) \(dayComponent)\(ordinalSuffix(for: dayComponent))"
    }
    
    private func sortedRows(for record: AvRecord) -> [AvRecordRow] {
        // Sort the rows in the desired order. Replace 'someSortProperty' and 'ascending' with your criteria.
        let sortedRows = record.rows?.sorted {
            ($0 as! AvRecordRow).t1 > ($1 as! AvRecordRow).t1
        }
        return sortedRows as! [AvRecordRow]
    }
    
    private func getDuration(record: AvRecord) -> Float {
        let rows = sortedRows(for: record)
        return Float(rows.first?.t1 ?? 0) / Float(60 * 100)
    }
    
    private func customHeader() -> some View {
        HStack {
            Text("Memories".capitalized)
                .font(.heading1Font(ofSize: 28))
                .foregroundColor(.black) // Set the color as needed
                .textCase(nil)
                .font(.system(size: 24, weight: .bold, design: .default))
                .padding(.leading, 20)
                .padding(.vertical, 10)
            Spacer()
        }
        .listRowInsets(EdgeInsets()) // Remove default padding
    }
}

#Preview {
    ListView()
}
