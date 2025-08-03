import SwiftUI

struct MainView: View {
    @StateObject private var conversationManager = ConversationManager()
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.theme.background
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    headerView
                    
                    // Main content area
                    HStack(spacing: 0) {
                        // Conversation area (left side)
                        conversationArea
                            .frame(width: geometry.size.width * 0.6)
                        
                        Divider()
                            .background(Color.theme.surfaceSecondary)
                        
                        // Todo list area (right side)
                        todoArea
                            .frame(width: geometry.size.width * 0.4)
                    }
                    .frame(maxHeight: .infinity)
                    
                    // Input area at bottom
                    inputArea
                }
            }
        }
        .frame(minWidth: 800, minHeight: 600)
    }
    
    private var headerView: some View {
        HStack {
            Text("Todo Assistant")
                .font(.title2)
                .fontWeight(.medium)
                .foregroundColor(Color.theme.textPrimary)
            
            Spacer()
            
            Text("Ready to help organize your day")
                .font(.caption)
                .foregroundColor(Color.theme.textSecondary)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
        .background(Color.theme.surface)
    }
    
    private var conversationArea: some View {
        VStack {
            ConversationView(messages: conversationManager.messages)
        }
        .background(Color.theme.background)
    }
    
    private var todoArea: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Current Todos")
                .font(.headline)
                .foregroundColor(Color.theme.textPrimary)
                .padding(.horizontal, 16)
                .padding(.top, 16)
            
            TodoListView(todos: conversationManager.todos)
            
            Spacer()
        }
        .background(Color.theme.surface)
    }
    
    private var inputArea: some View {
        InputView(
            onSendMessage: conversationManager.sendMessage,
            isProcessing: conversationManager.isProcessing
        )
        .background(Color.theme.surfaceSecondary)
    }
}