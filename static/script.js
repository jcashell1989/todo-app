// Socket.IO connection
const socket = io();

// DOM elements
const messagesArea = document.getElementById('messagesArea');
const messageInput = document.getElementById('messageInput');
const sendButton = document.getElementById('sendButton');
const todosDebug = document.getElementById('todosDebug');
const todosList = document.getElementById('todosList');

// State
let isProcessing = false;

// Initialize
document.addEventListener('DOMContentLoaded', function() {
    setupEventListeners();
    focusInput();
});

function setupEventListeners() {
    // Send message on button click
    sendButton.addEventListener('click', sendMessage);
    
    // Send message on Enter key
    messageInput.addEventListener('keypress', function(e) {
        if (e.key === 'Enter' && !e.shiftKey) {
            e.preventDefault();
            sendMessage();
        }
    });
    
    // Socket event listeners
    socket.on('connect', function() {
        console.log('Connected to server');
    });
    
    socket.on('initial_data', function(data) {
        displayMessages(data.messages);
        updateTodos(data.todos);
        scrollToBottom();
    });
    
    socket.on('new_message', function(message) {
        displayMessage(message);
        scrollToBottom();
    });
    
    socket.on('todos_updated', function(todos) {
        updateTodos(todos);
    });
    
    socket.on('disconnect', function() {
        console.log('Disconnected from server');
    });
}

function sendMessage() {
    const message = messageInput.value.trim();
    if (!message || isProcessing) return;
    
    // Clear input and disable while processing
    messageInput.value = '';
    setProcessing(true);
    
    // Send message to server
    socket.emit('send_message', { message: message });
    
    // Show typing indicator
    showTypingIndicator();
}

function setProcessing(processing) {
    isProcessing = processing;
    sendButton.disabled = processing;
    messageInput.disabled = processing;
    
    if (!processing) {
        hideTypingIndicator();
        focusInput();
    }
}

function displayMessages(messages) {
    messagesArea.innerHTML = '';
    messages.forEach(message => displayMessage(message));
}

function displayMessage(message) {
    const messageDiv = document.createElement('div');
    messageDiv.className = `message ${message.sender}`;
    messageDiv.setAttribute('data-message-id', message.id);
    
    // Add message type class if not text
    if (message.message_type && message.message_type !== 'text') {
        messageDiv.classList.add(message.message_type);
    }
    
    // Create message content
    const contentDiv = document.createElement('div');
    contentDiv.className = 'message-content';
    contentDiv.textContent = message.content;
    
    // Create timestamp
    const timeDiv = document.createElement('div');
    timeDiv.className = 'message-time';
    const timestamp = new Date(message.timestamp);
    timeDiv.textContent = formatTime(timestamp);
    
    messageDiv.appendChild(contentDiv);
    messageDiv.appendChild(timeDiv);
    
    messagesArea.appendChild(messageDiv);
    
    // Stop processing after assistant message
    if (message.sender === 'assistant') {
        setProcessing(false);
    }
    
    // Update fading effect
    updateMessageFading();
}

function showTypingIndicator() {
    // Remove existing typing indicator
    hideTypingIndicator();
    
    const typingDiv = document.createElement('div');
    typingDiv.className = 'typing-indicator';
    typingDiv.id = 'typing-indicator';
    
    // Add typing dots
    for (let i = 0; i < 3; i++) {
        const dot = document.createElement('div');
        dot.className = 'typing-dot';
        typingDiv.appendChild(dot);
    }
    
    messagesArea.appendChild(typingDiv);
    scrollToBottom();
}

function hideTypingIndicator() {
    const indicator = document.getElementById('typing-indicator');
    if (indicator) {
        indicator.remove();
    }
}

function updateTodos(todos) {
    // Update debug panel if visible
    if (todosDebug.style.display !== 'none') {
        todosList.innerHTML = '';
        todos.forEach(todo => {
            const todoDiv = document.createElement('div');
            todoDiv.innerHTML = `
                <strong>${todo.title}</strong> 
                <span style="color: #666;">[${todo.status}]</span>
                ${todo.due_date ? `<br><small>Due: ${formatDate(new Date(todo.due_date))}</small>` : ''}
            `;
            todosList.appendChild(todoDiv);
        });
    }
}

function updateMessageFading() {
    const messages = messagesArea.querySelectorAll('.message:not(.typing-indicator)');
    const totalMessages = messages.length;
    
    messages.forEach((message, index) => {
        // Remove any existing fading classes
        for (let i = 1; i <= 9; i++) {
            message.classList.remove(`fading-${i}`);
        }
        
        // Calculate fading level based on position from bottom
        const positionFromBottom = totalMessages - index;
        if (positionFromBottom > 10) {
            const fadingLevel = Math.min(9, Math.floor((positionFromBottom - 10) / 2) + 1);
            message.classList.add(`fading-${fadingLevel}`);
        }
    });
}

function scrollToBottom() {
    requestAnimationFrame(() => {
        messagesArea.scrollTop = messagesArea.scrollHeight;
    });
}

function focusInput() {
    if (!messageInput.disabled) {
        messageInput.focus();
    }
}

function formatTime(date) {
    return date.toLocaleTimeString([], { 
        hour: '2-digit', 
        minute: '2-digit',
        hour12: true 
    });
}

function formatDate(date) {
    return date.toLocaleDateString([], {
        month: 'short',
        day: 'numeric',
        year: date.getFullYear() !== new Date().getFullYear() ? 'numeric' : undefined
    });
}

// Scroll event for fading effect
messagesArea.addEventListener('scroll', updateMessageFading);

// Debug toggle (press 'd' key)
document.addEventListener('keydown', function(e) {
    if (e.key === 'd' && e.ctrlKey) {
        e.preventDefault();
        const isVisible = todosDebug.style.display !== 'none';
        todosDebug.style.display = isVisible ? 'none' : 'block';
    }
});

// Handle window resize
window.addEventListener('resize', () => {
    scrollToBottom();
});