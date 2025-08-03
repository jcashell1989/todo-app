import SwiftUI

extension Color {
    static let theme = ColorTheme()
}

struct ColorTheme {
    // Calm light blues and greys
    let background = Color(red: 0.98, green: 0.99, blue: 1.0)
    let surface = Color(red: 0.95, green: 0.97, blue: 0.99)
    let surfaceSecondary = Color(red: 0.92, green: 0.95, blue: 0.97)
    
    // Text colors
    let textPrimary = Color(red: 0.15, green: 0.15, blue: 0.18)
    let textSecondary = Color(red: 0.4, green: 0.45, blue: 0.5)
    let textTertiary = Color(red: 0.6, green: 0.65, blue: 0.7)
    
    // Accent colors
    let accent = Color(red: 0.4, green: 0.6, blue: 0.8)
    let accentLight = Color(red: 0.6, green: 0.75, blue: 0.9)
    
    // User vs AI message colors
    let userMessage = Color(red: 0.88, green: 0.92, blue: 0.96)
    let aiMessage = Color(red: 0.92, green: 0.96, blue: 0.98)
    
    // Status colors
    let success = Color(red: 0.4, green: 0.7, blue: 0.5)
    let warning = Color(red: 0.8, green: 0.6, blue: 0.3)
    let error = Color(red: 0.8, green: 0.4, blue: 0.4)
}