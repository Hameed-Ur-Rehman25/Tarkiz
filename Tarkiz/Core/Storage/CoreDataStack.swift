import CoreData
import Foundation

final class CoreDataStack {
    static let shared = CoreDataStack()
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "tarkiz")
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                Logger.shared.error("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                Logger.shared.error("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func clearAllData() throws {
        let entities = persistentContainer.managedObjectModel.entities
        for entity in entities {
            guard let name = entity.name else { continue }
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: name)
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            try persistentContainer.viewContext.execute(deleteRequest)
        }
        saveContext()
    }
}
