#!/bin/bash

# Environment Setup Script for Todo App
# This script helps you set up your Claude API key

echo "🔧 Todo App Environment Setup"
echo "=============================="
echo ""

# Check if API key is already set
if [ ! -z "$CLAUDE_API_KEY" ]; then
    echo "✅ CLAUDE_API_KEY is already set in your environment"
    echo "Current key: ${CLAUDE_API_KEY:0:10}..." 
    echo ""
    read -p "Do you want to update it? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Keeping existing API key."
        exit 0
    fi
fi

echo "To get your Claude API key:"
echo "1. Visit https://console.anthropic.com/"
echo "2. Sign in or create an account"
echo "3. Go to API Keys section"
echo "4. Create a new API key"
echo ""

read -p "Enter your Claude API key: " api_key

if [ -z "$api_key" ]; then
    echo "❌ No API key provided. Exiting."
    exit 1
fi

# Validate the key format (basic check)
if [[ ! $api_key =~ ^sk-ant-api03- ]]; then
    echo "⚠️  Warning: API key doesn't match expected format (should start with 'sk-ant-api03-')"
    read -p "Continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Determine which shell config file to use
if [ -f "$HOME/.zshrc" ]; then
    SHELL_CONFIG="$HOME/.zshrc"
elif [ -f "$HOME/.bash_profile" ]; then
    SHELL_CONFIG="$HOME/.bash_profile"
elif [ -f "$HOME/.bashrc" ]; then
    SHELL_CONFIG="$HOME/.bashrc"
else
    SHELL_CONFIG="$HOME/.zshrc"
    echo "Creating new .zshrc file..."
fi

echo ""
echo "Adding CLAUDE_API_KEY to $SHELL_CONFIG"

# Remove any existing CLAUDE_API_KEY lines
grep -v "CLAUDE_API_KEY" "$SHELL_CONFIG" > "${SHELL_CONFIG}.tmp" 2>/dev/null || true
mv "${SHELL_CONFIG}.tmp" "$SHELL_CONFIG" 2>/dev/null || true

# Add the new API key
echo "" >> "$SHELL_CONFIG"
echo "# Todo App - Claude API Key" >> "$SHELL_CONFIG"
echo "export CLAUDE_API_KEY=\"$api_key\"" >> "$SHELL_CONFIG"

echo "✅ API key added to $SHELL_CONFIG"
echo ""
echo "To activate the changes, either:"
echo "1. Restart your terminal, or"
echo "2. Run: source $SHELL_CONFIG"
echo ""

# Set for current session
export CLAUDE_API_KEY="$api_key"

echo "✅ API key is now set for this session"
echo ""
echo "You can now run ./launch.sh to start the Todo App!"