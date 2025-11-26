//
//  Constants.swift
//  Psychosis
//
//  Created on [Current Date]
//

import Foundation

enum Constants {
    // App Information
    static let appName = "Psychosis"
    static let appVersion = "0.1.0"
    
    // API Configuration
    static let baseURL = "https://api.example.com" // TODO: Update with actual API URL
    
    // Storage Keys
    enum StorageKeys {
        static let userPreferences = "userPreferences"
        static let homeItems = "homeItems"
        static let darkModeEnabled = "darkModeEnabled"
        static let notificationsEnabled = "notificationsEnabled"
        static let hapticFeedbackEnabled = "hapticFeedbackEnabled"
        static let userProfile = "userProfile"
        static let notifications = "notifications"
        static let favorites = "favorites"
        static let history = "history"
        static let tasks = "tasks"
        static let calendarEvents = "calendarEvents"
        static let notes = "notes"
    }
}

