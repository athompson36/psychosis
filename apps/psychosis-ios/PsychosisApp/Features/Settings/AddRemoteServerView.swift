//
//  AddRemoteServerView.swift
//  PsychosisApp
//
//  Created on [Current Date]
//

import SwiftUI

struct AddRemoteServerView: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var name: String = ""
    @State private var host: String = ""
    @State private var port: String = "5900"
    @State private var selectedType: ServerType = .ubuntu
    @State private var autoConnect: Bool = false
    
    let existingServer: RemoteServer?
    let onSave: (RemoteServer) -> Void
    
    init(existingServer: RemoteServer? = nil, onSave: @escaping (RemoteServer) -> Void) {
        self.existingServer = existingServer
        self.onSave = onSave
        
        if let server = existingServer {
            _name = State(initialValue: server.name)
            _host = State(initialValue: server.host)
            _port = State(initialValue: String(server.port))
            _selectedType = State(initialValue: server.type)
            _autoConnect = State(initialValue: server.autoConnect)
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Server Information")) {
                    TextField("Server Name", text: $name)
                        .textContentType(.none)
                        .autocapitalization(.words)
                    
                    TextField("Host", text: $host)
                        .textContentType(.none)
                        .autocapitalization(.none)
                        .keyboardType(.URL)
                    
                    TextField("Port", text: $port)
                        .textContentType(.none)
                        .keyboardType(.numberPad)
                }
                
                Section(header: Text("Server Type")) {
                    Picker("Type", selection: $selectedType) {
                        ForEach(ServerType.allCases, id: \.self) { type in
                            HStack {
                                Text(type.icon)
                                Text(type.rawValue)
                            }
                            .tag(type)
                        }
                    }
                }
                
                Section(header: Text("Connection")) {
                    Toggle("Auto-connect", isOn: $autoConnect)
                }
                
                Section {
                    Button(action: saveServer) {
                        HStack {
                            Spacer()
                            Text(existingServer == nil ? "Add Server" : "Save Changes")
                                .fontWeight(.semibold)
                            Spacer()
                        }
                    }
                    .disabled(!isValid)
                }
            }
            .navigationTitle(existingServer == nil ? "Add Remote Server" : "Edit Server")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        !host.trimmingCharacters(in: .whitespaces).isEmpty &&
        !port.trimmingCharacters(in: .whitespaces).isEmpty &&
        Int(port) != nil
    }
    
    private func saveServer() {
        guard let portInt = Int(port) else { return }
        
        let server: RemoteServer
        if let existing = existingServer {
            server = RemoteServer(
                id: existing.id,
                name: name.trimmingCharacters(in: .whitespaces),
                host: host.trimmingCharacters(in: .whitespaces),
                port: portInt,
                type: selectedType,
                autoConnect: autoConnect
            )
        } else {
            server = RemoteServer(
                name: name.trimmingCharacters(in: .whitespaces),
                host: host.trimmingCharacters(in: .whitespaces),
                port: portInt,
                type: selectedType,
                autoConnect: autoConnect
            )
        }
        
        onSave(server)
        dismiss()
    }
}

#Preview {
    AddRemoteServerView { server in
        print("Saved: \(server)")
    }
}

