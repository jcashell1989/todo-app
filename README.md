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

### Quick Start

1. Clone the repository:
   ```bash
   git clone https://github.com/jcashell1989/todo-app.git
   cd todo-app
   ```

2. Run the setup script to configure your API key:
   ```bash
   ./setup_env.sh
   ```

3. Launch the app:
   ```bash
   ./launch.sh
   ```

### Manual Setup

If you prefer to set up manually:

1. Get your Claude API key from [Anthropic's Console](https://console.anthropic.com/)

2. Set the environment variable:
   ```bash
   export CLAUDE_API_KEY="your-api-key-here"
   # Or add to your shell profile:
   echo 'export CLAUDE_API_KEY="your-key"' >> ~/.zshrc
   ```

3. Open in Xcode:
   ```bash
   open TodoApp.xcodeproj
   ```

4. In Xcode, you can also set the API key in:
   Product → Scheme → Edit Scheme → Run → Environment Variables

### API Key Configuration

The app requires a Claude API key to function. You can obtain one from [Anthropic's website](https://console.anthropic.com/).

Set the API key as an environment variable:
- In Xcode: Product → Scheme → Edit Scheme → Run → Environment Variables
- Add `CLAUDE_API_KEY` with your key value

## Usage

1. Launch the app using `./launch.sh` or open `TodoApp.xcodeproj` in Xcode
2. Type natural language requests like:
   - "Add a todo to call mom tomorrow"
   - "Remind me to buy groceries next Friday"
   - "What should I prioritize today?"
   - "Mark the grocery shopping as completed"
   - "Show me my high priority tasks"
   - "I need to finish the report by next week"

### Natural Language Date Support

The app understands various date formats:
- **Relative**: "tomorrow", "next week", "in 3 days"
- **Days of week**: "monday", "next friday", "this saturday"
- **Specific dates**: "12/25", "2024-03-15", "March 1st"
- **Natural phrases**: "end of the week", "next month"

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