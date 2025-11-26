//
//  FavoriteItem.swift
//  Psychosis
//
//  Created on [Current Date]
//

import Foundation

/// Favorite item model
struct FavoriteItem: Identifiable, Codable, Equatable {
    let id: UUID
    let title: String
    let description: String
    let iconName: String
    let category: String
    let addedDate: Date
    
    init(
        id: UUID = UUID(),
        title: String,
        description: String,
        iconName: String,
        category: String,
        addedDate: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.iconName = iconName
        self.category = category
        self.addedDate = addedDate
    }
}

