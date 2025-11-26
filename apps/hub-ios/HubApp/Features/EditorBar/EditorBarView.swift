//
//  EditorBarView.swift
//  HubApp
//
//  Created on [Current Date]
//

import SwiftUI

struct EditorBarView: View {
    @Binding var selectedTool: String
    let connectionStatus: String
    
    let tools = [
        ("dev-remote", "⚡", "Dev Remote"),
        ("vscode", "📝", "VS Code"),
        ("xcode", "🔨", "Xcode")
    ]
    
    var body: some View {
        HStack(spacing: 16) {
            // Tool Selector
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
            .frame(maxWidth: 150)
            
            Spacer()
            
            // Title
            Text("Psychosis")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color(hex: "00d4ff"), Color(hex: "7b2cbf")],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
            
            Spacer()
            
            // Connection Status
            HStack(spacing: 6) {
                Circle()
                    .fill(connectionStatus == "connected" ? Color.green : Color.red)
                    .frame(width: 8, height: 8)
                
                Text(connectionStatus.capitalized)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Settings Button
            Button(action: {}) {
                Image(systemName: "gearshape.fill")
                    .font(.title3)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(12)
        .padding(.horizontal)
        .padding(.top, 8)
    }
}

#Preview {
    EditorBarView(selectedTool: .constant("dev-remote"), connectionStatus: "connected")
        .background(Color.black)
}

