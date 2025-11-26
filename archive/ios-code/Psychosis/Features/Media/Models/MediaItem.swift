//
//  MediaItem.swift
//  Psychosis
//
//  Created on [Current Date]
//

import Foundation

/// Media item model
struct MediaItem: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var description: String
    var imageURL: URL?
    var thumbnailURL: URL?
    var mediaType: MediaType
    var fileSize: Int64 // in bytes
    var createdAt: Date
    var tags: [String]
    var isFavorite: Bool
    
    init(
        id: UUID = UUID(),
        title: String,
        description: String = "",
        imageURL: URL? = nil,
        thumbnailURL: URL? = nil,
        mediaType: MediaType = .image,
        fileSize: Int64 = 0,
        createdAt: Date = Date(),
        tags: [String] = [],
        isFavorite: Bool = false
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.imageURL = imageURL
        self.thumbnailURL = thumbnailURL
        self.mediaType = mediaType
        self.fileSize = fileSize
        self.createdAt = createdAt
        self.tags = tags
        self.isFavorite = isFavorite
    }
}

enum MediaType: String, Codable, CaseIterable {
    case image = "Image"
    case video = "Video"
    case audio = "Audio"
    case document = "Document"
    
    var iconName: String {
        switch self {
        case .image: return "photo"
        case .video: return "video"
        case .audio: return "music.note"
        case .document: return "doc"
        }
    }
}

