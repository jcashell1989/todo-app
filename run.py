#!/usr/bin/env python3
"""
Simple launcher script for the Todo Chat app.
Checks environment and starts the Flask application.
"""

import os
import sys
import webbrowser
from time import sleep
import threading

def check_environment():
    """Check if required environment variables are set"""
    api_key = os.getenv('CLAUDE_API_KEY')
    if not api_key:
        print("⚠️  Warning: CLAUDE_API_KEY environment variable not set")
        print("   The app will start but won't be able to process messages")
        print("   Set your API key with: export CLAUDE_API_KEY='your-key-here'")
        print()
    else:
        print("✅ Claude API key found")

def open_browser():
    """Open browser after a short delay"""
    sleep(2)  # Wait for Flask to start
    webbrowser.open('http://localhost:5000')

def main():
    print("🌤️  Starting Todo Chat App...")
    print("=" * 50)
    
    # Check environment
    check_environment()
    
    # Check if port is already in use
    import socket
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    result = sock.connect_ex(('localhost', 5000))
    sock.close()
    
    if result == 0:
        print("❌ Port 5000 is already in use")
        print("   Stop any other applications using port 5000 and try again")
        return 1
    
    print("🚀 Starting server on http://localhost:5000")
    print("📱 App will open automatically in your browser")
    print("🛑 Press Ctrl+C to stop the server")
    print()
    
    # Open browser in background thread
    browser_thread = threading.Thread(target=open_browser)
    browser_thread.daemon = True
    browser_thread.start()
    
    # Import and run the Flask app
    try:
        from app import app, socketio
        socketio.run(app, debug=False, host='0.0.0.0', port=5000)
    except KeyboardInterrupt:
        print("\n👋 Shutting down Todo Chat App...")
        return 0
    except ImportError as e:
        print(f"❌ Error importing app: {e}")
        print("   Make sure all dependencies are installed: pip install -r requirements.txt")
        return 1
    except Exception as e:
        print(f"❌ Error starting app: {e}")
        return 1

if __name__ == '__main__':
    sys.exit(main())