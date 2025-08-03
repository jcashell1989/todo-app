import Foundation

class DateParser {
    private let calendar = Calendar.current
    private let today = Date()
    
    func parseNaturalLanguageDate(from text: String) -> Date? {
        let lowercasedText = text.lowercased()
        
        // Today
        if lowercasedText.contains("today") {
            return calendar.startOfDay(for: today)
        }
        
        // Tomorrow
        if lowercasedText.contains("tomorrow") {
            return calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: today))
        }
        
        // Yesterday (for past reference)
        if lowercasedText.contains("yesterday") {
            return calendar.date(byAdding: .day, value: -1, to: calendar.startOfDay(for: today))
        }
        
        // Next week
        if lowercasedText.contains("next week") {
            return calendar.date(byAdding: .weekOfYear, value: 1, to: calendar.startOfDay(for: today))
        }
        
        // This week
        if lowercasedText.contains("this week") {
            return calendar.startOfDay(for: today)
        }
        
        // Days of the week
        if let weekdayDate = parseWeekday(from: lowercasedText) {
            return weekdayDate
        }
        
        // Relative days (in X days)
        if let relativeDays = parseRelativeDays(from: lowercasedText) {
            return calendar.date(byAdding: .day, value: relativeDays, to: calendar.startOfDay(for: today))
        }
        
        // Next month
        if lowercasedText.contains("next month") {
            return calendar.date(byAdding: .month, value: 1, to: calendar.startOfDay(for: today))
        }
        
        // Specific dates (MM/DD, MM-DD, etc.)
        if let specificDate = parseSpecificDate(from: text) {
            return specificDate
        }
        
        return nil
    }
    
    private func parseWeekday(from text: String) -> Date? {
        let weekdays = [
            "monday": 2, "tuesday": 3, "wednesday": 4, "thursday": 5,
            "friday": 6, "saturday": 7, "sunday": 1,
            "mon": 2, "tue": 3, "wed": 4, "thu": 5, "fri": 6, "sat": 7, "sun": 1
        ]
        
        for (day, weekdayNumber) in weekdays {
            if text.contains(day) {
                return nextDate(for: weekdayNumber)
            }
        }
        
        return nil
    }
    
    private func nextDate(for weekday: Int) -> Date? {
        let currentWeekday = calendar.component(.weekday, from: today)
        var daysToAdd = weekday - currentWeekday
        
        if daysToAdd <= 0 {
            daysToAdd += 7
        }
        
        return calendar.date(byAdding: .day, value: daysToAdd, to: calendar.startOfDay(for: today))
    }
    
    private func parseRelativeDays(from text: String) -> Int? {
        let patterns = [
            "in (\\d+) days?",
            "(\\d+) days? from now",
            "after (\\d+) days?"
        ]
        
        for pattern in patterns {
            let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive)
            let range = NSRange(text.startIndex..<text.endIndex, in: text)
            
            if let match = regex?.firstMatch(in: text, options: [], range: range) {
                let numberRange = match.range(at: 1)
                if let swiftRange = Range(numberRange, in: text) {
                    let numberString = String(text[swiftRange])
                    return Int(numberString)
                }
            }
        }
        
        return nil
    }
    
    private func parseSpecificDate(from text: String) -> Date? {
        let dateFormatter = DateFormatter()
        
        // Try various formats
        let formats = [
            "MM/dd/yyyy", "MM-dd-yyyy", "MM.dd.yyyy",
            "MM/dd", "MM-dd", "MM.dd",
            "yyyy-MM-dd", "dd/MM/yyyy", "dd-MM-yyyy"
        ]
        
        for format in formats {
            dateFormatter.dateFormat = format
            
            let regex = try? NSRegularExpression(pattern: "\\b\\d{1,4}[/-.]\\d{1,2}(?:[/-.]\\d{1,4})?\\b")
            let range = NSRange(text.startIndex..<text.endIndex, in: text)
            
            if let match = regex?.firstMatch(in: text, options: [], range: range) {
                if let swiftRange = Range(match.range, in: text) {
                    let dateString = String(text[swiftRange])
                    if let date = dateFormatter.date(from: dateString) {
                        // If year not specified, assume current year
                        if !format.contains("yyyy") {
                            let components = calendar.dateComponents([.month, .day], from: date)
                            var newComponents = DateComponents()
                            newComponents.year = calendar.component(.year, from: today)
                            newComponents.month = components.month
                            newComponents.day = components.day
                            
                            if let adjustedDate = calendar.date(from: newComponents) {
                                // If the date is in the past, assume next year
                                if adjustedDate < today {
                                    return calendar.date(byAdding: .year, value: 1, to: adjustedDate)
                                }
                                return adjustedDate
                            }
                        }
                        return date
                    }
                }
            }
        }
        
        return nil
    }
    
    // Helper function to extract date phrases for better parsing
    func extractDatePhrases(from text: String) -> [String] {
        let patterns = [
            "\\b(?:today|tomorrow|yesterday)\\b",
            "\\b(?:next|this)\\s+(?:week|month|year)\\b",
            "\\b(?:monday|tuesday|wednesday|thursday|friday|saturday|sunday|mon|tue|wed|thu|fri|sat|sun)\\b",
            "\\bin\\s+\\d+\\s+days?\\b",
            "\\b\\d+\\s+days?\\s+from\\s+now\\b",
            "\\b\\d{1,2}[/-.]\\d{1,2}(?:[/-.]\\d{2,4})?\\b"
        ]
        
        var phrases: [String] = []
        let text = text.lowercased()
        
        for pattern in patterns {
            let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive)
            let range = NSRange(text.startIndex..<text.endIndex, in: text)
            
            regex?.enumerateMatches(in: text, options: [], range: range) { match, _, _ in
                if let match = match, let swiftRange = Range(match.range, in: text) {
                    phrases.append(String(text[swiftRange]))
                }
            }
        }
        
        return phrases
    }
}