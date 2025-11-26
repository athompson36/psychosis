//
//  HistoryItem.swift
//  Psychosis
//
//  Created on [Current Date]
//

import Foundation

/// History item model
struct HistoryItem: Identifiable, Codable, Equatable {
    let id: UUID
    let title: String
    let description: String
    let iconName: String
    let action: String
    let timestamp: Date
    
    init(
        id: UUID = UUID(),
        title: String,
        description: String,
        iconName: String,
        action: String,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.iconName = iconName
        self.action = action
        self.timestamp = timestamp
    }
}

