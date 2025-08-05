import json
import os
from typing import List
from datetime import datetime
from models import Todo, Message, TodoPriority, TodoStatus, MessageSender, MessageType

class PersistenceManager:
    def __init__(self, data_dir: str = "data"):
        self.data_dir = data_dir
        self.messages_file = os.path.join(data_dir, "messages.json")
        self.todos_file = os.path.join(data_dir, "todos.json")
        
        # Ensure data directory exists
        os.makedirs(data_dir, exist_ok=True)
    
    def load_messages(self) -> List[Message]:
        """Load messages from JSON file"""
        if not os.path.exists(self.messages_file):
            return []
        
        try:
            with open(self.messages_file, 'r', encoding='utf-8') as f:
                data = json.load(f)
                return [Message.from_dict(msg_data) for msg_data in data]
        except (json.JSONDecodeError, KeyError, ValueError) as e:
            print(f"Error loading messages: {e}")
            return []
    
    def save_messages(self, messages: List[Message]) -> None:
        """Save messages to JSON file"""
        try:
            with open(self.messages_file, 'w', encoding='utf-8') as f:
                data = [msg.to_dict() for msg in messages]
                json.dump(data, f, indent=2, ensure_ascii=False)
        except Exception as e:
            print(f"Error saving messages: {e}")
    
    def load_todos(self) -> List[Todo]:
        """Load todos from JSON file"""
        if not os.path.exists(self.todos_file):
            return []
        
        try:
            with open(self.todos_file, 'r', encoding='utf-8') as f:
                data = json.load(f)
                return [Todo.from_dict(todo_data) for todo_data in data]
        except (json.JSONDecodeError, KeyError, ValueError) as e:
            print(f"Error loading todos: {e}")
            return []
    
    def save_todos(self, todos: List[Todo]) -> None:
        """Save todos to JSON file"""
        try:
            with open(self.todos_file, 'w', encoding='utf-8') as f:
                data = [todo.to_dict() for todo in todos]
                json.dump(data, f, indent=2, ensure_ascii=False)
        except Exception as e:
            print(f"Error saving todos: {e}")
    
    def clear_all_data(self) -> None:
        """Clear all persisted data (for testing/reset)"""
        try:
            if os.path.exists(self.messages_file):
                os.remove(self.messages_file)
            if os.path.exists(self.todos_file):
                os.remove(self.todos_file)
        except Exception as e:
            print(f"Error clearing data: {e}")
    
    def backup_data(self, backup_dir: str = "backup") -> bool:
        """Create a backup of current data"""
        try:
            os.makedirs(backup_dir, exist_ok=True)
            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            
            # Backup messages
            if os.path.exists(self.messages_file):
                backup_messages = os.path.join(backup_dir, f"messages_{timestamp}.json")
                with open(self.messages_file, 'r') as src, open(backup_messages, 'w') as dst:
                    dst.write(src.read())
            
            # Backup todos
            if os.path.exists(self.todos_file):
                backup_todos = os.path.join(backup_dir, f"todos_{timestamp}.json")
                with open(self.todos_file, 'r') as src, open(backup_todos, 'w') as dst:
                    dst.write(src.read())
            
            return True
        except Exception as e:
            print(f"Error creating backup: {e}")
            return False