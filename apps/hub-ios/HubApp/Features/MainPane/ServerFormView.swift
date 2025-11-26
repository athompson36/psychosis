//
//  ServerFormView.swift
//  Psychosis
//
//  Created on [Current Date]
//

import SwiftUI

struct ServerFormView: View {
    @Environment(\.dismiss) var dismiss
    
    let serverToEdit: RemoteServer?
    let onSave: (RemoteServer) -> Void
    
    @State private var name: String = ""
    @State private var host: String = ""
    @State private var port: String = "6080"
    @State private var type: ServerType = .ubuntu
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var useSSL: Bool = false
    @State private var connectionPath: String = "/vnc.html"
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Server Information")) {
                    TextField("Server Name", text: $name)
                        .textContentType(.none)
                        .autocapitalization(.words)
                    
                    TextField("Host or IP Address", text: $host)
                        .keyboardType(.URL)
                        .autocapitalization(.none)
                        .textContentType(.URL)
                    
                    TextField("Port", text: $port)
                        .keyboardType(.numberPad)
                        .textContentType(.none)
                    
                    Picker("Server Type", selection: $type) {
                        ForEach(ServerType.allCases, id: \.self) { serverType in
                            HStack {
                                Text(serverType.icon)
                                Text(serverType.rawValue)
                            }
                            .tag(serverType)
                        }
                    }
                }
                
                Section(header: Text("Connection Settings")) {
                    Toggle("Use SSL/HTTPS", isOn: $useSSL)
                    
                    TextField("Connection Path (e.g., /vnc.html)", text: $connectionPath)
                        .keyboardType(.default)
                        .autocapitalization(.none)
                        .textContentType(.none)
                }
                
                Section(header: Text("Authentication (Optional)")) {
                    TextField("Username", text: $username)
                        .keyboardType(.default)
                        .autocapitalization(.none)
                        .textContentType(.username)
                    
                    SecureField("Password", text: $password)
                        .textContentType(.password)
                }
                
                Section {
                    Button("Save") {
                        saveServer()
                    }
                    .disabled(name.isEmpty || host.isEmpty || Int(port) == nil)
                }
            }
            .navigationTitle(serverToEdit == nil ? "Add Server" : "Edit Server")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                loadServerData()
            }
        }
    }
    
    private func loadServerData() {
        if let existing = serverToEdit {
            name = existing.name
            host = existing.host
            port = String(existing.port)
            type = existing.type
            username = existing.username ?? ""
            password = existing.password ?? ""
            useSSL = existing.useSSL
            connectionPath = existing.connectionPath ?? "/vnc.html"
        } else {
            // Initialize with defaults for new server
            name = ""
            host = ""
            port = "6080"
            type = .ubuntu
            username = ""
            password = ""
            useSSL = false
            connectionPath = "/vnc.html"
        }
    }
    
    private func saveServer() {
        guard let portInt = Int(port), !name.isEmpty, !host.isEmpty else {
            return
        }
        
        let usernameValue = username.isEmpty ? nil : username
        let passwordValue = password.isEmpty ? nil : password
        let pathValue = connectionPath.isEmpty ? nil : connectionPath
        
        let server: RemoteServer
        if let existing = serverToEdit {
            server = RemoteServer(
                id: existing.id,
                name: name,
                host: host,
                port: portInt,
                type: type,
                autoConnect: existing.autoConnect,
                username: usernameValue,
                password: passwordValue,
                useSSL: useSSL,
                connectionPath: pathValue
            )
        } else {
            server = RemoteServer(
                name: name,
                host: host,
                port: portInt,
                type: type,
                username: usernameValue,
                password: passwordValue,
                useSSL: useSSL,
                connectionPath: pathValue
            )
        }
        
        onSave(server)
        dismiss()
    }
}

#Preview {
    ServerFormView(serverToEdit: nil) { server in
        print("Saved: \(server.name)")
    }
}

