//
//  ConnectionHistoryManager.swift
//  PsychosisApp
//
//  Created on [Current Date]
//

import Foundation

@MainActor
class ConnectionHistoryManager: ObservableObject {
    static let shared = ConnectionHistoryManager()
    
    @Published var recentConnections: [ConnectionHistoryEntry] = []
    
    private let userDefaults = UserDefaults.standard
    private let historyKey = "connectionHistory"
    private let maxHistoryEntries = 20
    
    private init() {
        loadHistory()
    }
    
    func addConnection(_ server: RemoteServer, success: Bool, duration: TimeInterval? = nil) {
        let entry = ConnectionHistoryEntry(
            serverId: server.id,
            serverName: server.name,
            host: server.host,
            timestamp: Date(),
            success: success,
            duration: duration
        )
        
        // Remove old entry for same server if exists
        recentConnections.removeAll { $0.serverId == server.id }
        
        // Add new entry at beginning
        recentConnections.insert(entry, at: 0)
        
        // Limit history size
        if recentConnections.count > maxHistoryEntries {
            recentConnections = Array(recentConnections.prefix(maxHistoryEntries))
        }
        
        saveHistory()
    }
    
    func getRecentConnections(for serverId: UUID) -> [ConnectionHistoryEntry] {
        return recentConnections.filter { $0.serverId == serverId }
    }
    
    func clearHistory() {
        recentConnections.removeAll()
        saveHistory()
    }
    
    private func saveHistory() {
        if let encoded = try? JSONEncoder().encode(recentConnections) {
            userDefaults.set(encoded, forKey: historyKey)
        }
    }
    
    private func loadHistory() {
        if let data = userDefaults.data(forKey: historyKey),
           let decoded = try? JSONDecoder().decode([ConnectionHistoryEntry].self, from: data) {
            recentConnections = decoded
        }
    }
}

struct ConnectionHistoryEntry: Identifiable, Codable {
    let id: UUID
    let serverId: UUID
    let serverName: String
    let host: String
    let timestamp: Date
    let success: Bool
    let duration: TimeInterval?
    
    init(id: UUID = UUID(), serverId: UUID, serverName: String, host: String, timestamp: Date, success: Bool, duration: TimeInterval? = nil) {
        self.id = id
        self.serverId = serverId
        self.serverName = serverName
        self.host = host
        self.timestamp = timestamp
        self.success = success
        self.duration = duration
    }
}

