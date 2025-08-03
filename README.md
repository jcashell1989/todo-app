# Todo Assistant

A naturalistic todo app for macOS that uses Claude AI to help manage tasks through conversational interface.

## Features

- Natural language todo management
- Conversational interface with message history
- Calm, readable design with flowing message display
- Persistent storage for todos and conversations
- Priority-based todo organization
- Text input (voice input planned for future release)

## Setup

### Prerequisites

- macOS 13.0 or later
- Xcode 15.0 or later
- Claude API key from Anthropic

### Installation

1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd todo_app
   ```

2. Set your Claude API key as an environment variable:
   ```bash
   export CLAUDE_API_KEY="your-api-key-here"
   ```

3. Open the project in Xcode:
   ```bash
   open TodoApp.xcodeproj
   ```

4. Build and run the project in Xcode

### API Key Configuration

The app requires a Claude API key to function. You can obtain one from [Anthropic's website](https://console.anthropic.com/).

Set the API key as an environment variable:
- In Xcode: Product → Scheme → Edit Scheme → Run → Environment Variables
- Add `CLAUDE_API_KEY` with your key value

## Usage

1. Launch the app
2. Type natural language requests like:
   - "Add a todo to call mom tomorrow"
   - "What should I prioritize today?"
   - "Mark the grocery shopping as completed"
   - "Show me my high priority tasks"

## Architecture

- **SwiftUI** for native macOS interface
- **Claude API** for natural language processing
- **JSON persistence** for local data storage
- **MVVM pattern** with SwiftUI and ObservableObject

## Project Structure

```
TodoApp/
├── Models/           # Data models (Todo, Message)
├── Views/            # SwiftUI views and components
├── Services/         # API and persistence services
├── Managers/         # Business logic coordinators
└── Theme/            # Color scheme and styling
```

## Development

The app follows the development guidelines in `CLAUDE.md`. Key points:

- Ask 2-3 questions after each implementation
- Use git and GitHub for version control
- Maintain calm, readable design
- Focus on natural language interaction