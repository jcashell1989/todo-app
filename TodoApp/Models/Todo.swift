import Foundation

struct Todo: Identifiable, Codable {
    let id = UUID()
    var title: String
    var description: String?
    var priority: TodoPriority
    var status: TodoStatus
    var createdDate: Date
    var dueDate: Date?
    var completedDate: Date?
    
    init(title: String, description: String? = nil, priority: TodoPriority = .medium, dueDate: Date? = nil) {
        self.title = title
        self.description = description
        self.priority = priority
        self.status = .pending
        self.createdDate = Date()
        self.dueDate = dueDate
    }
    
    mutating func markCompleted() {
        status = .completed
        completedDate = Date()
    }
    
    mutating func markInProgress() {
        status = .inProgress
        completedDate = nil
    }
    
    mutating func markPending() {
        status = .pending
        completedDate = nil
    }
}

enum TodoPriority: String, Codable, CaseIterable {
    case low = "low"
    case medium = "medium"
    case high = "high"
    case urgent = "urgent"
    
    var displayName: String {
        switch self {
        case .low: return "Low"
        case .medium: return "Medium"
        case .high: return "High"
        case .urgent: return "Urgent"
        }
    }
    
    var sortOrder: Int {
        switch self {
        case .low: return 1
        case .medium: return 2
        case .high: return 3
        case .urgent: return 4
        }
    }
}

enum TodoStatus: String, Codable, CaseIterable {
    case pending = "pending"
    case inProgress = "in_progress"
    case completed = "completed"
    
    var displayName: String {
        switch self {
        case .pending: return "Pending"
        case .inProgress: return "In Progress"
        case .completed: return "Completed"
        }
    }
}