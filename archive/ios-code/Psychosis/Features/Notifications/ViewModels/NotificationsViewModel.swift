//
//  NotificationsViewModel.swift
//  Psychosis
//
//  Created on [Current Date]
//

import Foundation

/// ViewModel for Notifications screen
@Observable
final class NotificationsViewModel {
    // MARK: - Properties
    
    var notifications: [NotificationItem] = []
    var isLoading = false
    var errorMessage: String?
    var unreadCount: Int {
        notifications.filter { !$0.isRead }.count
    }
    
    // MARK: - Dependencies
    
    private let storageManager: StorageManager
    
    // MARK: - Initialization
    
    init(storageManager: StorageManager = DefaultStorageManager()) {
        self.storageManager = storageManager
    }
    
    // MARK: - Public Methods
    
    /// Load notifications
    @MainActor
    func loadNotifications() async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds
            
            // Try to load from storage
            if let saved: [NotificationItem] = try? storageManager.load([NotificationItem].self, forKey: Constants.StorageKeys.notifications) {
                notifications = saved
            } else {
                // Create sample notifications
                notifications = createSampleNotifications()
                try? saveNotifications()
            }
            
            isLoading = false
        } catch {
            errorMessage = "Failed to load notifications: \(error.localizedDescription)"
            isLoading = false
        }
    }
    
    /// Mark notification as read
    func markAsRead(_ notification: NotificationItem) {
        guard let index = notifications.firstIndex(where: { $0.id == notification.id }) else { return }
        notifications[index].isRead = true
        try? saveNotifications()
    }
    
    /// Mark all as read
    func markAllAsRead() {
        for index in notifications.indices {
            notifications[index].isRead = true
        }
        try? saveNotifications()
    }
    
    /// Delete notification
    func deleteNotification(_ notification: NotificationItem) {
        notifications.removeAll { $0.id == notification.id }
        try? saveNotifications()
    }
    
    /// Clear all notifications
    func clearAll() {
        notifications.removeAll()
        try? saveNotifications()
    }
    
    /// Add sample notification
    func addSampleNotification() {
        let newNotification = NotificationItem(
            title: "New Notification",
            message: "This is a sample notification",
            type: .info
        )
        notifications.insert(newNotification, at: 0)
        try? saveNotifications()
    }
    
    // MARK: - Private Methods
    
    private func createSampleNotifications() -> [NotificationItem] {
        [
            NotificationItem(
                title: "Welcome!",
                message: "Thanks for using Psychosis",
                type: .success,
                timestamp: Date().addingTimeInterval(-3600)
            ),
            NotificationItem(
                title: "Update Available",
                message: "New features are available",
                type: .info,
                timestamp: Date().addingTimeInterval(-7200)
            ),
            NotificationItem(
                title: "Reminder",
                message: "Don't forget to check your profile",
                type: .warning,
                timestamp: Date().addingTimeInterval(-86400)
            )
        ]
    }
    
    private func saveNotifications() throws {
        try storageManager.save(notifications, forKey: Constants.StorageKeys.notifications)
    }
}

