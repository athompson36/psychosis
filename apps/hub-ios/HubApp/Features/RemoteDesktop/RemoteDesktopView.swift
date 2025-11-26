//
//  RemoteDesktopView.swift
//  Psychosis
//
//  Created on [Current Date]
//

import SwiftUI

struct RemoteDesktopView: View {
    let remoteServer: RemoteServer
    @State private var isConnected: Bool = false
    @State private var connectionError: String?
    
    var body: some View {
        VStack(spacing: 0) {
            // Connection Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(remoteServer.name)
                        .font(.headline)
                    
                    Text(remoteServer.host)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
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
                
                if !isConnected {
                    Button("Connect") {
                        connectToServer()
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding()
            .background(.ultraThinMaterial)
            
            Divider()
            
            // Remote Cursor Chat Interface
            ZStack {
                Color.black
                
                if isConnected {
                    // Remote Cursor chat interface would be displayed here
                    // This would be a web view or remote desktop stream showing Cursor's chat
                    VStack(spacing: 16) {
                        Image(systemName: "cursorarrow.click")
                            .font(.system(size: 60))
                            .foregroundColor(.white.opacity(0.5))
                        
                        Text("Cursor Chat")
                            .font(.title2)
                            .foregroundColor(.white)
                        
                        Text("Remote desktop view of Cursor chat interface")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                            .multilineTextAlignment(.center)
                        
                        Text("Connected to: \(remoteServer.name)")
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.5))
                    }
                    .padding()
                } else {
                    VStack(spacing: 16) {
                        Image(systemName: "display.trianglebadge.exclamationmark")
                            .font(.system(size: 60))
                            .foregroundColor(.white.opacity(0.5))
                        
                        Text("Not Connected")
                            .font(.title2)
                            .foregroundColor(.white)
                        
                        if let error = connectionError {
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.red)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        
                        Button("Connect to \(remoteServer.name)") {
                            connectToServer()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(.ultraThinMaterial)
        .cornerRadius(12)
        .onAppear {
            // Auto-connect on appear if configured
            if remoteServer.autoConnect {
                connectToServer()
            }
        }
    }
    
    private func connectToServer() {
        isConnected = false
        connectionError = nil
        
        Task {
            // TODO: Implement actual remote desktop connection
            // This would connect via VNC, RDP, or a custom protocol
            // to the remote server running Cursor
            
            // Simulate connection
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            
            await MainActor.run {
                // For now, simulate successful connection
                // In production, this would check actual connection status
                isConnected = true
            }
        }
    }
}


#Preview {
    RemoteDesktopView(remoteServer: RemoteServer(
        name: "fs-dev Ubuntu",
        host: "fs-dev.local",
        type: .ubuntu
    ))
    .background(Color.black)
}


