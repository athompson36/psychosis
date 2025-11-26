//
//  DetailItem.swift
//  Psychosis
//
//  Created on [Current Date]
//

import Foundation

/// Model for detail view
struct DetailItem: Identifiable, Codable {
    let id: UUID
    let title: String
    let description: String
    let content: String
    let iconName: String
    let timestamp: Date
    
    init(
        id: UUID = UUID(),
        title: String,
        description: String,
        content: String,
        iconName: String,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.content = content
        self.iconName = iconName
        self.timestamp = timestamp
    }
}

