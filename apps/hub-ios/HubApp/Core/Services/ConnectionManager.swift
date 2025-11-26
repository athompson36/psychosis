//
//  ConnectionManager.swift
//  HubApp
//
//  Created on [Current Date]
//

import Foundation

@MainActor
class ConnectionManager: ObservableObject {
    static let shared = ConnectionManager()
    
    @Published var activeConnections: [UUID: ConnectionStatus] = [:]
    
    private let userDefaults = UserDefaults.standard
    private let lastConnectionsKey = "lastActiveConnections"
    
    private init() {
        loadLastConnections()
    }
    
    func saveConnectionStatus(for serverId: UUID, status: ConnectionStatus) {
        activeConnections[serverId] = status
        saveLastConnections()
    }
    
    func getLastConnectionStatus(for serverId: UUID) -> ConnectionStatus? {
        return activeConnections[serverId]
    }
    
    private func saveLastConnections() {
        // Save connection statuses for persistence
        // In a full implementation, this would save to UserDefaults or Core Data
    }
    
    private func loadLastConnections() {
        // Load last connection statuses
        // In a full implementation, this would load from UserDefaults or Core Data
    }
    
    func getConnectionURL(for server: RemoteServer) -> URL? {
        // Construct URL using user-provided server configuration
        var components = URLComponents()
        
        // Use SSL if configured
        components.scheme = server.useSSL ? "https" : "http"
        components.host = server.host
        
        // Handle port: For Ubuntu, if port is 5900 (VNC), use 6080 for noVNC web interface
        var effectivePort = server.port
        if server.type == .ubuntu && server.port == 5900 {
            // VNC port 5900 -> noVNC web interface typically on 6080
            effectivePort = 6080
        }
        components.port = effectivePort
        
        // Use custom path if provided, otherwise use defaults based on type
        if let customPath = server.connectionPath, !customPath.isEmpty {
            components.path = customPath.hasPrefix("/") ? customPath : "/\(customPath)"
        } else {
            // Default paths based on server type
            switch server.type {
            case .ubuntu:
                // noVNC web interface
                components.path = "/vnc.html"
            case .mac:
                // macOS Screen Sharing web interface
                components.path = "/vnc.html"
            }
        }
        
        // Add credentials to URL if provided
        if let username = server.username, !username.isEmpty {
            if let password = server.password, !password.isEmpty {
                components.user = username
                components.password = password
            } else {
                components.user = username
            }
        }
        
        // Add query parameters for noVNC/VNC web clients
        var queryItems: [URLQueryItem] = []
        queryItems.append(URLQueryItem(name: "autoconnect", value: "true"))
        queryItems.append(URLQueryItem(name: "resize", value: "scale"))
        queryItems.append(URLQueryItem(name: "quality", value: "6"))
        
        // Add password as query parameter if not in URL (for some VNC web clients)
        if let password = server.password, !password.isEmpty, server.username == nil {
            queryItems.append(URLQueryItem(name: "password", value: password))
        }
        
        components.queryItems = queryItems
        
        return components.url
    }
    
    func testConnection(to server: RemoteServer, retries: Int = 3) async -> ConnectionTestResult {
        // Test if server is reachable with retry logic
        guard let url = getConnectionURL(for: server) else {
            return .failure("Unable to construct connection URL")
        }
        
        // For HTTP/HTTPS, test with a simple request
        if url.scheme == "http" || url.scheme == "https" {
            var lastError: Error?
            var lastStatusCode: Int?
            
            for attempt in 1...retries {
                do {
                    var request = URLRequest(url: url)
                    request.timeoutInterval = 5.0
                    request.httpMethod = "HEAD"
                    
                    // Add authentication if credentials are in URL
                    if let user = url.user, let password = url.password {
                        let loginString = "\(user):\(password)"
                        let loginData = loginString.data(using: .utf8)!
                        let base64LoginString = loginData.base64EncodedString()
                        request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
                    }
                    
                    let (_, response) = try await URLSession.shared.data(for: request)
                    
                    if let httpResponse = response as? HTTPURLResponse {
                        lastStatusCode = httpResponse.statusCode
                        if (200...299).contains(httpResponse.statusCode) {
                            return .success("Connection successful")
                        } else if (400...499).contains(httpResponse.statusCode) {
                            return .failure("Server returned error \(httpResponse.statusCode). Check authentication and permissions.")
                        } else if (500...599).contains(httpResponse.statusCode) {
                            return .failure("Server error \(httpResponse.statusCode). Server may be experiencing issues.")
                        }
                    }
                } catch {
                    lastError = error
                    // Exponential backoff: wait before retry
                    if attempt < retries {
                        let delay = pow(2.0, Double(attempt)) // 2, 4, 8 seconds
                        try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                    }
                }
            }
            
            // Provide detailed error message
            if let error = lastError {
                let errorMsg = error.localizedDescription
                let nsError = error as NSError
                
                // Check for specific error codes
                if nsError.code == -1005 {
                    // Connection lost/reset by peer - often DNS resolution failure
                    var errorMsg = "Connection lost. This often indicates:\n"
                    // Check if hostname might be the issue (not an IP address)
                    let isIPAddress = server.host.range(of: "^\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}$", options: .regularExpression) != nil
                    if server.host.contains(".local") || (!isIPAddress && !server.host.contains(".")) {
                        errorMsg += "• Hostname '\(server.host)' may not resolve on this device\n"
                        errorMsg += "• Try using IP address instead (e.g., 192.168.4.100)\n"
                    }
                    errorMsg += "• Server doesn't support the requested path\n"
                    errorMsg += "• Authentication required\n"
                    errorMsg += "• Try accessing http://\(server.host):\(url.port ?? 0)/vnc.html in a browser first"
                    return .failure(errorMsg)
                } else if nsError.code == -1004 {
                    // Could not connect
                    if errorMsg.contains("refused") {
                        return .failure("Connection refused. Service may not be running on port \(url.port ?? 0).")
                    }
                    return .failure("Could not connect to server. Check network connectivity and firewall settings.")
                } else if errorMsg.contains("timed out") || nsError.code == -1001 {
                    return .failure("Connection timed out. Server may be unreachable or firewall is blocking.")
                } else if errorMsg.contains("host") || nsError.code == -1003 {
                    return .failure("Host not found. Check hostname/IP address: \(server.host)")
                }
                return .failure("Connection failed: \(errorMsg) (code: \(nsError.code))")
            }
            
            if let statusCode = lastStatusCode {
                return .failure("Server returned status code \(statusCode)")
            }
            
            return .failure("Connection failed after \(retries) attempts")
        }
        
        // For VNC protocol, assume connection is possible (would need VNC client to verify)
        return .success("VNC protocol connection (cannot verify without VNC client)")
    }
    
    func testPort(host: String, port: Int, timeout: TimeInterval = 3.0) async -> Bool {
        // Test if a specific port is reachable by attempting an HTTP connection
        // This is simpler and works better on iOS
        var components = URLComponents()
        components.scheme = "http"
        components.host = host
        components.port = port
        components.path = "/"
        
        guard let url = components.url else { return false }
        
        do {
            var request = URLRequest(url: url)
            request.timeoutInterval = timeout
            request.httpMethod = "HEAD"
            
            let (_, response) = try await URLSession.shared.data(for: request)
            
            // If we get any response (even error codes), the port is open
            if response is HTTPURLResponse {
                return true // Port is reachable (even if service returns error)
            }
            return true
        } catch {
            // Check if it's a connection refused vs timeout
            let errorMsg = error.localizedDescription.lowercased()
            if errorMsg.contains("refused") {
                return false // Port is closed/not listening
            }
            // Timeout or other error - port might be filtered
            return false
        }
    }
    
    func connectWithRetry(to server: RemoteServer, maxRetries: Int = 3) async -> ConnectionResult {
        // First, test the connection to get detailed error information
        let testResult = await testConnection(to: server, retries: 1)
        
        switch testResult {
        case .success:
            if let url = getConnectionURL(for: server) {
                return .success(url)
            } else {
                return .failure("Unable to construct connection URL")
            }
        case .failure(let errorMessage):
            // Try a few more times with retries
            for attempt in 2...maxRetries {
                let delay = pow(2.0, Double(attempt - 1))
                try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                
                let retryResult = await testConnection(to: server, retries: 1)
                if case .success = retryResult {
                    if let url = getConnectionURL(for: server) {
                        return .success(url)
                    }
                }
            }
            
            return .failure(errorMessage)
        }
    }
}

enum ConnectionResult {
    case success(URL)
    case failure(String)
}

enum ConnectionTestResult {
    case success(String)
    case failure(String)
}

struct ConnectionStatus {
    let serverId: UUID
    let isConnected: Bool
    let lastConnected: Date?
    let error: String?
}

