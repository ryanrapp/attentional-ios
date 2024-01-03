//
//  RecordViewModel.swift
//  attentional.swiftui
//
//  Created by Ryan Rapp on 1/2/24.
//


class RecordViewModel: ObservableObject {
    @Published var sortedRows: [AvRecordRow] = []

    let record: AvRecord
    let viewContext: NSManagedObjectContext

    init(record: AvRecord, context: NSManagedObjectContext) {
        self.record = record
        self.viewContext = context
        loadSortedRows()
    }

    func loadSortedRows() {
        let fetchRequest: NSFetchRequest<AvRecordRow> = AvRecordRow.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "t0", ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "parent == %@", record)

        do {
            sortedRows = try viewContext.fetch(fetchRequest)
        } catch {
            print("Error fetching sorted AvRecordRows: \(error)")
        }
    }
}
