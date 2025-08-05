# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a naturalistic to-do app that runs as a Python web application in the browser. It integrates conversational AI to help users manage tasks with a calm, cloud-themed interface and fading message history.

## Core Requirements

**Interface Design:**
- Single-page web application running locally in browser
- Cloud-themed design with soft blues, whites, and gradients
- Single chat window with messages that gradually fade as they move upward
- Natural language input for conversational task management
- Real-time chat interface with WebSocket connectivity

**Functionality:**
- Natural language task prioritization assistance via Claude API
- Persistent JSON-based storage for multi-day todo management
- Conversational interface with fading message history effect
- Natural language date parsing ("tomorrow", "next Friday", "in 3 days")

## Development Commands

**Quick Setup:**
```bash
export CLAUDE_API_KEY='your-api-key-here'  # Set Claude API key
pip install -r requirements.txt            # Install dependencies
python run.py                              # Launch app (opens browser automatically)
```

**Manual Commands:**
```bash
python app.py                              # Start Flask development server
python -m flask --app app run --debug     # Start with debug mode
```

**Development Process:**
- Ask 2-3 clarifying questions after each implementation prompt
- Use git and GitHub (`gh`) for version control
- Focus on naturalistic language processing for task management
- Test natural language date parsing with phrases like "tomorrow", "next Friday", "in 3 days"
- Debug todos visibility with Ctrl+D in browser

## Current Architecture

**Technology Stack:**
- Flask + Socket.IO for real-time web application
- HTML5 + CSS3 + JavaScript for cloud-themed frontend
- Claude API for natural language processing
- JSON-based file storage for persistence
- httpx for async HTTP requests

**Key Components:**
- `app.py`: Flask application with Socket.IO real-time chat
- `models.py`: Todo and Message dataclasses with JSON serialization
- `services/ai_service.py`: Claude API integration with date parsing
- `services/date_parser.py`: Natural language date parsing
- `services/persistence.py`: JSON file storage manager
- `templates/index.html`: Single-page chat interface
- `static/style.css`: Cloud theme with gradient fading effects
- `static/script.js`: Real-time chat and fading message functionality

**Project Structure:**
```
todo_app/
├── app.py                    # Flask app with Socket.IO
├── models.py                 # Todo and Message models
├── run.py                    # Simple launcher script
├── requirements.txt          # Python dependencies
├── services/
│   ├── ai_service.py        # Claude API integration
│   ├── date_parser.py       # Natural language date parsing
│   └── persistence.py       # JSON storage
├── templates/
│   └── index.html           # Single chat interface
├── static/
│   ├── style.css           # Cloud theme + fading effects
│   └── script.js           # Chat functionality
└── data/                   # JSON storage (auto-created)
    ├── messages.json       # Chat history
    └── todos.json          # Todo items
```

**Key Features:**
- Messages gradually fade as they scroll upward in chat history
- Real-time chat with typing indicators
- Natural conversation flow with persistent memory
- Intelligent date recognition and parsing
- Calm, cloud-inspired visual design