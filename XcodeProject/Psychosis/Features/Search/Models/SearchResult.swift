//
//  SearchResult.swift
//  Psychosis
//
//  Created on [Current Date]
//

import Foundation

/// Search result model
struct SearchResult: Identifiable, Codable, Equatable {
    let id: UUID
    let title: String
    let description: String
    let category: SearchCategory
    let iconName: String
    let timestamp: Date
    
    init(
        id: UUID = UUID(),
        title: String,
        description: String,
        category: SearchCategory,
        iconName: String,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.category = category
        self.iconName = iconName
        self.timestamp = timestamp
    }
}

enum SearchCategory: String, Codable, CaseIterable {
    case all = "All"
    case home = "Home"
    case settings = "Settings"
    case profile = "Profile"
    case detail = "Detail"
}

