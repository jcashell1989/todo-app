import re
from datetime import datetime, timedelta
from typing import Optional, List

class DateParser:
    def __init__(self):
        self.today = datetime.now().replace(hour=0, minute=0, second=0, microsecond=0)
    
    def parse_natural_language_date(self, text: str) -> Optional[datetime]:
        """Parse natural language date expressions into datetime objects"""
        text_lower = text.lower().strip()
        
        # Today
        if "today" in text_lower:
            return self.today
        
        # Tomorrow
        if "tomorrow" in text_lower:
            return self.today + timedelta(days=1)
        
        # Yesterday (for past reference)
        if "yesterday" in text_lower:
            return self.today - timedelta(days=1)
        
        # Next week
        if "next week" in text_lower:
            return self.today + timedelta(weeks=1)
        
        # This week
        if "this week" in text_lower:
            return self.today
        
        # Days of the week
        weekday_date = self._parse_weekday(text_lower)
        if weekday_date:
            return weekday_date
        
        # Relative days (in X days)
        relative_days = self._parse_relative_days(text_lower)
        if relative_days is not None:
            return self.today + timedelta(days=relative_days)
        
        # Next month
        if "next month" in text_lower:
            if self.today.month == 12:
                return self.today.replace(year=self.today.year + 1, month=1)
            else:
                return self.today.replace(month=self.today.month + 1)
        
        # Specific dates (MM/DD, MM-DD, etc.)
        specific_date = self._parse_specific_date(text)
        if specific_date:
            return specific_date
        
        return None
    
    def _parse_weekday(self, text: str) -> Optional[datetime]:
        """Parse weekday names to next occurrence of that day"""
        weekdays = {
            "monday": 0, "tuesday": 1, "wednesday": 2, "thursday": 3,
            "friday": 4, "saturday": 5, "sunday": 6,
            "mon": 0, "tue": 1, "wed": 2, "thu": 3, 
            "fri": 4, "sat": 5, "sun": 6
        }
        
        for day_name, target_weekday in weekdays.items():
            if day_name in text:
                return self._next_date_for_weekday(target_weekday)
        
        return None
    
    def _next_date_for_weekday(self, target_weekday: int) -> datetime:
        """Get the next occurrence of the specified weekday (0=Monday, 6=Sunday)"""
        current_weekday = self.today.weekday()
        days_ahead = target_weekday - current_weekday
        
        if days_ahead <= 0:  # Target day already happened this week
            days_ahead += 7
        
        return self.today + timedelta(days=days_ahead)
    
    def _parse_relative_days(self, text: str) -> Optional[int]:
        """Parse relative day expressions like 'in 3 days' or '5 days from now'"""
        patterns = [
            r"in (\d+) days?",
            r"(\d+) days? from now",  
            r"after (\d+) days?",
            r"in (\d+) day",
            r"(\d+) day from now"
        ]
        
        for pattern in patterns:
            match = re.search(pattern, text, re.IGNORECASE)
            if match:
                return int(match.group(1))
        
        return None
    
    def _parse_specific_date(self, text: str) -> Optional[datetime]:
        """Parse specific date formats like MM/DD/YYYY, MM-DD, etc."""
        # Date patterns to try
        patterns = [
            (r"\b(\d{1,2})[/-](\d{1,2})[/-](\d{4})\b", "%m/%d/%Y"),  # MM/DD/YYYY
            (r"\b(\d{4})[/-](\d{1,2})[/-](\d{1,2})\b", "%Y/%m/%d"),  # YYYY/MM/DD
            (r"\b(\d{1,2})[/-](\d{1,2})\b", "%m/%d"),               # MM/DD (current year)
        ]
        
        for pattern, date_format in patterns:
            match = re.search(pattern, text)
            if match:
                try:
                    if len(match.groups()) == 2:  # MM/DD format
                        month, day = match.groups()
                        # Assume current year
                        date_str = f"{month}/{day}/{self.today.year}"
                        parsed_date = datetime.strptime(date_str, "%m/%d/%Y")
                        
                        # If the date is in the past, assume next year
                        if parsed_date < self.today:
                            parsed_date = parsed_date.replace(year=self.today.year + 1)
                        
                        return parsed_date.replace(hour=0, minute=0, second=0, microsecond=0)
                    
                    elif len(match.groups()) == 3:  # Full date format
                        if date_format == "%Y/%m/%d":
                            year, month, day = match.groups()
                            date_str = f"{year}/{month}/{day}"
                        else:  # MM/DD/YYYY
                            month, day, year = match.groups()
                            date_str = f"{month}/{day}/{year}"
                        
                        parsed_date = datetime.strptime(date_str, date_format)
                        return parsed_date.replace(hour=0, minute=0, second=0, microsecond=0)
                
                except ValueError:
                    continue
        
        return None
    
    def extract_date_phrases(self, text: str) -> List[str]:
        """Extract potential date phrases from text for better parsing"""
        patterns = [
            r"\b(?:today|tomorrow|yesterday)\b",
            r"\b(?:next|this)\s+(?:week|month|year)\b",
            r"\b(?:monday|tuesday|wednesday|thursday|friday|saturday|sunday|mon|tue|wed|thu|fri|sat|sun)\b",
            r"\bin\s+\d+\s+days?\b",
            r"\b\d+\s+days?\s+from\s+now\b",
            r"\b\d{1,2}[/-]\d{1,2}(?:[/-]\d{2,4})?\b"
        ]
        
        phrases = []
        text_lower = text.lower()
        
        for pattern in patterns:
            matches = re.finditer(pattern, text_lower, re.IGNORECASE)
            for match in matches:
                phrases.append(match.group())
        
        return phrases