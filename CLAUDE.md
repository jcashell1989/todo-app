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

## Development Approach

**Setup and Deployment:**
- Initialize git repository and use `gh` command for GitHub integration
- Assume API keys will be provided during development
- Keep code light and easily readable

**Development Process:**
- Ask 2-3 clarifying questions after each implementation prompt
- Focus on naturalistic language processing for task management
- Implement persistent storage for todo data

## Architecture Considerations

This is a greenfield project requiring:
- macOS desktop GUI framework selection (likely SwiftUI, Electron, or similar)
- Voice input/output integration
- Natural language processing for todo management
- Local data persistence layer
- Conversational UI components with message history

The project emphasizes user experience over technical complexity, prioritizing calm, intuitive interaction patterns.