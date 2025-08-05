from flask import Flask, render_template, request, jsonify
from flask_socketio import SocketIO, emit
import os
import json
import socket
from datetime import datetime
from services.ai_service import AIService
from services.persistence import PersistenceManager
from models import Message, Todo, MessageSender, MessageType

app = Flask(__name__)
app.config['SECRET_KEY'] = 'your-secret-key-here'
socketio = SocketIO(app, cors_allowed_origins="*")

ai_service = AIService()
persistence = PersistenceManager()

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/api/messages', methods=['GET'])
def get_messages():
    messages = persistence.load_messages()
    return jsonify([msg.to_dict() for msg in messages])

@app.route('/api/todos', methods=['GET'])
def get_todos():
    todos = persistence.load_todos()
    return jsonify([todo.to_dict() for todo in todos])

@socketio.on('send_message')
def handle_message(data):
    user_message = Message(
        content=data['message'],
        sender=MessageSender.USER
    )
    
    # Save user message
    messages = persistence.load_messages()
    messages.append(user_message)
    persistence.save_messages(messages)
    
    # Emit user message to all clients
    emit('new_message', user_message.to_dict(), broadcast=True)
    
    # Process with AI
    try:
        todos = persistence.load_todos()
        response = ai_service.process_message(data['message'], todos)
        
        # Apply todo updates if any
        if response.todo_updates:
            todos = ai_service.apply_todo_updates(todos, response.todo_updates)
            persistence.save_todos(todos)
        
        # Create assistant message
        assistant_message = Message(
            content=response.message,
            sender=MessageSender.ASSISTANT
        )
        
        # Save assistant message
        messages.append(assistant_message)
        persistence.save_messages(messages)
        
        # Emit assistant response
        emit('new_message', assistant_message.to_dict(), broadcast=True)
        emit('todos_updated', [todo.to_dict() for todo in todos], broadcast=True)
        
    except Exception as e:
        error_message = Message(
            content="I'm having trouble processing that right now. Please try again.",
            sender=MessageSender.ASSISTANT,
            message_type=MessageType.ERROR
        )
        messages.append(error_message)
        persistence.save_messages(messages)
        emit('new_message', error_message.to_dict(), broadcast=True)

@socketio.on('connect')
def handle_connect():
    # Send initial data when client connects
    messages = persistence.load_messages()
    todos = persistence.load_todos()
    
    # Add welcome message if no messages exist
    if not messages:
        welcome_message = Message(
            content="Hello! I'm here to help you manage your todos naturally. You can tell me what you need to do, ask me to prioritize tasks, or just have a conversation about your day.",
            sender=MessageSender.ASSISTANT
        )
        messages.append(welcome_message)
        persistence.save_messages(messages)
    
    emit('initial_data', {
        'messages': [msg.to_dict() for msg in messages],
        'todos': [todo.to_dict() for todo in todos]
    })

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

if __name__ == '__main__':
    # Ensure directories exist
    os.makedirs('data', exist_ok=True)
    
    # Find available port
    port = find_available_port(5000)
    print(f"Starting server on port {port}")
    
    socketio.run(app, debug=True, host='0.0.0.0', port=port)