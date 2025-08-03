import SwiftUI

struct InputView: View {
    @State private var inputText = ""
    @FocusState private var isTextFieldFocused: Bool
    
    let onSendMessage: (String) -> Void
    let isProcessing: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            textInput
            sendButton
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
    
    private var textInput: some View {
        TextField("Ask about your todos or add new ones...", text: $inputText, axis: .vertical)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .focused($isTextFieldFocused)
            .font(.body)
            .lineLimit(1...4)
            .onSubmit {
                sendMessage()
            }
            .disabled(isProcessing)
    }
    
    private var sendButton: some View {
        Button(action: sendMessage) {
            Group {
                if isProcessing {
                    ProgressView()
                        .scaleEffect(0.8)
                } else {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.title2)
                }
            }
        }
        .foregroundColor(canSend ? Color.theme.accent : Color.theme.textTertiary)
        .disabled(!canSend)
        .animation(.easeInOut(duration: 0.2), value: isProcessing)
    }
    
    private var canSend: Bool {
        !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isProcessing
    }
    
    private func sendMessage() {
        let message = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !message.isEmpty else { return }
        
        onSendMessage(message)
        inputText = ""
        isTextFieldFocused = false
    }
}