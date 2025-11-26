//
//  RemoteDesktopView.swift
//  Psychosis
//
//  Created on [Current Date]
//

import SwiftUI

struct RemoteDesktopView: View {
    @State private var selectedTool: String = "dev-remote"
    @State private var isConnected: Bool = false
    
    let tools = [
        ("dev-remote", "⚡", "Dev Remote"),
        ("vscode", "📝", "VS Code"),
        ("xcode", "🔨", "Xcode")
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Tool Selector
            HStack {
                Picker("Tool", selection: $selectedTool) {
                    ForEach(tools, id: \.0) { tool in
                        HStack {
                            Text(tool.1)
                            Text(tool.2)
                        }
                        .tag(tool.0)
                    }
                }
                .pickerStyle(.menu)
                
                Spacer()
                
                // Connection Status
                HStack(spacing: 6) {
                    Circle()
                        .fill(isConnected ? Color.green : Color.red)
                        .frame(width: 8, height: 8)
                    
                    Text(isConnected ? "Connected" : "Disconnected")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(.ultraThinMaterial)
            
            Divider()
            
            // Remote Screen Area
            ZStack {
                Color.black
                
                if isConnected {
                    // Remote screen would be displayed here
                    VStack(spacing: 16) {
                        Image(systemName: "display")
                            .font(.system(size: 60))
                            .foregroundColor(.white.opacity(0.5))
                        
                        Text("Remote Desktop")
                            .font(.title2)
                            .foregroundColor(.white)
                        
                        Text("\(selectedTool) screen would appear here")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                    }
                } else {
                    VStack(spacing: 16) {
                        Image(systemName: "display.trianglebadge.exclamationmark")
                            .font(.system(size: 60))
                            .foregroundColor(.white.opacity(0.5))
                        
                        Text("Not Connected")
                            .font(.title2)
                            .foregroundColor(.white)
                        
                        Button("Connect") {
                            // TODO: Implement connection
                            isConnected = true
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(.ultraThinMaterial)
        .cornerRadius(12)
    }
}

#Preview {
    RemoteDesktopView()
        .background(Color.black)
}

