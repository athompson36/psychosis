//
//  SettingsView.swift
//  PsychosisApp
//
//  Created on [Current Date]
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var serverManager = RemoteServerManager.shared
    @State private var showAddServerSheet: Bool = false
    @State private var serverToEdit: RemoteServer?
    
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
                            
                            if server.autoConnect {
                                Image(systemName: "bolt.fill")
                                    .foregroundColor(.yellow)
                                    .font(.caption)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            // Get the latest server from manager to ensure we have the most up-to-date data
                            if let latestServer = serverManager.servers.first(where: { $0.id == server.id }) {
                                serverToEdit = latestServer
                                showAddServerSheet = true
                            }
                        }
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
            .onChange(of: showAddServerSheet) { isPresented in
                // Clear serverToEdit when sheet is dismissed
                if !isPresented {
                    serverToEdit = nil
                }
            }
        }
    }
}

#Preview {
    SettingsView()
}

