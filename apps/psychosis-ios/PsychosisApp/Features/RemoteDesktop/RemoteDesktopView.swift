//
//  RemoteDesktopView.swift
//  Psychosis
//
//  Created on [Current Date]
//

import SwiftUI
import WebKit

// MARK: - Cursor Pane Enum
enum CursorPane: String, CaseIterable {
    case editor = "Editor"
    case files = "Files"
    case chat = "Chat"
    case terminal = "Terminal"
    
    var icon: String {
        switch self {
        case .editor: return "doc.text.fill"
        case .files: return "folder.fill"
        case .chat: return "message.fill"
        case .terminal: return "terminal.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .editor: return .blue
        case .files: return .green
        case .chat: return .purple
        case .terminal: return .orange
        }
    }
}

// MARK: - Remote Desktop View
struct RemoteDesktopView: View {
    let remoteServer: RemoteServer
    @Binding var selectedPane: CursorPane
    @StateObject private var connectionManager = ConnectionManager.shared
    @StateObject private var historyManager = ConnectionHistoryManager.shared
    @StateObject private var qualityMonitor = ConnectionQualityMonitor.shared
    @StateObject private var notificationManager = NotificationManager.shared
    @StateObject private var commandService = RemoteCommandService.shared
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
                        WebViewWrapper(
                            url: url,
                            username: remoteServer.username,
                            password: remoteServer.password,
                            isLoading: $webViewIsLoading,
                            errorMessage: $webViewError,
                            selectedPane: selectedPane,
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
                    // Minimal disconnect indicator (quality moved to header)
                    Button(action: {
                        disconnectFromServer()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title3)
                            .foregroundColor(.secondary)
                            .padding(8)
                            .background(.ultraThinMaterial)
                            .cornerRadius(8)
                    }
                    .padding(8)
                    .opacity(0.7)
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
        .onChange(of: selectedPane) { oldPane, newPane in
            // Update pane when selection changes from MainPaneView
            if isConnected {
                showPane(newPane)
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
                    
                    // Automatically manage Cursor after connection is established
                    Task {
                        // Wait a moment for the connection to stabilize
                        try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
                        
                        let result = await commandService.manageCursor(server: remoteServer)
                        
                        await MainActor.run {
                            switch result {
                            case .alreadyRunning:
                                print("✅ Cursor is already running, focused")
                            case .started:
                                print("✅ Cursor started")
                            case .startedAndFocused:
                                print("✅ Cursor started and focused")
                            case .failed:
                                print("⚠️ Failed to manage Cursor - may need manual start")
                            }
                            
                            // After Cursor is focused, wait a bit more then show the selected pane
                            Task {
                                try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
                                await MainActor.run {
                                    showPane(selectedPane)
                                }
                            }
                        }
                    }
                    
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
    
    private func showPane(_ pane: CursorPane) {
        guard let webView = webViewReference else { return }
        
        // IMPORTANT: noVNC renders the remote desktop as a canvas (pixels).
        // We CANNOT manipulate Cursor's DOM because it's running on the remote server.
        // Instead, we send VNC keyboard shortcuts through noVNC's RFB API.
        //
        // Cursor keyboard shortcuts (Linux/Ubuntu):
        // - Ctrl+B: Toggle sidebar (files)
        // - Ctrl+J: Toggle panel (terminal/output)
        // - Ctrl+L: Open Cursor AI chat
        // - Ctrl+Shift+E: Focus file explorer
        
        let script: String
        
        switch pane {
        case .chat:
            // Activate Zen Mode with Ctrl+K Z (fullscreen, distraction-free mode)
            // Then open Chat with Ctrl+L
            script = """
                (function() {
                    console.log('🎯 Activating Zen Mode (Ctrl+K Z) then opening Chat (Ctrl+L)');
                    
                    // Use the RFB instance stored by the setup script
                    var rfb = window.psychosisRFB || window.rfb || (typeof UI !== 'undefined' && UI.rfb) || null;
                    
                    // If not found, try to find it now
                    if (!rfb) {
                        var canvas = document.querySelector('canvas');
                        if (canvas && canvas.rfb) rfb = canvas.rfb;
                    }
                    
                    console.log('RFB instance:', rfb ? 'found' : 'NOT FOUND');
                    var result = { rfbFound: false, keysSent: false };
                    
                    // Function to send keys via RFB API
                    function sendKeysRFB(keys) {
                        if (rfb && typeof rfb.sendKey === 'function') {
                            result.rfbFound = true;
                            try {
                                console.log('📤 Sending keys via RFB API:', keys.length, 'keys');
                                keys.forEach(function(key, index) {
                                    console.log('  Key', index + ':', key.keyName, key.down ? 'DOWN' : 'UP', 'keysym:', '0x' + key.keysym.toString(16));
                                    rfb.sendKey(key.keysym, key.down);
                                    // Small delay between keys for better reliability
                                    if (index < keys.length - 1) {
                                        // Use synchronous delay (blocking)
                                        var start = Date.now();
                                        while (Date.now() - start < 20) {} // 20ms delay
                                    }
                                });
                                result.keysSent = true;
                                console.log('✅ Sent', keys.length, 'keys via RFB API');
                                return true;
                            } catch(e) {
                                console.error('❌ Error with RFB sendKey:', e);
                                console.error('  Stack:', e.stack);
                                return false;
                            }
                        } else {
                            console.warn('⚠️ RFB API not available:', {
                                hasRFB: !!rfb,
                                hasSendKey: rfb && typeof rfb.sendKey === 'function',
                                rfbType: typeof rfb,
                                rfbKeys: rfb ? Object.keys(rfb).slice(0, 10) : []
                            });
                        }
                        return false;
                    }
                    
                    // Function to send keys via keyboard events (fallback)
                    function sendKeysEvents(keys, delay) {
                        var canvas = document.querySelector('canvas');
                        if (!canvas) {
                            console.error('❌ Canvas not found');
                            return false;
                        }
                        
                        // Ensure canvas is focusable and focused
                        canvas.setAttribute('tabindex', '0');
                        canvas.style.outline = 'none';
                        canvas.focus();
                        canvas.click();
                        
                        setTimeout(function() {
                            keys.forEach(function(key) {
                                var eventProps = {
                                    key: key.keyName,
                                    code: key.code,
                                    keyCode: key.keyCode,
                                    which: key.which || key.keyCode,
                                    ctrlKey: key.ctrl || false,
                                    metaKey: false,
                                    altKey: false,
                                    shiftKey: key.shift || false,
                                    bubbles: true,
                                    cancelable: true,
                                    composed: true
                                };
                                
                                // Send to document (where VS Code/Cursor keyboard handlers listen)
                                var event1 = new KeyboardEvent(key.down ? 'keydown' : 'keyup', eventProps);
                                document.dispatchEvent(event1);
                                
                                // Also send to body
                                var event2 = new KeyboardEvent(key.down ? 'keydown' : 'keyup', eventProps);
                                document.body.dispatchEvent(event2);
                                
                                // And to active element
                                if (document.activeElement) {
                                    var event3 = new KeyboardEvent(key.down ? 'keydown' : 'keyup', eventProps);
                                    document.activeElement.dispatchEvent(event3);
                                }
                            });
                            
                            result.keysSent = true;
                            console.log('✅ Sent keys via keyboard events');
                        }, delay || 50);
                        
                        return true;
                    }
                    
                    // Step 1: Activate Zen Mode (Ctrl+K Z)
                    // Zen mode is a chord: Ctrl+K (press and release), then Z
                    // VS Code shows "Ctrl+K" in status bar, then waits for next key
                    var ctrlKKeys = [
                        {keysym: 0xFFE3, keyName: 'Control', code: 'ControlLeft', keyCode: 17, which: 17, ctrl: true, shift: false, down: true},
                        {keysym: 0x006B, keyName: 'k', code: 'KeyK', keyCode: 75, which: 75, ctrl: true, shift: false, down: true},
                        {keysym: 0x006B, keyName: 'k', code: 'KeyK', keyCode: 75, which: 75, ctrl: true, shift: false, down: false},
                        {keysym: 0xFFE3, keyName: 'Control', code: 'ControlLeft', keyCode: 17, which: 17, ctrl: false, shift: false, down: false}
                    ];
                    
                    var zKey = [
                        {keysym: 0x007A, keyName: 'z', code: 'KeyZ', keyCode: 90, which: 90, ctrl: false, shift: false, down: true},
                        {keysym: 0x007A, keyName: 'z', code: 'KeyZ', keyCode: 90, which: 90, ctrl: false, shift: false, down: false}
                    ];
                    
                    // Send Ctrl+K first
                    if (!sendKeysRFB(ctrlKKeys)) {
                        sendKeysEvents(ctrlKKeys, 50);
                    }
                    
                    // Wait for VS Code to recognize the chord (shows "Ctrl+K" in status bar)
                    setTimeout(function() {
                        // Now send Z to complete the chord
                        if (!sendKeysRFB(zKey)) {
                            sendKeysEvents(zKey, 0);
                        }
                        
                        // Step 2: After Zen mode activates, open Chat (Ctrl+L)
                        setTimeout(function() {
                            var chatKeys = [
                                {keysym: 0xFFE3, keyName: 'Control', code: 'ControlLeft', keyCode: 17, which: 17, ctrl: true, shift: false, down: true},
                                {keysym: 0x006C, keyName: 'l', code: 'KeyL', keyCode: 76, which: 76, ctrl: true, shift: false, down: true},
                                {keysym: 0x006C, keyName: 'l', code: 'KeyL', keyCode: 76, which: 76, ctrl: true, shift: false, down: false},
                                {keysym: 0xFFE3, keyName: 'Control', code: 'ControlLeft', keyCode: 17, which: 17, ctrl: false, shift: false, down: false}
                            ];
                            
                            if (!sendKeysRFB(chatKeys)) {
                                sendKeysEvents(chatKeys, 0);
                            }
                            
                            console.log('✅ Sent Zen Mode (Ctrl+K Z) then Chat (Ctrl+L)');
                        }, 400); // Wait 400ms for Zen mode to fully activate
                    }, 150); // Wait 150ms between Ctrl+K and Z (chord recognition delay)
                    
                    return result;
                })();
            """
            
        case .editor:
            // Focus editor using Ctrl+1 (focus first editor group) per Cursor docs
            script = """
                (function() {
                    console.log('🎯 Focusing editor with Ctrl+1');
                    
                    // Use the RFB instance stored by the setup script
                    var rfb = window.psychosisRFB || window.rfb || (typeof UI !== 'undefined' && UI.rfb) || null;
                    if (!rfb) {
                        var canvas = document.querySelector('canvas');
                        if (canvas && canvas.rfb) rfb = canvas.rfb;
                    }
                    
                    var result = { rfbFound: false, keysSent: false };
                    
                    // Fallback: Send keyboard events to document/body (Cursor listens globally)
                    var canvas = document.querySelector('canvas');
                    if (canvas) {
                        canvas.setAttribute('tabindex', '0');
                        canvas.style.outline = 'none';
                        canvas.focus();
                        canvas.click();
                        
                        setTimeout(function() {
                            // Send Ctrl+1 to document (where Cursor's keyboard handler listens)
                            var keys = [
                                {keyName: 'Control', code: 'ControlLeft', keyCode: 17, which: 17, ctrl: true, down: true},
                                {keyName: '1', code: 'Digit1', keyCode: 49, which: 49, ctrl: true, down: true},
                                {keyName: '1', code: 'Digit1', keyCode: 49, which: 49, ctrl: true, down: false},
                                {keyName: 'Control', code: 'ControlLeft', keyCode: 17, which: 17, ctrl: false, down: false}
                            ];
                            
                            for (var i = 0; i < keys.length; i++) {
                                var key = keys[i];
                                var eventProps = {
                                    key: key.keyName,
                                    code: key.code,
                                    keyCode: key.keyCode,
                                    which: key.which,
                                    ctrlKey: key.ctrl,
                                    metaKey: false,
                                    altKey: false,
                                    shiftKey: false,
                                    bubbles: true,
                                    cancelable: true,
                                    composed: true
                                };
                                
                                var event1 = new KeyboardEvent(key.down ? 'keydown' : 'keyup', eventProps);
                                document.dispatchEvent(event1);
                                
                                var event2 = new KeyboardEvent(key.down ? 'keydown' : 'keyup', eventProps);
                                document.body.dispatchEvent(event2);
                                
                                if (document.activeElement) {
                                    var event3 = new KeyboardEvent(key.down ? 'keydown' : 'keyup', eventProps);
                                    document.activeElement.dispatchEvent(event3);
                                }
                            }
                            
                            result.keysSent = true;
                            console.log('✅ Sent Ctrl+1 to document/body');
                        }, 50);
                    } else {
                        console.error('❌ Canvas not found');
                    }
                    
                    return result;
                })();
            """
            
        case .files:
            // Show file explorer with Ctrl+Shift+E
            script = """
                (function() {
                    console.log('🎯 Showing files explorer');
                    
                    // Use the RFB instance stored by the setup script
                    var rfb = window.psychosisRFB || window.rfb || (typeof UI !== 'undefined' && UI.rfb) || null;
                    if (!rfb) {
                        var canvas = document.querySelector('canvas');
                        if (canvas && canvas.rfb) rfb = canvas.rfb;
                    }
                    
                    var result = { rfbFound: false, keysSent: false };
                    
                    // Send keyboard events directly to document/body (Cursor listens globally)
                    var canvas = document.querySelector('canvas');
                    if (canvas) {
                        canvas.setAttribute('tabindex', '0');
                        canvas.focus();
                        canvas.click();
                        
                        // Send Ctrl+B first
                        setTimeout(function() {
                            var keys1 = [
                                {keyName: 'Control', code: 'ControlLeft', keyCode: 17, which: 17, ctrl: true, shift: false, down: true},
                                {keyName: 'b', code: 'KeyB', keyCode: 66, which: 66, ctrl: true, shift: false, down: true},
                                {keyName: 'b', code: 'KeyB', keyCode: 66, which: 66, ctrl: true, shift: false, down: false},
                                {keyName: 'Control', code: 'ControlLeft', keyCode: 17, which: 17, ctrl: false, shift: false, down: false}
                            ];
                            
                            for (var i = 0; i < keys1.length; i++) {
                                var key = keys1[i];
                                var eventProps = {
                                    key: key.keyName,
                                    code: key.code,
                                    keyCode: key.keyCode,
                                    which: key.which,
                                    ctrlKey: key.ctrl,
                                    shiftKey: key.shift,
                                    metaKey: false,
                                    altKey: false,
                                    bubbles: true,
                                    cancelable: true,
                                    composed: true
                                };
                                
                                var event1 = new KeyboardEvent(key.down ? 'keydown' : 'keyup', eventProps);
                                document.dispatchEvent(event1);
                                
                                var event2 = new KeyboardEvent(key.down ? 'keydown' : 'keyup', eventProps);
                                document.body.dispatchEvent(event2);
                                
                                if (document.activeElement) {
                                    var event3 = new KeyboardEvent(key.down ? 'keydown' : 'keyup', eventProps);
                                    document.activeElement.dispatchEvent(event3);
                                }
                            }
                            
                            // Then Ctrl+Shift+E after delay
                            setTimeout(function() {
                                var keys2 = [
                                    {keyName: 'Control', code: 'ControlLeft', keyCode: 17, which: 17, ctrl: true, shift: false, down: true},
                                    {keyName: 'Shift', code: 'ShiftLeft', keyCode: 16, which: 16, ctrl: true, shift: true, down: true},
                                    {keyName: 'e', code: 'KeyE', keyCode: 69, which: 69, ctrl: true, shift: true, down: true},
                                    {keyName: 'e', code: 'KeyE', keyCode: 69, which: 69, ctrl: true, shift: true, down: false},
                                    {keyName: 'Shift', code: 'ShiftLeft', keyCode: 16, which: 16, ctrl: true, shift: false, down: false},
                                    {keyName: 'Control', code: 'ControlLeft', keyCode: 17, which: 17, ctrl: false, shift: false, down: false}
                                ];
                                
                                for (var j = 0; j < keys2.length; j++) {
                                    var key2 = keys2[j];
                                    var event2 = new KeyboardEvent(key2.down ? 'keydown' : 'keyup', {
                                        key: key2.keyName,
                                        code: key2.code,
                                        keyCode: key2.keyCode,
                                        which: key2.which,
                                        ctrlKey: key2.ctrl,
                                        shiftKey: key2.shift,
                                        metaKey: false,
                                        altKey: false,
                                        bubbles: true,
                                        cancelable: true,
                                        composed: true
                                    });
                                    document.dispatchEvent(event2);
                                    
                                    // Create new events for body and activeElement
                                    var event2Body = new KeyboardEvent(key2.down ? 'keydown' : 'keyup', {
                                        key: key2.keyName,
                                        code: key2.code,
                                        keyCode: key2.keyCode,
                                        which: key2.which,
                                        ctrlKey: key2.ctrl,
                                        shiftKey: key2.shift,
                                        metaKey: false,
                                        altKey: false,
                                        bubbles: true,
                                        cancelable: true,
                                        composed: true
                                    });
                                    document.body.dispatchEvent(event2Body);
                                    
                                    if (document.activeElement) {
                                        var event2Active = new KeyboardEvent(key2.down ? 'keydown' : 'keyup', {
                                            key: key2.keyName,
                                            code: key2.code,
                                            keyCode: key2.keyCode,
                                            which: key2.which,
                                            ctrlKey: key2.ctrl,
                                            shiftKey: key2.shift,
                                            metaKey: false,
                                            altKey: false,
                                            bubbles: true,
                                            cancelable: true,
                                            composed: true
                                        });
                                        document.activeElement.dispatchEvent(event2Active);
                                    }
                                }
                                
                                result.keysSent = true;
                                console.log('✅ Sent Ctrl+B and Ctrl+Shift+E for file explorer');
                            }, 200);
                        }, 50);
                    } else {
                        console.error('❌ Canvas not found');
                    }
                    
                    return result;
                })();
            """
            
        case .terminal:
            // Show terminal with Ctrl+J (toggle panel)
            script = """
                (function() {
                    console.log('🎯 Showing terminal with Ctrl+J');
                    
                    // Use the RFB instance stored by the setup script
                    var rfb = window.psychosisRFB || window.rfb || (typeof UI !== 'undefined' && UI.rfb) || null;
                    if (!rfb) {
                        var canvas = document.querySelector('canvas');
                        if (canvas && canvas.rfb) rfb = canvas.rfb;
                    }
                    
                    var result = { rfbFound: false, keysSent: false };
                    
                    // Send keyboard events directly to document/body (Cursor listens globally)
                    var canvas = document.querySelector('canvas');
                    if (canvas) {
                        canvas.setAttribute('tabindex', '0');
                        canvas.style.outline = 'none';
                        canvas.focus();
                        canvas.click();
                        
                        setTimeout(function() {
                            var keys = [
                                {keyName: 'Control', code: 'ControlLeft', keyCode: 17, which: 17, ctrl: true, shift: false, down: true},
                                {keyName: 'j', code: 'KeyJ', keyCode: 74, which: 74, ctrl: true, shift: false, down: true},
                                {keyName: 'j', code: 'KeyJ', keyCode: 74, which: 74, ctrl: true, shift: false, down: false},
                                {keyName: 'Control', code: 'ControlLeft', keyCode: 17, which: 17, ctrl: false, shift: false, down: false}
                            ];
                            
                            for (var i = 0; i < keys.length; i++) {
                                var key = keys[i];
                                var eventProps = {
                                    key: key.keyName,
                                    code: key.code,
                                    keyCode: key.keyCode,
                                    which: key.which,
                                    ctrlKey: key.ctrl,
                                    shiftKey: key.shift,
                                    metaKey: false,
                                    altKey: false,
                                    bubbles: true,
                                    cancelable: true,
                                    composed: true
                                };
                                
                                var event1 = new KeyboardEvent(key.down ? 'keydown' : 'keyup', eventProps);
                                document.dispatchEvent(event1);
                                
                                var event2 = new KeyboardEvent(key.down ? 'keydown' : 'keyup', eventProps);
                                document.body.dispatchEvent(event2);
                                
                                if (document.activeElement) {
                                    var event3 = new KeyboardEvent(key.down ? 'keydown' : 'keyup', eventProps);
                                    document.activeElement.dispatchEvent(event3);
                                }
                            }
                            
                            result.keysSent = true;
                            console.log('✅ Sent Ctrl+J for terminal');
                        }, 50);
                    } else {
                        console.error('❌ Canvas not found');
                    }
                    
                    return result;
                })();
            """
        }
        
        webView.evaluateJavaScript(script) { result, error in
            if let error = error {
                print("❌ Error sending VNC keys: \(error.localizedDescription)")
            } else {
                // Check if we got a result indicating success
                if let resultDict = result as? [String: Any] {
                    if let found = resultDict["rfbFound"] as? Bool {
                        print("RFB found: \(found)")
                    }
                    if let sent = resultDict["keysSent"] as? Bool {
                        print("Keys sent: \(sent)")
                    }
                }
                print("✅ Sent VNC shortcut for \(pane.rawValue) pane")
            }
        }
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
    @Previewable @State var pane: CursorPane = .chat
    RemoteDesktopView(remoteServer: RemoteServer(
        name: "fs-dev Ubuntu",
        host: "fs-dev.local",
        type: .ubuntu
    ), selectedPane: $pane)
    .background(Color.black)
}


