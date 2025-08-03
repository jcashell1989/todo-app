import Foundation

class PersistenceManager {
    private let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    
    private var messagesURL: URL {
        documentsDirectory.appendingPathComponent("messages.json")
    }
    
    private var todosURL: URL {
        documentsDirectory.appendingPathComponent("todos.json")
    }
    
    func saveMessages(_ messages: [Message]) {
        do {
            let data = try JSONEncoder().encode(messages)
            try data.write(to: messagesURL)
        } catch {
            print("Failed to save messages: \(error)")
        }
    }
    
    func loadMessages() -> [Message] {
        do {
            let data = try Data(contentsOf: messagesURL)
            return try JSONDecoder().decode([Message].self, from: data)
        } catch {
            print("Failed to load messages: \(error)")
            return []
        }
    }
    
    func saveTodos(_ todos: [Todo]) {
        do {
            let data = try JSONEncoder().encode(todos)
            try data.write(to: todosURL)
        } catch {
            print("Failed to save todos: \(error)")
        }
    }
    
    func loadTodos() -> [Todo] {
        do {
            let data = try Data(contentsOf: todosURL)
            return try JSONDecoder().decode([Todo].self, from: data)
        } catch {
            print("Failed to load todos: \(error)")
            return []
        }
    }
    
    func clearAllData() {
        try? FileManager.default.removeItem(at: messagesURL)
        try? FileManager.default.removeItem(at: todosURL)
    }
}