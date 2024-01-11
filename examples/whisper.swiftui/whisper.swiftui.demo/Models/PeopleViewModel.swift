//
//  PeopleViewModel.swift
//  attentional.swiftui
//
//  Created by Ryan Rapp on 1/11/24.
//

import Foundation
import CoreData
import SwiftUI
import Combine

class PeopleViewModel: ObservableObject {
    private var viewContext: NSManagedObjectContext?
    private var cancellables = Set<AnyCancellable>()
    
    @Published var showingPersonSelector = false
    @Published var selectedPerson: Person?
    @Published var selectingPersonRow: AvRecordRow? = nil
    @Published var newPersonName: String = ""
    @Published var people: [Person] = []
    
    init(viewContext: NSManagedObjectContext? = nil) {
        self.viewContext = viewContext
    }
    
    func updateContext(context: NSManagedObjectContext) {
        self.viewContext = context
        loadPeople()
    }
    
    func saveAddPerson() {
        guard let viewContext = viewContext else { return }
        do {
            try viewContext.save()
        } catch {
            print("Could not add new person: \(error)")
        }
    }
    
    func addPerson() -> Person? {
        guard let viewContext = viewContext else { return nil }
        
        loadPeople()
        
        if let found = people.filter({ person in
            return newPersonName == person.name
        }).first {
            selectingPersonRow?.speaker = found
            saveAddPerson()
            return found
        } else if newPersonName != "" {
            let newPerson = Person(context: viewContext)
            newPerson.name = newPersonName
            selectingPersonRow?.speaker = newPerson
            saveAddPerson()
            return newPerson
        } else {
            selectingPersonRow?.speaker = nil
            saveAddPerson()
            return nil
        }
    }
    
    private func loadPeople() {
        guard let viewContext = viewContext else { return }
        
        let request: NSFetchRequest<Person> = Person.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Person.name, ascending: true)]

        do {
            people = try viewContext.fetch(request)
        } catch {
            print("Error fetching people: \(error)")
        }
    }
}

extension PeopleViewModel {
    private func setUpContextObserver() {
        NotificationCenter.default.publisher(for: .NSManagedObjectContextObjectsDidChange, object: viewContext)
            .sink { [weak self] _ in
                self?.loadPeople()
            }
            .store(in: &cancellables)
    }
}
