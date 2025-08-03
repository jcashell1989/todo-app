import SwiftUI

struct TodoListView: View {
    let todos: [Todo]
    
    private var sortedTodos: [Todo] {
        todos.sorted { todo1, todo2 in
            if todo1.status != todo2.status {
                return todo1.status.rawValue < todo2.status.rawValue
            }
            if todo1.priority != todo2.priority {
                return todo1.priority.sortOrder > todo2.priority.sortOrder
            }
            return todo1.createdDate < todo2.createdDate
        }
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                ForEach(sortedTodos) { todo in
                    TodoItemView(todo: todo)
                }
                
                if todos.isEmpty {
                    emptyStateView
                }
            }
            .padding(.horizontal, 16)
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "checkmark.circle")
                .font(.system(size: 48))
                .foregroundColor(Color.theme.textTertiary)
            
            Text("No todos yet")
                .font(.headline)
                .foregroundColor(Color.theme.textSecondary)
            
            Text("Start a conversation to add your first todo")
                .font(.subheadline)
                .foregroundColor(Color.theme.textTertiary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 40)
    }
}

struct TodoItemView: View {
    let todo: Todo
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                statusIndicator
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(todo.title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(Color.theme.textPrimary)
                        .strikethrough(todo.status == .completed)
                    
                    if let description = todo.description, !description.isEmpty {
                        Text(description)
                            .font(.caption)
                            .foregroundColor(Color.theme.textSecondary)
                            .lineLimit(2)
                    }
                }
                
                Spacer()
                
                priorityBadge
            }
            
            if let dueDate = todo.dueDate {
                HStack {
                    Image(systemName: "calendar")
                        .foregroundColor(Color.theme.textTertiary)
                        .font(.caption)
                    
                    Text(dueDate, style: .date)
                        .font(.caption)
                        .foregroundColor(Color.theme.textTertiary)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color.theme.surface)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(borderColor, lineWidth: 1)
        )
    }
    
    private var statusIndicator: some View {
        Circle()
            .fill(statusColor)
            .frame(width: 12, height: 12)
    }
    
    private var statusColor: Color {
        switch todo.status {
        case .pending:
            return Color.theme.textTertiary
        case .inProgress:
            return Color.theme.accent
        case .completed:
            return Color.theme.success
        }
    }
    
    private var borderColor: Color {
        switch todo.priority {
        case .urgent:
            return Color.theme.error
        case .high:
            return Color.theme.warning
        default:
            return Color.theme.surfaceSecondary
        }
    }
    
    private var priorityBadge: some View {
        Text(todo.priority.displayName)
            .font(.caption2)
            .fontWeight(.medium)
            .foregroundColor(priorityTextColor)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(priorityBackgroundColor)
            .cornerRadius(4)
    }
    
    private var priorityTextColor: Color {
        switch todo.priority {
        case .urgent:
            return .white
        case .high:
            return .white
        default:
            return Color.theme.textSecondary
        }
    }
    
    private var priorityBackgroundColor: Color {
        switch todo.priority {
        case .urgent:
            return Color.theme.error
        case .high:
            return Color.theme.warning
        case .medium:
            return Color.theme.accentLight
        case .low:
            return Color.theme.surfaceSecondary
        }
    }
}