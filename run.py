#!/usr/bin/env python3
"""
Simple launcher script for the Todo Chat app.
Checks environment and starts the Flask application.
"""

import os
import sys
import socket
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

def find_available_port(start_port=5000):
    """Find an available port starting from start_port"""
    port = start_port
    while port < start_port + 100:  # Try up to 100 ports
        try:
            sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            sock.bind(('localhost', port))
            sock.close()
            return port
        except OSError:
            port += 1
    raise RuntimeError(f"No available ports found in range {start_port}-{start_port+99}")

def open_browser(port):
    """Open browser after a short delay"""
    sleep(2)  # Wait for Flask to start
    webbrowser.open(f'http://localhost:{port}')

def main():
    print("🌤️  Starting Todo Chat App...")
    print("=" * 50)
    
    # Check environment
    check_environment()
    
    # Find available port
    try:
        port = find_available_port(5000)
        print(f"🚀 Starting server on http://localhost:{port}")
        print("📱 App will open automatically in your browser")
        print("🛑 Press Ctrl+C to stop the server")
        print()
    except RuntimeError as e:
        print(f"❌ {e}")
        return 1
    
    # Open browser in background thread
    browser_thread = threading.Thread(target=open_browser, args=(port,))
    browser_thread.daemon = True
    browser_thread.start()
    
    # Import and run the Flask app
    try:
        from app import app, socketio
        socketio.run(app, debug=False, host='0.0.0.0', port=port)
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