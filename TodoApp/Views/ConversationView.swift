import SwiftUI

struct ConversationView: View {
    let messages: [Message]
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(Array(messages.enumerated()), id: \.element.id) { index, message in
                        MessageBubble(
                            message: message,
                            opacity: messageOpacity(for: index)
                        )
                        .id(message.id)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            }
            .onChange(of: messages.count) { _ in
                if let lastMessage = messages.last {
                    withAnimation(.easeOut(duration: 0.3)) {
                        proxy.scrollTo(lastMessage.id, anchor: .bottom)
                    }
                }
            }
        }
    }
    
    private func messageOpacity(for index: Int) -> Double {
        let totalMessages = messages.count
        let fadeThreshold = max(totalMessages - 10, 0)
        
        if index < fadeThreshold {
            let fadeAmount = Double(fadeThreshold - index) / 10.0
            return max(0.3, 1.0 - fadeAmount)
        }
        
        return 1.0
    }
}

struct MessageBubble: View {
    let message: Message
    let opacity: Double
    
    var body: some View {
        HStack {
            if message.sender == .user {
                Spacer(minLength: 60)
            }
            
            VStack(alignment: message.sender == .user ? .trailing : .leading, spacing: 4) {
                HStack {
                    if message.sender != .user {
                        senderIcon
                    }
                    
                    Text(message.content)
                        .font(.body)
                        .foregroundColor(Color.theme.textPrimary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(backgroundColor)
                        .cornerRadius(16)
                        .animation(.spring(response: 0.3), value: message.content)
                    
                    if message.sender == .user {
                        senderIcon
                    }
                }
                
                Text(message.timestamp, style: .time)
                    .font(.caption2)
                    .foregroundColor(Color.theme.textTertiary)
                    .padding(.horizontal, 8)
            }
            
            if message.sender != .user {
                Spacer(minLength: 60)
            }
        }
        .opacity(opacity)
        .animation(.easeInOut(duration: 0.2), value: opacity)
    }
    
    private var backgroundColor: Color {
        switch message.sender {
        case .user:
            return Color.theme.userMessage
        case .assistant:
            return Color.theme.aiMessage
        case .system:
            return Color.theme.surfaceSecondary
        }
    }
    
    private var senderIcon: some View {
        Circle()
            .fill(message.sender == .user ? Color.theme.accent : Color.theme.accentLight)
            .frame(width: 32, height: 32)
            .overlay(
                Text(message.sender == .user ? "U" : "AI")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
            )
    }
}