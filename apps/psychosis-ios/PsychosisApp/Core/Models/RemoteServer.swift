//
//  RemoteServer.swift
//  PsychosisApp
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
    let username: String?
    let password: String?
    let useSSL: Bool
    let connectionPath: String? // Custom path like /vnc.html, /remote, etc.
    
    init(
        id: UUID = UUID(),
        name: String,
        host: String,
        port: Int = 5900,
        type: ServerType,
        autoConnect: Bool = false,
        username: String? = nil,
        password: String? = nil,
        useSSL: Bool = false,
        connectionPath: String? = nil
    ) {
        self.id = id
        self.name = name
        self.host = host
        self.port = port
        self.type = type
        self.autoConnect = autoConnect
        self.username = username
        self.password = password
        self.useSSL = useSSL
        self.connectionPath = connectionPath
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

