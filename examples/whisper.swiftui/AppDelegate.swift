import UIKit
import CoreData

class AppDelegate: UIResponder, UIApplicationDelegate {

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Model")
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                print("Unresolved error \(error), \(error.userInfo)")
                let coordinator = container.persistentStoreCoordinator
                if let storeURL = container.persistentStoreDescriptions.first?.url {
                    do {
                        try coordinator.destroyPersistentStore(at: storeURL, ofType: NSSQLiteStoreType, options: nil)
                    } catch {
                        // Handle the error
                    }
                }
            }
        }
//        container.loadPersistentStores { description, error in
//            if let error = error as NSError? {
//                fatalError("Unresolved error \(error), \(error.userInfo)")
//            } else {
//                print("Persistent store loaded: \(description)")
//            }
//        }
        return container
    }()

    func saveContext() {
        print("Got save Context");
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
