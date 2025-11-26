//
//  UserProfile.swift
//  Psychosis
//
//  Created on [Current Date]
//

import Foundation

/// User profile model
struct UserProfile: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var email: String
    var bio: String
    var avatarURL: String?
    var joinDate: Date
    var preferences: UserPreferences
    
    init(
        id: UUID = UUID(),
        name: String = "",
        email: String = "",
        bio: String = "",
        avatarURL: String? = nil,
        joinDate: Date = Date(),
        preferences: UserPreferences = UserPreferences()
    ) {
        self.id = id
        self.name = name
        self.email = email
        self.bio = bio
        self.avatarURL = avatarURL
        self.joinDate = joinDate
        self.preferences = preferences
    }
}

/// User preferences
struct UserPreferences: Codable, Equatable {
    var theme: AppTheme
    var notificationsEnabled: Bool
    var hapticFeedbackEnabled: Bool
    
    init(
        theme: AppTheme = .system,
        notificationsEnabled: Bool = true,
        hapticFeedbackEnabled: Bool = true
    ) {
        self.theme = theme
        self.notificationsEnabled = notificationsEnabled
        self.hapticFeedbackEnabled = hapticFeedbackEnabled
    }
}

enum AppTheme: String, Codable, CaseIterable {
    case light = "Light"
    case dark = "Dark"
    case system = "System"
}

