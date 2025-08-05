from dataclasses import dataclass, field
from datetime import datetime
from enum import Enum
from typing import Optional, Dict, Any, List
import uuid

class TodoPriority(Enum):
    LOW = "low"
    MEDIUM = "medium"
    HIGH = "high"
    URGENT = "urgent"
    
    @property
    def display_name(self) -> str:
        return {
            TodoPriority.LOW: "Low",
            TodoPriority.MEDIUM: "Medium", 
            TodoPriority.HIGH: "High",
            TodoPriority.URGENT: "Urgent"
        }[self]
    
    @property
    def sort_order(self) -> int:
        return {
            TodoPriority.LOW: 1,
            TodoPriority.MEDIUM: 2,
            TodoPriority.HIGH: 3,
            TodoPriority.URGENT: 4
        }[self]

class TodoStatus(Enum):
    PENDING = "pending"
    IN_PROGRESS = "in_progress"
    COMPLETED = "completed"
    
    @property
    def display_name(self) -> str:
        return {
            TodoStatus.PENDING: "Pending",
            TodoStatus.IN_PROGRESS: "In Progress",
            TodoStatus.COMPLETED: "Completed"
        }[self]

class MessageSender(Enum):
    USER = "user"
    ASSISTANT = "assistant"
    SYSTEM = "system"

class MessageType(Enum):
    TEXT = "text"
    TODO_UPDATE = "todo_update"
    ERROR = "error"

@dataclass
class Todo:
    title: str
    id: str = field(default_factory=lambda: str(uuid.uuid4()))
    description: Optional[str] = None
    priority: TodoPriority = TodoPriority.MEDIUM
    status: TodoStatus = TodoStatus.PENDING
    created_date: datetime = field(default_factory=datetime.now)
    due_date: Optional[datetime] = None
    completed_date: Optional[datetime] = None
    
    def mark_completed(self) -> None:
        self.status = TodoStatus.COMPLETED
        self.completed_date = datetime.now()
    
    def mark_in_progress(self) -> None:
        self.status = TodoStatus.IN_PROGRESS
        self.completed_date = None
    
    def mark_pending(self) -> None:
        self.status = TodoStatus.PENDING
        self.completed_date = None
    
    def to_dict(self) -> Dict[str, Any]:
        return {
            'id': self.id,
            'title': self.title,
            'description': self.description,
            'priority': self.priority.value,
            'status': self.status.value,
            'created_date': self.created_date.isoformat(),
            'due_date': self.due_date.isoformat() if self.due_date else None,
            'completed_date': self.completed_date.isoformat() if self.completed_date else None
        }
    
    @classmethod
    def from_dict(cls, data: Dict[str, Any]) -> 'Todo':
        todo = cls(
            id=data['id'],
            title=data['title'],
            description=data.get('description'),
            priority=TodoPriority(data['priority']),
            status=TodoStatus(data['status']),
            created_date=datetime.fromisoformat(data['created_date'])
        )
        
        if data.get('due_date'):
            todo.due_date = datetime.fromisoformat(data['due_date'])
        if data.get('completed_date'):
            todo.completed_date = datetime.fromisoformat(data['completed_date'])
            
        return todo

@dataclass
class Message:
    content: str
    sender: MessageSender
    id: str = field(default_factory=lambda: str(uuid.uuid4()))
    timestamp: datetime = field(default_factory=datetime.now)
    message_type: MessageType = MessageType.TEXT
    
    def to_dict(self) -> Dict[str, Any]:
        return {
            'id': self.id,
            'content': self.content,
            'sender': self.sender.value,
            'timestamp': self.timestamp.isoformat(),
            'message_type': self.message_type.value if isinstance(self.message_type, MessageType) else self.message_type
        }
    
    @classmethod
    def from_dict(cls, data: Dict[str, Any]) -> 'Message':
        return cls(
            id=data['id'],
            content=data['content'],
            sender=MessageSender(data['sender']),
            timestamp=datetime.fromisoformat(data['timestamp']),
            message_type=MessageType(data.get('message_type', 'text'))
        )

@dataclass
class TodoUpdate:
    action: str  # add, update, complete, delete
    todo_id: Optional[str] = None
    title: Optional[str] = None
    description: Optional[str] = None
    priority: Optional[TodoPriority] = None
    due_date: Optional[datetime] = None

@dataclass
class AIResponse:
    message: str
    todo_updates: Optional[List[TodoUpdate]] = None