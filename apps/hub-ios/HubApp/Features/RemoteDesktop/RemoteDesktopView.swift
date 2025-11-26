//
//  RemoteDesktopView.swift
//  Psychosis
//
//  Created on [Current Date]
//

import SwiftUI
import WebKit

// MARK: - Remote Desktop View
struct RemoteDesktopView: View {
    let remoteServer: RemoteServer
    @StateObject private var connectionManager = ConnectionManager.shared
    @StateObject private var historyManager = ConnectionHistoryManager.shared
    @StateObject private var qualityMonitor = ConnectionQualityMonitor.shared
    @StateObject private var notificationManager = NotificationManager.shared
    @State private var isConnected: Bool = false
    @State private var isConnecting: Bool = false
    @State private var connectionError: String?
    @State private var connectionURL: URL?
    @State private var webViewIsLoading: Bool = false
    @State private var webViewError: String?
    @State private var connectionStartTime: Date?
    @State private var showKeyboard: Bool = false
    @State private var isFullscreen: Bool = false
    @State private var keyboardText: String = ""
    @State private var webViewReference: WKWebView?
    
    var body: some View {
        ZStack {
            // Remote Cursor Chat Interface - Full Screen Native View
            if isConnected, let url = connectionURL {
                // Full screen native view when connected
                ZStack {
                    // WebView fills entire space
                    WebViewWrapper(
                        url: url,
                        username: remoteServer.username,
                        password: remoteServer.password,
                        isLoading: $webViewIsLoading,
                        errorMessage: $webViewError,
                        onScreenshot: { webView in
                            webViewReference = webView
                        }
                    )
                    .opacity(webViewIsLoading ? 0.5 : 1.0)
                    
                    if webViewIsLoading {
                        ProgressView()
                            .scaleEffect(1.5)
                            .tint(.white)
                    }
                    
                    if let error = webViewError {
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
                .overlay(alignment: .topTrailing) {
                    // Minimal connection indicator overlay
                    HStack(spacing: 6) {
                        // Connection Quality Indicator
                        HStack(spacing: 4) {
                            Image(systemName: qualityMonitor.quality.icon)
                                .foregroundColor(qualityMonitor.quality.color)
                                .font(.caption2)
                            
                            if let latency = qualityMonitor.latency {
                                Text("\(Int(latency))ms")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .onChange(of: qualityMonitor.quality) { oldQuality, newQuality in
                            // Notify on quality degradation
                            if newQuality == .poor && oldQuality != .poor {
                                notificationManager.notifyQualityWarning(
                                    serverName: remoteServer.name,
                                    quality: newQuality.description
                                )
                            }
                        }
                    }
                    .padding(8)
                    .background(.ultraThinMaterial)
                    .cornerRadius(8)
                    .padding(8)
                    .opacity(0.7)
                    .onLongPressGesture {
                        // Show disconnect option on long press
                        disconnectFromServer()
                    }
                }
                .overlay(alignment: .bottom) {
                    // Virtual Keyboard Overlay
                    VirtualKeyboardView(
                        isVisible: $showKeyboard,
                        textInput: $keyboardText,
                        onSend: { input in
                            // Check if it's a key command or text
                            if input.hasPrefix("Ctrl+") || input == "Esc" || input == "Tab" || input == "Enter" {
                                sendKeyToRemote(input)
                            } else {
                                sendTextToRemote(input)
                            }
                        }
                    )
                }
            } else {
                // Connection UI (only shown when not connected)
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
                        HStack(spacing: 8) {
                            if isConnecting {
                                ProgressView()
                                    .scaleEffect(0.7)
                            } else {
                                Circle()
                                    .fill(Color.red)
                                    .frame(width: 8, height: 8)
                            }
                            
                            Text(statusText)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        if !isConnected && !isConnecting {
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
                
                        if isConnecting {
                            VStack(spacing: 16) {
                                ProgressView()
                                    .scaleEffect(1.5)
                                    .tint(.white)
                                
                                Text("Connecting...")
                                    .font(.title3)
                                    .foregroundColor(.white)
                                
                                Text("Establishing connection to \(remoteServer.name)")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.7))
                                    .multilineTextAlignment(.center)
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
                                
                                VStack(spacing: 8) {
                                    Text("Connect to view Cursor chat interface")
                                        .font(.subheadline)
                                        .foregroundColor(.white.opacity(0.7))
                                        .multilineTextAlignment(.center)
                                    
                                    if connectionError != nil {
                                        Text("💡 Tip: Use 'Test Connection' to diagnose issues")
                                            .font(.caption2)
                                            .foregroundColor(.white.opacity(0.6))
                                            .padding(.top, 4)
                                    }
                                }
                                
                                if let error = connectionError {
                                    VStack(spacing: 12) {
                                        Divider()
                                            .background(.white.opacity(0.3))
                                        
                                        HStack {
                                            Image(systemName: "exclamationmark.triangle.fill")
                                                .foregroundColor(.red)
                                            Text("Connection Error")
                                                .font(.headline)
                                                .foregroundColor(.red)
                                        }
                                        
                                        ScrollView {
                                            Text(error)
                                                .font(.caption)
                                                .foregroundColor(.white.opacity(0.9))
                                                .multilineTextAlignment(.leading)
                                                .padding(.horizontal)
                                        }
                                        .frame(maxHeight: 150)
                                        
                                        Button("Retry Connection") {
                                            connectToServer()
                                        }
                                        .buttonStyle(.borderedProminent)
                                        .padding(.top, 4)
                                    }
                                    .padding(.top, 8)
                                }
                                
                                VStack(spacing: 12) {
                                    Button("Connect to \(remoteServer.name)") {
                                        connectToServer()
                                    }
                                    .buttonStyle(.borderedProminent)
                                    .disabled(isConnecting)
                                    
                                    Button("Test Connection") {
                                        testConnection()
                                    }
                                    .buttonStyle(.bordered)
                                    .disabled(isConnecting)
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .background(.ultraThinMaterial)
                .cornerRadius(12)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            // Auto-connect on appear if configured
            if remoteServer.autoConnect {
                connectToServer()
            } else {
                // Check if we have a previous successful connection
                if let lastStatus = connectionManager.getLastConnectionStatus(for: remoteServer.id),
                   lastStatus.isConnected,
                   let lastConnected = lastStatus.lastConnected,
                   Date().timeIntervalSince(lastConnected) < 300 { // 5 minutes
                    // Auto-reconnect if last connection was recent
                    connectToServer()
                }
            }
        }
        .onDisappear {
            // Save connection status when view disappears
            if isConnected {
                connectionManager.saveConnectionStatus(
                    for: remoteServer.id,
                    status: ConnectionStatus(
                        serverId: remoteServer.id,
                        isConnected: isConnected,
                        lastConnected: Date(),
                        error: nil
                    )
                )
            }
        }
    }
    
    private var statusText: String {
        if isConnecting {
            return "Connecting..."
        } else if isConnected {
            return "Connected"
        } else {
            return "Disconnected"
        }
    }
    
    private func connectToServer() {
        isConnecting = true
        isConnected = false
        connectionError = nil
        connectionURL = nil
        
        Task {
            // Use connection manager with retry logic
            let result = await connectionManager.connectWithRetry(to: remoteServer, maxRetries: 3)
            
            await MainActor.run {
                switch result {
                case .success(let url):
                    connectionURL = url
                    isConnected = true
                    isConnecting = false
                    connectionError = nil
                    connectionStartTime = Date()
                    
                    // Start quality monitoring
                    qualityMonitor.startMonitoring(url: url)
                    
                    // Update connection status in manager
                    connectionManager.activeConnections[remoteServer.id] = ConnectionStatus(
                        serverId: remoteServer.id,
                        isConnected: true,
                        lastConnected: Date(),
                        error: nil
                    )
                    
                    // Record successful connection in history
                    historyManager.addConnection(remoteServer, success: true)
                    
                    // Send notification
                    notificationManager.notifyConnectionSuccess(serverName: remoteServer.name)
                    
                case .failure(let error):
                    isConnecting = false
                    isConnected = false
                    connectionError = formatConnectionError(error)
                    
                    // Stop quality monitoring
                    qualityMonitor.stopMonitoring()
                    
                    // Update connection status in manager
                    connectionManager.activeConnections[remoteServer.id] = ConnectionStatus(
                        serverId: remoteServer.id,
                        isConnected: false,
                        lastConnected: nil,
                        error: error
                    )
                    
                    // Record failed connection in history
                    historyManager.addConnection(remoteServer, success: false)
                    
                    // Send notification
                    notificationManager.notifyConnectionFailed(serverName: remoteServer.name, error: error)
                }
            }
        }
    }
    
    private func refreshConnection() {
        disconnectFromServer()
        // Small delay before reconnecting
        Task {
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
            await MainActor.run {
                connectToServer()
            }
        }
    }
    
    private func takeScreenshot() {
        guard let webView = webViewReference else { return }
        
        Task {
            if let image = await ScreenshotManager.shared.captureWebView(webView) {
                await MainActor.run {
                    ScreenshotManager.shared.saveImageToPhotos(image)
                    // Could also show a success message or share sheet
                }
            }
        }
    }
    
    private func sendTextToRemote(_ text: String) {
        // Get the WebView coordinator and inject text
        if let webView = webViewReference {
            // Access the coordinator through a custom method
            // For now, we'll use JavaScript injection directly
            let escapedText = text
                .replacingOccurrences(of: "\\", with: "\\\\")
                .replacingOccurrences(of: "\"", with: "\\\"")
                .replacingOccurrences(of: "\n", with: "\\n")
            
            let script = """
                (function() {
                    var activeElement = document.activeElement;
                    if (activeElement && (activeElement.tagName === 'INPUT' || activeElement.tagName === 'TEXTAREA' || activeElement.isContentEditable)) {
                        if (activeElement.tagName === 'INPUT' || activeElement.tagName === 'TEXTAREA') {
                            activeElement.value += '\(escapedText)';
                        } else {
                            activeElement.textContent += '\(escapedText)';
                        }
                        var event = new Event('input', { bubbles: true });
                        activeElement.dispatchEvent(event);
                    } else {
                        var input = document.querySelector('input, textarea, [contenteditable="true"]');
                        if (input) {
                            input.focus();
                            if (input.tagName === 'INPUT' || input.tagName === 'TEXTAREA') {
                                input.value += '\(escapedText)';
                            } else {
                                input.textContent += '\(escapedText)';
                            }
                            var event = new Event('input', { bubbles: true });
                            input.dispatchEvent(event);
                        }
                    }
                })();
            """
            
            webView.evaluateJavaScript(script, completionHandler: nil)
        }
    }
    
    private func testConnection() {
        Task {
            await MainActor.run {
                isConnecting = true
                connectionError = nil
            }
            
            let effectivePort = (remoteServer.type == .ubuntu && remoteServer.port == 5900) ? 6080 : remoteServer.port
            
            // Test port connectivity first
            let portOpen = await connectionManager.testPort(host: remoteServer.host, port: effectivePort)
            
            if !portOpen {
                await MainActor.run {
                    isConnecting = false
                    connectionError = """
                    Port \(effectivePort) is not reachable on \(remoteServer.host)
                    
                    Possible issues:
                    • Service is not running on port \(effectivePort)
                    • Firewall is blocking the connection
                    • Server is not accessible on this network
                    
                    To fix:
                    1. On your Ubuntu server, check if noVNC is running:
                       sudo systemctl status novnc
                       # Or check manually:
                       netstat -tlnp | grep 6080
                    
                    2. If not running, start noVNC:
                       # Install if needed:
                       sudo apt install novnc websockify
                       # Or use Docker:
                       docker run -p 6080:6080 theasp/novnc
                    
                    3. Check firewall:
                       sudo ufw allow 6080/tcp
                    
                    4. Test from another device:
                       curl http://\(remoteServer.host):\(effectivePort)/vnc.html
                    """
                }
                return
            }
            
            // Test HTTP connection
            let testResult = await connectionManager.testConnection(to: remoteServer, retries: 1)
            
            await MainActor.run {
                isConnecting = false
                
                switch testResult {
                case .success(let message):
                    connectionError = "✅ Connection test successful!\n\n\(message)\n\nYou can now connect."
                case .failure(let error):
                    connectionError = "❌ Connection test failed:\n\n\(error)\n\nSee troubleshooting steps above."
                }
            }
        }
    }
    
    private func sendKeyToRemote(_ key: String) {
        guard let webView = webViewReference else { return }
        
        let (keyCode, keyName, ctrlKey): (String, String, Bool) = {
            switch key {
            case "Enter": return ("13", "Enter", false)
            case "Tab": return ("9", "Tab", false)
            case "Esc", "Escape": return ("27", "Escape", false)
            case "Ctrl+C": return ("67", "c", true)
            case "Ctrl+V": return ("86", "v", true)
            case "Ctrl+Z": return ("90", "z", true)
            case "Ctrl+S": return ("83", "s", true)
            default: return ("0", "", false)
            }
        }()
        
        guard keyCode != "0" else { return }
        
        let script = """
            (function() {
                var activeElement = document.activeElement || document.body;
                var keyEvent = new KeyboardEvent('keydown', {
                    key: '\(keyName)',
                    code: '\(keyName)',
                    keyCode: \(keyCode),
                    which: \(keyCode),
                    bubbles: true,
                    cancelable: true,
                    ctrlKey: \(ctrlKey ? "true" : "false"),
                    shiftKey: false,
                    altKey: false,
                    metaKey: false
                });
                activeElement.dispatchEvent(keyEvent);
                
                var keyUpEvent = new KeyboardEvent('keyup', {
                    key: '\(keyName)',
                    code: '\(keyName)',
                    keyCode: \(keyCode),
                    which: \(keyCode),
                    bubbles: true,
                    cancelable: true,
                    ctrlKey: \(ctrlKey ? "true" : "false"),
                    shiftKey: false,
                    altKey: false,
                    metaKey: false
                });
                activeElement.dispatchEvent(keyUpEvent);
            })();
        """
        
        webView.evaluateJavaScript(script, completionHandler: nil)
    }
    
    private func formatConnectionError(_ error: String) -> String {
        var message = "Cannot connect to \(remoteServer.name)\n\n"
        message += "Error: \(error)\n\n"
        
        // Calculate effective port (may differ from configured port)
        let effectivePort = (remoteServer.type == .ubuntu && remoteServer.port == 5900) ? 6080 : remoteServer.port
        
        // Provide specific guidance based on error type
        if error.contains("Could not connect") || error.contains("timed out") || error.contains("Connection refused") {
            message += "🔍 Troubleshooting Steps:\n\n"
            message += "1. Check Server Status:\n"
            message += "   • Verify the server is running\n"
            if remoteServer.type == .ubuntu {
                message += "   • Check if noVNC is running: sudo systemctl status novnc\n"
                message += "   • For Ubuntu, noVNC web interface should be on port 6080\n"
            } else {
                message += "   • Check if Screen Sharing is enabled on macOS\n"
            }
            message += "   • Try accessing from another device\n\n"
            
            message += "2. Port Configuration:\n"
            if remoteServer.type == .ubuntu && remoteServer.port == 5900 {
                message += "   ⚠️  Port 5900 is VNC protocol (not HTTP)\n"
                message += "   • Using port 6080 for noVNC web interface\n"
                message += "   • If noVNC is on a different port, update server settings\n"
            }
            message += "   • Configured port: \(remoteServer.port)\n"
            message += "   • Effective port: \(effectivePort)\n"
            message += "   • Verify service is listening on port \(effectivePort)\n\n"
            
            message += "3. Network Connection:\n"
            message += "   • Ensure you're on the same network (or VPN)\n"
            message += "   • Test connectivity: ping \(remoteServer.host)\n"
            message += "   • Test port: nc -zv \(remoteServer.host) \(effectivePort)\n"
            message += "   • Verify firewall allows port \(effectivePort)\n\n"
            
            message += "4. Configuration:\n"
            message += "   • Host: \(remoteServer.host)\n"
            message += "   • Port: \(remoteServer.port) → \(effectivePort) (web interface)\n"
            if let path = remoteServer.connectionPath {
                message += "   • Path: \(path)\n"
            }
            message += "   • SSL: \(remoteServer.useSSL ? "Enabled" : "Disabled")\n\n"
            
            message += "5. Quick Fixes:\n"
            message += "   • Try using IP address instead of hostname\n"
            if remoteServer.type == .ubuntu {
                message += "   • For Ubuntu: Ensure noVNC is installed and running\n"
                message += "   • Quick setup: docker run -p 6080:6080 theasp/novnc\n"
                message += "   • Or install: sudo apt install novnc websockify\n"
                message += "   • Test in browser: http://\(remoteServer.host):\(effectivePort)/vnc.html\n"
            }
            message += "   • Verify credentials if authentication is required\n\n"
            message += "5. Alternative Ports:\n"
            message += "   • If noVNC is on a different port, update server settings\n"
            message += "   • Common ports: 6080 (noVNC), 5900 (VNC), 8080 (custom)"
        } else if error.contains("SSL") || error.contains("certificate") {
            message += "🔒 SSL/TLS Issue:\n\n"
            message += "• Try disabling SSL if server doesn't support it\n"
            message += "• Verify SSL certificate is valid\n"
            message += "• Check if server requires HTTPS on a different port"
        } else if error.contains("reset") || error.contains("connection was lost") || error.contains("-1005") {
            message += "🔄 Connection Reset:\n\n"
            message += "The server accepted the connection but immediately closed it.\n\n"
            message += "Possible causes:\n"
            message += "• Server doesn't recognize the request format\n"
            message += "• Path may be incorrect: \(remoteServer.connectionPath ?? "/vnc.html")\n"
            message += "• Server may require different headers\n"
            message += "• Authentication may be required\n\n"
            message += "Solutions:\n"
            message += "1. Test in browser first:\n"
            message += "   http://\(remoteServer.host):\(effectivePort)\(remoteServer.connectionPath ?? "/vnc.html")\n\n"
            message += "2. Try different paths:\n"
            message += "   • /vnc.html (default noVNC)\n"
            message += "   • / (root)\n"
            message += "   • /novnc/vnc.html\n"
            message += "   • Check server documentation\n\n"
            message += "3. Verify noVNC configuration on server\n"
        } else if error.contains("authentication") || error.contains("401") || error.contains("403") {
            message += "🔐 Authentication Issue:\n\n"
            message += "• Verify username and password are correct\n"
            message += "• Check if server requires authentication\n"
            message += "• Try connecting without credentials first"
        } else {
            message += "Please check:\n"
            message += "• Server is running and accessible\n"
            message += "• Network connection is active\n"
            message += "• Firewall allows connection on port \(remoteServer.port)\n"
            message += "• VPN is connected (if required)\n"
            message += "• Server hostname/IP is correct: \(remoteServer.host)"
        }
        
        return message
    }
    
    private func disconnectFromServer() {
        // Check if was connected before disconnecting
        let wasConnected = isConnected
        
        // Calculate connection duration
        var duration: TimeInterval?
        if let startTime = connectionStartTime {
            duration = Date().timeIntervalSince(startTime)
            historyManager.addConnection(remoteServer, success: wasConnected, duration: duration)
        }
        
        // Stop quality monitoring
        qualityMonitor.stopMonitoring()
        
        isConnected = false
        isConnecting = false
        connectionError = nil
        connectionURL = nil
        connectionStartTime = nil
        showKeyboard = false
        isFullscreen = false
        
        // Send notification if was connected
        if wasConnected {
            notificationManager.notifyConnectionLost(serverName: remoteServer.name)
        }
        
        // Update connection status in manager
        connectionManager.activeConnections[remoteServer.id] = ConnectionStatus(
            serverId: remoteServer.id,
            isConnected: false,
            lastConnected: nil,
            error: nil
        )
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


