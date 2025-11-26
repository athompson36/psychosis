//
//  SettingsViewModel.swift
//  Psychosis
//
//  Created on [Current Date]
//

import Foundation
import SwiftUI

/// ViewModel for Settings screen
@Observable
final class SettingsViewModel {
    // MARK: - Properties
    
    var sections: [SettingsSection] = []
    var isDarkModeEnabled = false
    var notificationsEnabled = true
    var hapticFeedbackEnabled = true
    
    // MARK: - Dependencies
    
    private let storageManager: StorageManager
    
    // MARK: - Initialization
    
    init(storageManager: StorageManager = DefaultStorageManager()) {
        self.storageManager = storageManager
        loadSettings()
        buildSections()
    }
    
    // MARK: - Public Methods
    
    /// Load settings from storage
    func loadSettings() {
        // Load dark mode preference
        if let darkMode: Bool = try? storageManager.load(Bool.self, forKey: Constants.StorageKeys.darkModeEnabled) {
            isDarkModeEnabled = darkMode
        }
        
        // Load notifications preference
        if let notifications: Bool = try? storageManager.load(Bool.self, forKey: Constants.StorageKeys.notificationsEnabled) {
            notificationsEnabled = notifications
        }
        
        // Load haptic feedback preference
        if let haptics: Bool = try? storageManager.load(Bool.self, forKey: Constants.StorageKeys.hapticFeedbackEnabled) {
            hapticFeedbackEnabled = haptics
        }
    }
    
    /// Save settings to storage
    func saveSettings() {
        try? storageManager.save(isDarkModeEnabled, forKey: Constants.StorageKeys.darkModeEnabled)
        try? storageManager.save(notificationsEnabled, forKey: Constants.StorageKeys.notificationsEnabled)
        try? storageManager.save(hapticFeedbackEnabled, forKey: Constants.StorageKeys.hapticFeedbackEnabled)
    }
    
    /// Toggle dark mode
    func toggleDarkMode() {
        isDarkModeEnabled.toggle()
        saveSettings()
    }
    
    /// Toggle notifications
    func toggleNotifications() {
        notificationsEnabled.toggle()
        saveSettings()
    }
    
    /// Toggle haptic feedback
    func toggleHapticFeedback() {
        hapticFeedbackEnabled.toggle()
        saveSettings()
    }
    
    /// Build settings sections
    func buildSections() {
        sections = [
            SettingsSection(
                title: "Appearance",
                options: [
                    SettingsOption(
                        title: "Dark Mode",
                        iconName: "moon.fill",
                        type: .toggle(Binding(
                            get: { self.isDarkModeEnabled },
                            set: { _ in self.toggleDarkMode() }
                        ))
                    )
                ]
            ),
            SettingsSection(
                title: "Notifications",
                options: [
                    SettingsOption(
                        title: "Enable Notifications",
                        iconName: "bell.fill",
                        type: .toggle(Binding(
                            get: { self.notificationsEnabled },
                            set: { _ in self.toggleNotifications() }
                        ))
                    )
                ]
            ),
            SettingsSection(
                title: "Preferences",
                options: [
                    SettingsOption(
                        title: "Haptic Feedback",
                        iconName: "hand.tap.fill",
                        type: .toggle(Binding(
                            get: { self.hapticFeedbackEnabled },
                            set: { _ in self.toggleHapticFeedback() }
                        ))
                    )
                ]
            ),
            SettingsSection(
                title: "About",
                options: [
                    SettingsOption(
                        title: "App Version",
                        iconName: "info.circle.fill",
                        type: .info(Constants.appVersion)
                    ),
                    SettingsOption(
                        title: "App Name",
                        iconName: "app.fill",
                        type: .info(Constants.appName)
                    )
                ]
            )
        ]
    }
}

