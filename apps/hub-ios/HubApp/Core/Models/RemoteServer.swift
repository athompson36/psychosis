//
//  RemoteServer.swift
//  HubApp
//
//  Created on [Current Date]
//

import Foundation

struct RemoteServer: Identifiable, Hashable, Codable {
    let id: UUID
    let name: String
    let host: String
    let port: Int
    let type: ServerType
    let autoConnect: Bool
    
    init(id: UUID = UUID(), name: String, host: String, port: Int = 5900, type: ServerType, autoConnect: Bool = false) {
        self.id = id
        self.name = name
        self.host = host
        self.port = port
        self.type = type
        self.autoConnect = autoConnect
    }
}

enum ServerType: String, CaseIterable, Codable {
    case ubuntu = "Ubuntu"
    case mac = "macOS"
    
    var icon: String {
        switch self {
        case .ubuntu: return "🖥️"
        case .mac: return "💻"
        }
    }
}

