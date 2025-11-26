//
//  SettingsView.swift
//  HubApp
//
//  Created on [Current Date]
//

import SwiftUI

struct SettingsView: View {
    @State private var remoteServers: [RemoteServer] = [
        RemoteServer(name: "fs-dev Ubuntu", host: "fs-dev.local", port: 5900, type: .ubuntu),
        RemoteServer(name: "Mac Studio", host: "mac-studio.local", port: 5900, type: .mac)
    ]
    @State private var showAddServerSheet: Bool = false
    @State private var serverToEdit: RemoteServer?
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Remote Servers")) {
                    ForEach(remoteServers) { server in
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
                            serverToEdit = server
                            showAddServerSheet = true
                        }
                    }
                    .onDelete { indexSet in
                        remoteServers.remove(atOffsets: indexSet)
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
                // Simple add server view
                NavigationView {
                    Form {
                        Section(header: Text("Server Information")) {
                            TextField("Server Name", text: .constant(serverToEdit?.name ?? ""))
                            TextField("Host", text: .constant(serverToEdit?.host ?? ""))
                            TextField("Port", text: .constant(serverToEdit != nil ? String(serverToEdit!.port) : "5900"))
                        }
                        Section {
                            Button("Save") {
                                showAddServerSheet = false
                            }
                        }
                    }
                    .navigationTitle(serverToEdit == nil ? "Add Server" : "Edit Server")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button("Cancel") {
                                showAddServerSheet = false
                            }
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    SettingsView()
}

