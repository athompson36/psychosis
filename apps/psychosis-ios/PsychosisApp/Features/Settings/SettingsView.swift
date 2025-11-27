//
//  SettingsView.swift
//  PsychosisApp
//
//  Created on [Current Date]
//

import SwiftUI

struct SettingsView: View {
    @State private var showAddServerSheet: Bool = false
    @State private var serverToEdit: RemoteServer?
    @Environment(\.dismiss) var dismiss
    
    let onConnect: ((RemoteServer) -> Void)?
    
    private var serverManager: RemoteServerManager {
        RemoteServerManager.shared
    }
    
    init(onConnect: ((RemoteServer) -> Void)? = nil) {
        self.onConnect = onConnect
    }
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Remote Servers")) {
                    ForEach(serverManager.servers) { server in
                        HStack {
                            Text(server.type.icon)
                            VStack(alignment: .leading, spacing: 4) {
                                Text(server.name)
                                    .font(.headline)
                                Text("\(server.host):\(server.port)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            HStack(spacing: 12) {
                                // Connect Button
                                Button(action: {
                                    if let latestServer = serverManager.servers.first(where: { $0.id == server.id }) {
                                        // Call the connect callback if provided
                                        onConnect?(latestServer)
                                        // Dismiss settings sheet
                                        dismiss()
                                    }
                                }) {
                                    HStack(spacing: 4) {
                                        Image(systemName: "play.circle.fill")
                                        Text("Connect")
                                            .font(.caption)
                                    }
                                    .foregroundColor(.green)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(Color.green.opacity(0.15))
                                    .cornerRadius(6)
                                }
                                .buttonStyle(.plain)
                                
                                // Edit Button
                                Button(action: {
                                    if let latestServer = serverManager.servers.first(where: { $0.id == server.id }) {
                                        serverToEdit = latestServer
                                        showAddServerSheet = true
                                    }
                                }) {
                                    Image(systemName: "pencil")
                                        .foregroundColor(.blue)
                                        .font(.caption)
                                        .padding(6)
                                        .background(Color.blue.opacity(0.15))
                                        .cornerRadius(6)
                                }
                                .buttonStyle(.plain)
                                
                                if server.autoConnect {
                                    Image(systemName: "bolt.fill")
                                        .foregroundColor(.yellow)
                                        .font(.caption)
                                }
                            }
                        }
                        .contentShape(Rectangle())
                    }
                    .onDelete { indexSet in
                        serverManager.deleteServer(at: indexSet)
                    }
                    
                    Button(action: {
                        serverToEdit = nil
                        showAddServerSheet = true
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Add Server")
                        }
                        .foregroundColor(.blue)
                    }
                }
                
                Section(header: Text("Connection")) {
                    HStack {
                        Text("Connection Timeout")
                        Spacer()
                        Text("5 seconds")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Auto-reconnect")
                        Spacer()
                        Toggle("", isOn: .constant(true))
                    }
                }
                
                Section(header: Text("History")) {
                    NavigationLink(destination: RecentConnectionsView { serverId in
                        // Navigate to server or connect
                        print("Selected server: \(serverId)")
                    }) {
                        HStack {
                            Image(systemName: "clock.arrow.circlepath")
                            Text("Recent Connections")
                        }
                    }
                }
                
                Section(header: Text("About")) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Build")
                        Spacer()
                        Text("1")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showAddServerSheet) {
                ServerFormView(serverToEdit: serverToEdit) { server in
                    if serverToEdit != nil {
                        serverManager.updateServer(server)
                    } else {
                        serverManager.addServer(server)
                    }
                    // Clear serverToEdit after saving
                    serverToEdit = nil
                }
                .id(serverToEdit?.id ?? UUID()) // Force recreation when serverToEdit changes
            }
            .onChange(of: showAddServerSheet) { oldValue, newValue in
                // Clear serverToEdit when sheet is dismissed
                if !newValue {
                    serverToEdit = nil
                }
            }
        }
    }
}

#Preview {
    SettingsView { server in
        print("Connect to: \(server.name)")
    }
}

