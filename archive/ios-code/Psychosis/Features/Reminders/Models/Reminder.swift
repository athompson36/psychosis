//
//  Reminder.swift
//  Psychosis
//
//  Created on [Current Date]
//

import Foundation

/// Reminder model
struct Reminder: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var description: String
    var dueDate: Date
    var isCompleted: Bool
    var priority: ReminderPriority
    var category: String
    var createdAt: Date
    var completedAt: Date?
    
    init(
        id: UUID = UUID(),
        title: String,
        description: String = "",
        dueDate: Date,
        isCompleted: Bool = false,
        priority: ReminderPriority = .normal,
        category: String = "General",
        createdAt: Date = Date(),
        completedAt: Date? = nil
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.dueDate = dueDate
        self.isCompleted = isCompleted
        self.priority = priority
        self.category = category
        self.createdAt = createdAt
        self.completedAt = completedAt
    }
}

enum ReminderPriority: String, Codable, CaseIterable {
    case low = "Low"
    case normal = "Normal"
    case high = "High"
    
    var color: String {
        switch self {
        case .low: return "blue"
        case .normal: return "orange"
        case .high: return "red"
        }
    }
    
    var iconName: String {
        switch self {
        case .low: return "arrow.down.circle"
        case .normal: return "minus.circle"
        case .high: return "exclamationmark.circle.fill"
        }
    }
}

