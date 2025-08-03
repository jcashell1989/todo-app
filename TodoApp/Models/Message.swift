import Foundation

struct Message: Identifiable, Codable {
    let id = UUID()
    let content: String
    let sender: MessageSender
    let timestamp: Date
    let messageType: MessageType
    
    init(content: String, sender: MessageSender, messageType: MessageType = .text) {
        self.content = content
        self.sender = sender
        self.messageType = messageType
        self.timestamp = Date()
    }
}

enum MessageSender: String, Codable, CaseIterable {
    case user = "user"
    case assistant = "assistant"
    case system = "system"
}

enum MessageType: String, Codable, CaseIterable {
    case text = "text"
    case todoUpdate = "todo_update"
    case error = "error"
}