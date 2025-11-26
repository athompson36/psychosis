//
//  FileItem.swift
//  HubApp
//
//  Created on [Current Date]
//

import Foundation

struct FileItem: Identifiable, Codable {
    let id: UUID
    let name: String
    let path: String
    let type: FileType
    var content: String?
    
    init(id: UUID = UUID(), name: String, path: String, type: FileType, content: String? = nil) {
        self.id = id
        self.name = name
        self.path = path
        self.type = type
        self.content = content
    }
}

enum FileType: String, Codable {
    case file
    case directory
}

