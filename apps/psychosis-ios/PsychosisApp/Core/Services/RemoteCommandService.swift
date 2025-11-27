//
//  RemoteCommandService.swift
//  PsychosisApp
//
//  Created on [Current Date]
//

import Foundation

@MainActor
class RemoteCommandService: ObservableObject {
    static let shared = RemoteCommandService()
    
    private let backendURL = "http://192.168.4.100:5000" // Backend API URL
    
    private init() {}
    
    /// Check if Cursor is running on the remote server via backend API
    func checkCursorRunning(server: RemoteServer) async -> Bool {
        guard let url = URL(string: "\(backendURL)/api/remote/cursor/check") else {
            print("❌ Invalid backend URL: \(backendURL)")
            return false
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 10.0
        
        var body: [String: Any] = ["host": server.host]
        if let username = server.username {
            body["username"] = username
        }
        if let password = server.password {
            body["password"] = password
        }
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode != 200 {
                    print("❌ Backend returned status \(httpResponse.statusCode) when checking Cursor")
                    return false
                }
            }
            
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let isRunning = json["isRunning"] as? Bool {
                print("✅ Cursor check: \(isRunning ? "running" : "not running")")
                return isRunning
            } else {
                print("⚠️ Invalid response format from backend")
            }
        } catch {
            print("❌ Error checking Cursor: \(error.localizedDescription)")
            if let urlError = error as? URLError {
                print("   URL Error code: \(urlError.code.rawValue)")
                print("   URL Error description: \(urlError.localizedDescription)")
            }
        }
        
        return false
    }
    
    /// Start Cursor on the remote server via backend API
    func startCursor(server: RemoteServer) async -> Bool {
        guard let url = URL(string: "\(backendURL)/api/remote/cursor/start") else {
            print("❌ Invalid backend URL: \(backendURL)")
            return false
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 10.0
        
        var body: [String: Any] = ["host": server.host]
        if let username = server.username {
            body["username"] = username
        }
        if let password = server.password {
            body["password"] = password
        }
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode != 200 {
                    print("❌ Backend returned status \(httpResponse.statusCode) when starting Cursor")
                    if let errorData = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let errorMsg = errorData["message"] as? String {
                        print("   Error message: \(errorMsg)")
                    }
                    return false
                }
            }
            
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let success = json["success"] as? Bool {
                if success {
                    print("✅ Cursor start command sent successfully")
                } else {
                    print("⚠️ Cursor start returned success=false")
                }
                return success
            } else {
                print("⚠️ Invalid response format from backend")
                if let responseString = String(data: data, encoding: .utf8) {
                    print("   Response: \(responseString)")
                }
            }
        } catch {
            print("❌ Error starting Cursor: \(error.localizedDescription)")
            if let urlError = error as? URLError {
                print("   URL Error code: \(urlError.code.rawValue)")
                print("   Could not connect to backend at \(backendURL)")
            }
        }
        
        return false
    }
    
    /// Bring Cursor window to front and focus it via backend API
    func focusCursor(server: RemoteServer) async -> Bool {
        guard let url = URL(string: "\(backendURL)/api/remote/cursor/focus") else {
            return false
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var body: [String: Any] = ["host": server.host]
        if let username = server.username {
            body["username"] = username
        }
        if let password = server.password {
            body["password"] = password
        }
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            if let httpResponse = response as? HTTPURLResponse,
               httpResponse.statusCode == 200,
               let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let success = json["success"] as? Bool {
                return success
            }
        } catch {
            print("Error focusing Cursor: \(error.localizedDescription)")
        }
        
        return false
    }
    
    /// Execute a shell command on the remote server via backend API
    func executeRemoteCommand(server: RemoteServer, command: String) async -> String? {
        guard let url = URL(string: "\(backendURL)/api/remote/execute") else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var body: [String: Any] = ["host": server.host, "command": command]
        if let username = server.username {
            body["username"] = username
        }
        if let password = server.password {
            body["password"] = password
        }
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            if let httpResponse = response as? HTTPURLResponse,
               httpResponse.statusCode == 200,
               let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let output = json["output"] as? String {
                return output
            }
        } catch {
            print("Error executing command: \(error.localizedDescription)")
        }
        
        return nil
    }
    
    /// Manage Cursor: check if running, start if not, focus if running
    func manageCursor(server: RemoteServer) async -> CursorManagementResult {
        print("🔍 Managing Cursor for server: \(server.host)")
        
        // First, check if Cursor is running
        let isRunning = await checkCursorRunning(server: server)
        
        if isRunning {
            print("✅ Cursor is running, attempting to focus...")
            // Try to focus it
            let focusResult = await focusCursor(server: server)
            if focusResult {
                print("✅ Successfully focused Cursor")
                return .alreadyRunning
            } else {
                print("⚠️ Cursor is running but could not focus it")
                // Still return alreadyRunning since it's running, even if focus failed
                return .alreadyRunning
            }
        }
        
        print("🚀 Cursor is not running, attempting to start...")
        // If not running, start it
        let startResult = await startCursor(server: server)
        
        if startResult {
            print("⏳ Waiting for Cursor to start...")
            // Wait a bit for Cursor to start, then try to focus
            try? await Task.sleep(nanoseconds: 3_000_000_000) // 3 seconds
            
            // Verify it started
            let verifyRunning = await checkCursorRunning(server: server)
            if verifyRunning {
                print("✅ Cursor started successfully, attempting to focus...")
                let focusAfterStart = await focusCursor(server: server)
                return focusAfterStart ? .startedAndFocused : .started
            } else {
                print("⚠️ Cursor start command sent but process not detected")
                return .started // Assume it started even if we can't verify
            }
        } else {
            print("❌ Failed to start Cursor")
        }
        
        return .failed
    }
}

enum CursorManagementResult {
    case alreadyRunning
    case started
    case startedAndFocused
    case failed
}

