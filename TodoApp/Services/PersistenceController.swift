import Foundation

struct PersistenceController {
    static let shared = PersistenceController()
    
    let container: NSPersistenceContainer
    
    init() {
        container = NSPersistenceContainer(name: "TodoApp")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Core Data error: \(error.localizedDescription)")
            }
        }
    }
}

extension PersistenceController {
    static var preview: PersistenceController = {
        let controller = PersistenceController()
        return controller
    }()
}