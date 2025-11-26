//
//  RecentConnectionsView.swift
//  HubApp
//
//  Created on [Current Date]
//

import SwiftUI

struct RecentConnectionsView: View {
    @StateObject private var historyManager = ConnectionHistoryManager.shared
    let onSelectServer: (UUID) -> Void
    
    var body: some View {
        List {
            if historyManager.recentConnections.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.system(size: 50))
                        .foregroundColor(.secondary)
                    
                    Text("No Recent Connections")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text("Connection history will appear here")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding()
            } else {
                ForEach(historyManager.recentConnections) { entry in
                    HStack {
                        Image(systemName: entry.success ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundColor(entry.success ? .green : .red)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(entry.serverName)
                                .font(.headline)
                            
                            Text(entry.host)
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            HStack(spacing: 8) {
                                Text(entry.timestamp, style: .relative)
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                
                                if let duration = entry.duration {
                                    Text("• \(formatDuration(duration))")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            onSelectServer(entry.serverId)
                        }) {
                            Image(systemName: "arrow.right.circle.fill")
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .navigationTitle("Recent Connections")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if !historyManager.recentConnections.isEmpty {
                    Button("Clear") {
                        historyManager.clearHistory()
                    }
                    .foregroundColor(.red)
                }
            }
        }
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        if duration < 60 {
            return "\(Int(duration))s"
        } else if duration < 3600 {
            return "\(Int(duration / 60))m"
        } else {
            return "\(Int(duration / 3600))h"
        }
    }
}

#Preview {
    NavigationView {
        RecentConnectionsView { serverId in
            print("Selected: \(serverId)")
        }
    }
}

