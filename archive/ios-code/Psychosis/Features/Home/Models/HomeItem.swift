//
//  HomeItem.swift
//  Psychosis
//
//  Created on [Current Date]
//

import Foundation

/// Model representing an item on the home screen
struct HomeItem: Identifiable, Codable, Equatable {
    let id: UUID
    let title: String
    let description: String
    let iconName: String
    let timestamp: Date
    
    init(
        id: UUID = UUID(),
        title: String,
        description: String,
        iconName: String,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.iconName = iconName
        self.timestamp = timestamp
    }
}

