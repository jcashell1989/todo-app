import Foundation
import SwiftUI

@MainActor
class ConversationManager: ObservableObject {
    @Published var messages: [Message] = []
    @Published var todos: [Todo] = []
    @Published var isProcessing = false
    
    private let aiService = AIService()
    private let persistenceManager = PersistenceManager()
    
    init() {
        loadPersistedData()
        addWelcomeMessage()
    }
    
    func sendMessage(_ content: String) {
        let userMessage = Message(content: content, sender: .user)
        messages.append(userMessage)
        
        Task {
            await processUserMessage(content)
        }
    }
    
    private func processUserMessage(_ content: String) async {
        isProcessing = true
        
        do {
            let response = try await aiService.processMessage(content, currentTodos: todos)
            
            if let todoUpdates = response.todoUpdates {
                applyTodoUpdates(todoUpdates)
            }
            
            let assistantMessage = Message(
                content: response.message,
                sender: .assistant
            )
            messages.append(assistantMessage)
            
            saveData()
            
        } catch {
            let errorMessage = Message(
                content: "I'm having trouble processing that right now. Please try again.",
                sender: .assistant,
                messageType: .error
            )
            messages.append(errorMessage)
        }
        
        isProcessing = false
    }
    
    private func applyTodoUpdates(_ updates: [TodoUpdate]) {
        for update in updates {
            switch update.action {
            case .add:
                let newTodo = Todo(
                    title: update.title,
                    description: update.description,
                    priority: update.priority ?? .medium,
                    dueDate: update.dueDate
                )
                todos.append(newTodo)
                
            case .complete:
                if let index = todos.firstIndex(where: { $0.id.uuidString == update.todoId }) {
                    todos[index].markCompleted()
                }
                
            case .update:
                if let index = todos.firstIndex(where: { $0.id.uuidString == update.todoId }) {
                    if let title = update.title {
                        todos[index].title = title
                    }
                    if let description = update.description {
                        todos[index].description = description
                    }
                    if let priority = update.priority {
                        todos[index].priority = priority
                    }
                    if let dueDate = update.dueDate {
                        todos[index].dueDate = dueDate
                    }
                }
                
            case .delete:
                todos.removeAll { $0.id.uuidString == update.todoId }
            }
        }
    }
    
    private func addWelcomeMessage() {
        let welcomeMessage = Message(
            content: "Hello! I'm here to help you manage your todos naturally. You can tell me what you need to do, ask me to prioritize tasks, or just have a conversation about your day.",
            sender: .assistant
        )
        messages.append(welcomeMessage)
    }
    
    private func loadPersistedData() {
        messages = persistenceManager.loadMessages()
        todos = persistenceManager.loadTodos()
    }
    
    private func saveData() {
        persistenceManager.saveMessages(messages)
        persistenceManager.saveTodos(todos)
    }
}