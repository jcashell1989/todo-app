#!/bin/bash

# Todo App Launch Script
# This script sets up the environment and launches the Todo App

echo "🚀 Todo App Launch Script"
echo "=========================="

# Check if Xcode is installed
if ! command -v xcodebuild &> /dev/null; then
    echo "❌ Error: Xcode is not installed or not in PATH"
    echo "Please install Xcode from the Mac App Store"
    exit 1
fi

# Check for Claude API key
if [ -z "$CLAUDE_API_KEY" ]; then
    echo "⚠️  Warning: CLAUDE_API_KEY environment variable is not set"
    echo ""
    echo "To set your Claude API key:"
    echo "1. Get your API key from https://console.anthropic.com/"
    echo "2. Export it in your shell:"
    echo "   export CLAUDE_API_KEY='your-api-key-here'"
    echo "3. Or add it to your ~/.zshrc or ~/.bash_profile:"
    echo "   echo 'export CLAUDE_API_KEY=\"your-api-key-here\"' >> ~/.zshrc"
    echo ""
    read -p "Do you want to continue without the API key? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Setup cancelled. Please set your API key and try again."
        exit 1
    fi
fi

# Check if we're in the right directory
if [ ! -f "TodoApp.xcodeproj/project.pbxproj" ]; then
    echo "❌ Error: TodoApp.xcodeproj not found"
    echo "Please run this script from the todo_app directory"
    exit 1
fi

echo "✅ Environment checks passed"
echo ""

# Offer to open in Xcode
echo "Choose how to launch the app:"
echo "1. Open in Xcode (recommended for development)"
echo "2. Build and run from command line"
echo "3. Just open Xcode project"
echo ""
read -p "Enter your choice (1-3): " choice

case $choice in
    1)
        echo "🔨 Building and running in Xcode..."
        xcodebuild -project TodoApp.xcodeproj -scheme TodoApp -configuration Debug build
        if [ $? -eq 0 ]; then
            echo "✅ Build successful! Opening in Xcode..."
            open TodoApp.xcodeproj
        else
            echo "❌ Build failed. Opening Xcode for debugging..."
            open TodoApp.xcodeproj
        fi
        ;;
    2)
        echo "🔨 Building from command line..."
        xcodebuild -project TodoApp.xcodeproj -scheme TodoApp -configuration Debug build
        if [ $? -eq 0 ]; then
            echo "✅ Build successful!"
            # Note: Running from command line requires more setup for macOS apps
            echo "To run the app, please use Xcode or build an archive"
        else
            echo "❌ Build failed"
            exit 1
        fi
        ;;
    3)
        echo "📱 Opening Xcode project..."
        open TodoApp.xcodeproj
        ;;
    *)
        echo "Invalid choice. Opening Xcode project..."
        open TodoApp.xcodeproj
        ;;
esac

echo ""
echo "🎉 Setup complete!"
echo ""
echo "Next steps:"
echo "1. If you haven't set your Claude API key, do so in Xcode:"
echo "   Product → Scheme → Edit Scheme → Run → Environment Variables"
echo "   Add: CLAUDE_API_KEY = your-api-key"
echo ""
echo "2. Build and run the app in Xcode (Cmd+R)"
echo ""
echo "3. Start chatting with your todo assistant!"
echo ""
echo "Happy organizing! 📝✨"