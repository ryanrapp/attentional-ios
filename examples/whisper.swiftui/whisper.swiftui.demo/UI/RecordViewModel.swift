//
//  RecordViewModel.swift
//  attentional.swiftui
//
//  Created by Ryan Rapp on 1/2/24.
//
import SwiftUI
import CoreData
import OpenAI

class RecordViewModel: ObservableObject {
    @Published var sortedRows: [AvRecordRow] = []
    @Published var durationInMinutes: Float = 0

    private var record: AvRecord?
    private var viewContext: NSManagedObjectContext?

    init(record: AvRecord? = nil, context: NSManagedObjectContext? = nil) {
        self.record = record
        self.viewContext = context
        loadSortedRows()
        
    }

    private func loadSortedRows() {
        guard let viewContext = viewContext, let record = record else { return }

        let fetchRequest: NSFetchRequest<AvRecordRow> = AvRecordRow.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "t0", ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "parent == %@", record)

        do {
            sortedRows = try viewContext.fetch(fetchRequest)
        } catch {
            print("Error fetching sorted AvRecordRows: \(error)")
        }
        var transcriptionDuration = 0
        for row in sortedRows {
            transcriptionDuration = max(Int(row.t1), transcriptionDuration)
        }
        durationInMinutes = Float(transcriptionDuration) / Float(60 * 100);
    }

    func updateContextAndRecord(context: NSManagedObjectContext, record: AvRecord) {
        self.viewContext = context
        self.record = record
        loadSortedRows()
    }
    
    func summarize(context: NSManagedObjectContext, record: AvRecord, apiKey: String) async {
        // Make sure the rows are up to date
        updateContextAndRecord(context: context, record: record)
//        let openAI = OpenAI(apiToken: apiKey)
//        
//        openAI.completionsStream(query: query) { partialResult in
//            switch partialResult {
//            case .success(let result):
//                print(result.choices)
//                break
//            case .failure(let error):
//                
//                break
//                //Handle chunk error here
//            }
//        } completion: { error in
//            //Handle streaming error here
//        }
        
    }
}
