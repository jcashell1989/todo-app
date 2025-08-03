# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a naturalistic to-do app for macOS desktop that integrates conversational AI to help users manage tasks. The app emphasizes calm, readable design with persistent memory and natural language interaction.

## Core Requirements

**Interface Design:**
- GUI application for macOS desktop
- Calm design with large, readable text
- Messages flow upward and fade into scrollable history
- Support for both voice and text input
- Display conversation inputs and AI responses

**Functionality:**
- Natural language task prioritization assistance
- Persistent storage for multi-day todo management
- Conversational interface showing both user input and app responses

## Development Commands

**Quick Setup:**
```bash
./setup_env.sh    # Configure Claude API key
./launch.sh       # Launch app in Xcode
```

**Manual Commands:**
```bash
open TodoApp.xcodeproj                           # Open in Xcode
xcodebuild -project TodoApp.xcodeproj -scheme TodoApp build  # Build from CLI
```

**Development Process:**
- Ask 2-3 clarifying questions after each implementation prompt
- Use git and GitHub (`gh`) for version control
- Focus on naturalistic language processing for task management
- Test natural language date parsing with phrases like "tomorrow", "next Friday", "in 3 days"

## Current Architecture

**Technology Stack:**
- SwiftUI for native macOS interface
- Claude API for natural language processing
- JSON-based persistence for local data storage
- MVVM pattern with SwiftUI and ObservableObject

**Key Components:**
- `ConversationManager`: Handles chat flow and todo operations
- `AIService`: Claude API integration with natural language date parsing
- `DateParser`: Parses relative dates ("tomorrow", "next week", etc.)
- `PersistenceManager`: JSON file storage for todos and messages
- Calm color theme with light blues and greys

**Project Structure:**
```
TodoApp/
├── Models/           # Todo and Message data structures
├── Views/           # SwiftUI views (MainView, ConversationView, etc.)
├── Services/        # AIService, DateParser, PersistenceManager
├── Managers/        # ConversationManager business logic
└── Theme/           # Color scheme and styling
```

The app emphasizes natural conversation flow with persistent memory and intelligent date recognition.