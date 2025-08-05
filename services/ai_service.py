import os
import json
import httpx
from typing import List, Optional, Dict, Any
from datetime import datetime
from models import Todo, TodoUpdate, AIResponse, TodoPriority, TodoStatus
from services.date_parser import DateParser

class AIService:
    def __init__(self):
        self.api_key = os.getenv('CLAUDE_API_KEY', '')
        if not self.api_key:
            print("Warning: CLAUDE_API_KEY environment variable not set")
        
        self.base_url = "https://api.anthropic.com/v1/messages"
        self.date_parser = DateParser()
    
    async def process_message(self, message: str, current_todos: List[Todo]) -> AIResponse:
        if not self.api_key:
            raise Exception("Claude API key not configured")
        
        enhanced_message = self._enhance_message_with_date_parsing(message)
        system_prompt = self._create_system_prompt(current_todos)
        
        async with httpx.AsyncClient() as client:
            response = await self._make_api_request(client, system_prompt, enhanced_message)
            return self._parse_response(response)
    
    def process_message(self, message: str, current_todos: List[Todo]) -> AIResponse:
        """Synchronous version for compatibility"""
        if not self.api_key:
            raise Exception("Claude API key not configured")
        
        enhanced_message = self._enhance_message_with_date_parsing(message)
        system_prompt = self._create_system_prompt(current_todos)
        
        with httpx.Client() as client:
            response = self._make_api_request_sync(client, system_prompt, enhanced_message)
            return self._parse_response(response)
    
    def _enhance_message_with_date_parsing(self, message: str) -> str:
        date_phrases = self.date_parser.extract_date_phrases(message)
        
        if not date_phrases:
            return message
        
        enhanced_message = message
        date_context = "\n\nDetected date references:"
        
        for phrase in date_phrases:
            parsed_date = self.date_parser.parse_natural_language_date(phrase)
            if parsed_date:
                iso_date = parsed_date.isoformat()
                date_context += f"\n- '{phrase}' = {iso_date}"
        
        return enhanced_message + date_context
    
    def _create_system_prompt(self, todos: List[Todo]) -> str:
        todos_json = self._todos_to_json(todos)
        
        return f"""You are a helpful todo assistant. You help users manage their todos through natural conversation.

Current todos (JSON format):
{todos_json}

When responding:
1. Be conversational and helpful
2. If the user wants to add, update, or complete todos, include the appropriate JSON structure
3. Always respond with plain text followed by JSON if todo updates are needed
4. For todo updates, use this exact format:

RESPONSE_TEXT

TODO_UPDATES:
{{
    "updates": [
        {{
            "action": "add|update|complete|delete",
            "todoId": "uuid-string-if-updating-existing",
            "title": "todo title",
            "description": "optional description",
            "priority": "low|medium|high|urgent",
            "dueDate": "ISO8601 date string if applicable"
        }}
    ]
}}

Keep responses natural and conversational. Help prioritize and organize tasks thoughtfully."""
    
    def _todos_to_json(self, todos: List[Todo]) -> str:
        try:
            todos_data = [todo.to_dict() for todo in todos]
            return json.dumps(todos_data, indent=2)
        except Exception:
            return "[]"
    
    async def _make_api_request(self, client: httpx.AsyncClient, system_prompt: str, user_message: str) -> Dict[str, Any]:
        headers = {
            "Content-Type": "application/json",
            "anthropic-version": "2023-06-01",
            "x-api-key": self.api_key
        }
        
        body = {
            "model": "claude-3-sonnet-20240229",
            "max_tokens": 1000,
            "messages": [
                {
                    "role": "user",
                    "content": user_message
                }
            ],
            "system": system_prompt
        }
        
        response = await client.post(self.base_url, headers=headers, json=body)
        
        if response.status_code != 200:
            raise Exception(f"API error with status code: {response.status_code}")
        
        return response.json()
    
    def _make_api_request_sync(self, client: httpx.Client, system_prompt: str, user_message: str) -> Dict[str, Any]:
        headers = {
            "Content-Type": "application/json",
            "anthropic-version": "2023-06-01",
            "x-api-key": self.api_key
        }
        
        body = {
            "model": "claude-3-sonnet-20240229",
            "max_tokens": 1000,
            "messages": [
                {
                    "role": "user",
                    "content": user_message
                }
            ],
            "system": system_prompt
        }
        
        response = client.post(self.base_url, headers=headers, json=body)
        
        if response.status_code != 200:
            raise Exception(f"API error with status code: {response.status_code}")
        
        return response.json()
    
    def _parse_response(self, json_response: Dict[str, Any]) -> AIResponse:
        try:
            content = json_response.get("content", [])
            if not content or not isinstance(content, list):
                raise Exception("Invalid response format")
            
            text = content[0].get("text", "")
            response_text, todo_updates = self._extract_todo_updates(text)
            
            return AIResponse(
                message=response_text.strip(),
                todo_updates=todo_updates
            )
        except Exception as e:
            raise Exception(f"Failed to parse API response: {str(e)}")
    
    def _extract_todo_updates(self, text: str) -> tuple[str, Optional[List[TodoUpdate]]]:
        components = text.split("TODO_UPDATES:")
        
        if len(components) != 2:
            return text, None
        
        response_text = components[0].strip()
        json_text = components[1].strip()
        
        try:
            json_data = json.loads(json_text)
            updates_array = json_data.get("updates", [])
            
            updates = []
            for update_dict in updates_array:
                action = update_dict.get("action")
                if not action:
                    continue
                
                todo_id = update_dict.get("todoId")
                title = update_dict.get("title")
                description = update_dict.get("description")
                
                priority = None
                if update_dict.get("priority"):
                    try:
                        priority = TodoPriority(update_dict["priority"])
                    except ValueError:
                        priority = TodoPriority.MEDIUM
                
                due_date = None
                if update_dict.get("dueDate"):
                    try:
                        due_date = datetime.fromisoformat(update_dict["dueDate"].replace('Z', '+00:00'))
                    except ValueError:
                        pass
                
                updates.append(TodoUpdate(
                    action=action,
                    todo_id=todo_id,
                    title=title,
                    description=description,
                    priority=priority,
                    due_date=due_date
                ))
            
            return response_text, updates if updates else None
            
        except (json.JSONDecodeError, KeyError):
            return response_text, None
    
    def apply_todo_updates(self, todos: List[Todo], updates: List[TodoUpdate]) -> List[Todo]:
        """Apply todo updates to the current todo list"""
        todos_copy = todos.copy()
        
        for update in updates:
            if update.action == "add":
                new_todo = Todo(
                    title=update.title or "New Todo",
                    description=update.description,
                    priority=update.priority or TodoPriority.MEDIUM,
                    due_date=update.due_date
                )
                todos_copy.append(new_todo)
            
            elif update.action == "complete":
                for todo in todos_copy:
                    if todo.id == update.todo_id:
                        todo.mark_completed()
                        break
            
            elif update.action == "update":
                for todo in todos_copy:
                    if todo.id == update.todo_id:
                        if update.title:
                            todo.title = update.title
                        if update.description:
                            todo.description = update.description
                        if update.priority:
                            todo.priority = update.priority
                        if update.due_date:
                            todo.due_date = update.due_date
                        break
            
            elif update.action == "delete":
                todos_copy = [todo for todo in todos_copy if todo.id != update.todo_id]
        
        return todos_copy