//
//  RemoteServerManager.swift
//  HubApp
//
//  Created on [Current Date]
//

import Foundation
import SwiftUI

@MainActor
class RemoteServerManager: ObservableObject {
    static let shared = RemoteServerManager()
    
    @Published var servers: [RemoteServer] = []
    
    private let userDefaults = UserDefaults.standard
    private let serversKey = "remoteServers"
    
    private init() {
        loadServers()
        
        // Add default servers if none exist
        if servers.isEmpty {
            servers = [
                RemoteServer(name: "fs-dev Ubuntu", host: "fs-dev.local", port: 5900, type: .ubuntu),
                RemoteServer(name: "Mac Studio", host: "mac-studio.local", port: 5900, type: .mac)
            ]
            saveServers()
        }
    }
    
    func addServer(_ server: RemoteServer) {
        servers.append(server)
        saveServers()
    }
    
    func updateServer(_ server: RemoteServer) {
        if let index = servers.firstIndex(where: { $0.id == server.id }) {
            servers[index] = server
            saveServers()
        }
    }
    
    func deleteServer(_ server: RemoteServer) {
        servers.removeAll { $0.id == server.id }
        saveServers()
    }
    
    func deleteServer(at indexSet: IndexSet) {
        servers.remove(atOffsets: indexSet)
        saveServers()
    }
    
    private func saveServers() {
        if let encoded = try? JSONEncoder().encode(servers) {
            userDefaults.set(encoded, forKey: serversKey)
        }
    }
    
    private func loadServers() {
        if let data = userDefaults.data(forKey: serversKey),
           let decoded = try? JSONDecoder().decode([RemoteServer].self, from: data) {
            servers = decoded
        }
    }
}

