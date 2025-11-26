//
//  Note.swift
//  Psychosis
//
//  Created on [Current Date]
//

import Foundation

/// Note model
struct Note: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var content: String
    var createdAt: Date
    var updatedAt: Date
    var isPinned: Bool
    var tags: [String]
    var color: NoteColor
    
    init(
        id: UUID = UUID(),
        title: String,
        content: String = "",
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        isPinned: Bool = false,
        tags: [String] = [],
        color: NoteColor = .yellow
    ) {
        self.id = id
        self.title = title
        self.content = content
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.isPinned = isPinned
        self.tags = tags
        self.color = color
    }
}

enum NoteColor: String, Codable, CaseIterable {
    case yellow = "Yellow"
    case blue = "Blue"
    case green = "Green"
    case pink = "Pink"
    case purple = "Purple"
    case orange = "Orange"
    
    var colorValue: String {
        rawValue.lowercased()
    }
}

