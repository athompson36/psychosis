//
//  AppTheme.swift
//  Psychosis
//
//  Created on [Current Date]
//

import SwiftUI

/// App-wide theme configuration
struct AppTheme {
    // Colors
    struct Colors {
        static let primary = Color.blue
        static let secondary = Color.gray
        static let background = Color(.systemBackground)
        static let foreground = Color(.label)
    }
    
    // Typography
    struct Typography {
        static let largeTitle = Font.largeTitle
        static let title = Font.title
        static let title2 = Font.title2
        static let title3 = Font.title3
        static let body = Font.body
        static let caption = Font.caption
    }
    
    // Spacing
    struct Spacing {
        static let small: CGFloat = 8
        static let medium: CGFloat = 16
        static let large: CGFloat = 24
        static let extraLarge: CGFloat = 32
    }
    
    // Corner Radius
    struct CornerRadius {
        static let small: CGFloat = 4
        static let medium: CGFloat = 8
        static let large: CGFloat = 16
    }
}

