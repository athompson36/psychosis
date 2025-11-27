//
//  RemoteDesktopViewV2.swift
//  PsychosisApp
//
//  Native VNC-based remote desktop view
//

import SwiftUI

struct RemoteDesktopViewV2: View {
    let remoteServer: RemoteServer
    @Binding var selectedPane: CursorPane
    @StateObject private var vncConnection = VNCConnection()
    @State private var paneController: CursorPaneController?
    @State private var showOverlay: Bool = true
    
    init(remoteServer: RemoteServer, selectedPane: Binding<CursorPane>) {
        self.remoteServer = remoteServer
        self._selectedPane = selectedPane
    }
    
    var body: some View {
        ZStack {
            // Native VNC View
            NativeVNCView(connection: vncConnection)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Liquid Glass Overlay
            if showOverlay {
                LiquidGlassOverlay(selectedPane: $selectedPane) { pane in
                    Task {
                        if let controller = paneController {
                            switch pane {
                            case .editor:
                                await controller.switchToEditor()
                            case .files:
                                await controller.switchToFiles()
                            case .chat:
                                await controller.switchToChat()
                            case .terminal:
                                await controller.switchToTerminal()
                            }
                        }
                    }
                }
                .transition(.opacity)
                .allowsHitTesting(true) // Allow touches on overlay buttons
                .background(Color.clear) // Make non-button areas transparent to touches
            }
            
            // Connection Status Overlay
            if vncConnection.isConnecting {
                VStack(spacing: 16) {
                    ProgressView()
                        .scaleEffect(1.5)
                        .tint(.white)
                    Text("Connecting to \(remoteServer.name)...")
                        .font(.headline)
                        .foregroundColor(.white)
                }
                .padding()
                .background(Color.black.opacity(0.8))
                .cornerRadius(12)
            }
            
            if let error = vncConnection.errorMessage {
                VStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.title)
                        .foregroundColor(.red)
                    Text("Connection Error")
                        .font(.headline)
                        .foregroundColor(.white)
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding()
                .background(Color.black.opacity(0.8))
                .cornerRadius(12)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
        .onAppear {
            print("🖥️ RemoteDesktopViewV2 appeared for server: \(remoteServer.name)")
            connectToServer()
        }
        .onDisappear {
            print("🖥️ RemoteDesktopViewV2 disappeared")
            vncConnection.disconnect()
        }
        .onChange(of: remoteServer.id) { oldId, newId in
            print("🔄 Server changed from \(oldId) to \(newId)")
            connectToServer()
        }
        .onChange(of: selectedPane) { oldPane, newPane in
            Task {
                if let controller = paneController {
                    switch newPane {
                    case .editor:
                        await controller.switchToEditor()
                    case .files:
                        await controller.switchToFiles()
                    case .chat:
                        await controller.switchToChat()
                    case .terminal:
                        await controller.switchToTerminal()
                    }
                }
            }
        }
    }
    
    private func connectToServer() {
        print("🔌 connectToServer() called for: \(remoteServer.name) (\(remoteServer.host):\(remoteServer.port))")
        
        // Disconnect any existing connection first
        if vncConnection.isConnected || vncConnection.isConnecting {
            print("⚠️ Disconnecting existing connection first")
            vncConnection.disconnect()
            // Wait a moment for cleanup
            Task {
                try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
                await performConnection()
            }
        } else {
            Task {
                await performConnection()
            }
        }
    }
    
    private func performConnection() async {
        // Create pane controller
        paneController = CursorPaneController(vncConnection: vncConnection)
        
        do {
            // Use port 5900 for direct VNC connection
            let port = remoteServer.port == 6080 ? 5900 : remoteServer.port
            
            print("🔌 Attempting VNC connection to \(remoteServer.host):\(port)")
            
            try await vncConnection.connect(
                host: remoteServer.host,
                port: port,
                password: remoteServer.password ?? ""
            )
            
            print("✅ Connected to VNC server: \(remoteServer.name)")
        } catch {
            print("❌ Failed to connect: \(error.localizedDescription)")
            vncConnection.errorMessage = error.localizedDescription
        }
    }
}

