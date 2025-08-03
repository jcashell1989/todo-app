import Foundation

struct AIResponse {
    let message: String
    let todoUpdates: [TodoUpdate]?
}

struct TodoUpdate {
    let action: TodoAction
    let todoId: String?
    let title: String?
    let description: String?
    let priority: TodoPriority?
    let dueDate: Date?
}

enum TodoAction: String, Codable {
    case add = "add"
    case update = "update"
    case complete = "complete"
    case delete = "delete"
}

class AIService {
    private let apiKey: String
    private let baseURL = "https://api.anthropic.com/v1/messages"
    private let dateParser = DateParser()
    
    init() {
        self.apiKey = ProcessInfo.processInfo.environment["CLAUDE_API_KEY"] ?? ""
        if apiKey.isEmpty {
            print("Warning: CLAUDE_API_KEY environment variable not set")
        }
    }
    
    func processMessage(_ message: String, currentTodos: [Todo]) async throws -> AIResponse {
        guard !apiKey.isEmpty else {
            throw AIServiceError.noAPIKey
        }
        
        let enhancedMessage = enhanceMessageWithDateParsing(message)
        let systemPrompt = createSystemPrompt(with: currentTodos)
        let requestBody = createRequestBody(systemPrompt: systemPrompt, userMessage: enhancedMessage)
        
        let response = try await makeAPIRequest(body: requestBody)
        return try parseResponse(response)
    }
    
    private func enhanceMessageWithDateParsing(_ message: String) -> String {
        let datePhrases = dateParser.extractDatePhrases(from: message)
        
        if datePhrases.isEmpty {
            return message
        }
        
        var enhancedMessage = message
        var dateContext = "\n\nDetected date references:"
        
        for phrase in datePhrases {
            if let parsedDate = dateParser.parseNaturalLanguageDate(from: phrase) {
                let formatter = ISO8601DateFormatter()
                let isoDate = formatter.string(from: parsedDate)
                dateContext += "\n- '\(phrase)' = \(isoDate)"
            }
        }
        
        return enhancedMessage + dateContext
    }
    
    private func createSystemPrompt(with todos: [Todo]) -> String {
        let todosJson = todosToJSON(todos)
        
        return """
        You are a helpful todo assistant. You help users manage their todos through natural conversation.
        
        Current todos (JSON format):
        \(todosJson)
        
        When responding:
        1. Be conversational and helpful
        2. If the user wants to add, update, or complete todos, include the appropriate JSON structure
        3. Always respond with plain text followed by JSON if todo updates are needed
        4. For todo updates, use this exact format:
        
        RESPONSE_TEXT
        
        TODO_UPDATES:
        {
            "updates": [
                {
                    "action": "add|update|complete|delete",
                    "todoId": "uuid-string-if-updating-existing",
                    "title": "todo title",
                    "description": "optional description",
                    "priority": "low|medium|high|urgent",
                    "dueDate": "ISO8601 date string if applicable"
                }
            ]
        }
        
        Keep responses natural and conversational. Help prioritize and organize tasks thoughtfully.
        """
    }
    
    private func todosToJSON(_ todos: [Todo]) -> String {
        do {
            let data = try JSONEncoder().encode(todos)
            return String(data: data, encoding: .utf8) ?? "[]"
        } catch {
            return "[]"
        }
    }
    
    private func createRequestBody(systemPrompt: String, userMessage: String) -> [String: Any] {
        return [
            "model": "claude-3-sonnet-20240229",
            "max_tokens": 1000,
            "messages": [
                [
                    "role": "user",
                    "content": userMessage
                ]
            ],
            "system": systemPrompt
        ]
    }
    
    private func makeAPIRequest(body: [String: Any]) async throws -> [String: Any] {
        guard let url = URL(string: baseURL) else {
            throw AIServiceError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            throw AIServiceError.encodingError
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AIServiceError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            throw AIServiceError.apiError(httpResponse.statusCode)
        }
        
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw AIServiceError.invalidResponse
        }
        
        return json
    }
    
    private func parseResponse(_ json: [String: Any]) throws -> AIResponse {
        guard let content = json["content"] as? [[String: Any]],
              let firstContent = content.first,
              let text = firstContent["text"] as? String else {
            throw AIServiceError.invalidResponse
        }
        
        let (responseText, todoUpdates) = extractTodoUpdates(from: text)
        
        return AIResponse(
            message: responseText.trimmingCharacters(in: .whitespacesAndNewlines),
            todoUpdates: todoUpdates
        )
    }
    
    private func extractTodoUpdates(from text: String) -> (String, [TodoUpdate]?) {
        let components = text.components(separatedBy: "TODO_UPDATES:")
        
        guard components.count == 2 else {
            return (text, nil)
        }
        
        let responseText = components[0].trimmingCharacters(in: .whitespacesAndNewlines)
        let jsonText = components[1].trimmingCharacters(in: .whitespacesAndNewlines)
        
        do {
            guard let jsonData = jsonText.data(using: .utf8),
                  let json = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any],
                  let updatesArray = json["updates"] as? [[String: Any]] else {
                return (responseText, nil)
            }
            
            let updates = try updatesArray.compactMap { updateDict -> TodoUpdate? in
                guard let actionString = updateDict["action"] as? String,
                      let action = TodoAction(rawValue: actionString) else {
                    return nil
                }
                
                let todoId = updateDict["todoId"] as? String
                let title = updateDict["title"] as? String
                let description = updateDict["description"] as? String
                let priorityString = updateDict["priority"] as? String
                let priority = priorityString != nil ? TodoPriority(rawValue: priorityString!) : nil
                
                var dueDate: Date?
                if let dateString = updateDict["dueDate"] as? String {
                    let formatter = ISO8601DateFormatter()
                    dueDate = formatter.date(from: dateString)
                }
                
                return TodoUpdate(
                    action: action,
                    todoId: todoId,
                    title: title,
                    description: description,
                    priority: priority,
                    dueDate: dueDate
                )
            }
            
            return (responseText, updates.isEmpty ? nil : updates)
            
        } catch {
            return (responseText, nil)
        }
    }
}

enum AIServiceError: Error, LocalizedError {
    case noAPIKey
    case invalidURL
    case encodingError
    case invalidResponse
    case apiError(Int)
    
    var errorDescription: String? {
        switch self {
        case .noAPIKey:
            return "Claude API key not configured"
        case .invalidURL:
            return "Invalid API URL"
        case .encodingError:
            return "Failed to encode request"
        case .invalidResponse:
            return "Invalid API response"
        case .apiError(let code):
            return "API error with status code: \(code)"
        }
    }
}