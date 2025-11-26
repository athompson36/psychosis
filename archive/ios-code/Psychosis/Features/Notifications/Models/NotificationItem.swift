//
//  NotificationItem.swift
//  Psychosis
//
//  Created on [Current Date]
//

import Foundation

/// Notification model
struct NotificationItem: Identifiable, Codable, Equatable {
    let id: UUID
    let title: String
    let message: String
    let type: NotificationType
    let timestamp: Date
    var isRead: Bool
    
    init(
        id: UUID = UUID(),
        title: String,
        message: String,
        type: NotificationType,
        timestamp: Date = Date(),
        isRead: Bool = false
    ) {
        self.id = id
        self.title = title
        self.message = message
        self.type = type
        self.timestamp = timestamp
        self.isRead = isRead
    }
}

enum NotificationType: String, Codable, CaseIterable {
    case info = "Info"
    case success = "Success"
    case warning = "Warning"
    case error = "Error"
    
    var iconName: String {
        switch self {
        case .info: return "info.circle.fill"
        case .success: return "checkmark.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .error: return "xmark.circle.fill"
        }
    }
    
    var color: String {
        switch self {
        case .info: return "blue"
        case .success: return "green"
        case .warning: return "orange"
        case .error: return "red"
        }
    }
}

