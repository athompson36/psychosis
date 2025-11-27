//
//  VNCService.swift
//  PsychosisApp
//
//  Service for managing VNC server (x11vnc) configuration
//

import Foundation

@MainActor
class VNCService: ObservableObject {
    static let shared = VNCService()
    
    private let backendURL = "http://192.168.4.100:5000" // Backend API URL
    
    private init() {}
    
    // MARK: - VNC Status
    
    struct VNCStatus: Codable {
        let running: Bool
        let processInfo: String?
        let flags: Flags?
        let allFlagsGood: Bool?
        
        struct Flags: Codable {
            let modtweak: Bool
            let repeat: Bool
            let xkb: Bool
        }
    }
    
    func checkStatus(server: RemoteServer) async -> Result<VNCStatus, Error> {
        guard let url = URL(string: "\(backendURL)/api/vnc/status") else {
            return .failure(NSError(domain: "VNCService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]))
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 10.0
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                return .failure(NSError(domain: "VNCService", code: -2, userInfo: [NSLocalizedDescriptionKey: "Invalid response"]))
            }
            
            guard httpResponse.statusCode == 200 else {
                return .failure(NSError(domain: "VNCService", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Server returned status \(httpResponse.statusCode)"]))
            }
            
            let status = try JSONDecoder().decode(VNCStatus.self, from: data)
            return .success(status)
        } catch {
            return .failure(error)
        }
    }
    
    // MARK: - Restart x11vnc
    
    struct RestartResult: Codable {
        let success: Bool
        let message: String?
        let processInfo: String?
        let error: String?
    }
    
    func restartVNC(server: RemoteServer) async -> Result<RestartResult, Error> {
        guard let url = URL(string: "\(backendURL)/api/vnc/restart") else {
            return .failure(NSError(domain: "VNCService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]))
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 30.0
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                return .failure(NSError(domain: "VNCService", code: -2, userInfo: [NSLocalizedDescriptionKey: "Invalid response"]))
            }
            
            guard httpResponse.statusCode == 200 else {
                if let errorData = try? JSONDecoder().decode([String: String].self, from: data),
                   let errorMsg = errorData["error"] {
                    return .failure(NSError(domain: "VNCService", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMsg]))
                }
                return .failure(NSError(domain: "VNCService", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Server returned status \(httpResponse.statusCode)"]))
            }
            
            let result = try JSONDecoder().decode(RestartResult.self, from: data)
            return .success(result)
        } catch {
            return .failure(error)
        }
    }
    
    // MARK: - Keyboard Settings
    
    struct KeyboardSettings: Codable {
        let keyboardRepeat: Bool
        let repeatRate: RepeatRate?
        
        struct RepeatRate: Codable {
            let delay: Int
            let rate: Int
        }
    }
    
    func getKeyboardSettings(server: RemoteServer) async -> Result<KeyboardSettings, Error> {
        guard let url = URL(string: "\(backendURL)/api/vnc/keyboard-settings") else {
            return .failure(NSError(domain: "VNCService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]))
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 10.0
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                return .failure(NSError(domain: "VNCService", code: -2, userInfo: [NSLocalizedDescriptionKey: "Invalid response"]))
            }
            
            guard httpResponse.statusCode == 200 else {
                return .failure(NSError(domain: "VNCService", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Server returned status \(httpResponse.statusCode)"]))
            }
            
            let settings = try JSONDecoder().decode(KeyboardSettings.self, from: data)
            return .success(settings)
        } catch {
            return .failure(error)
        }
    }
    
    func enableKeyboardRepeat(server: RemoteServer) async -> Result<Bool, Error> {
        guard let url = URL(string: "\(backendURL)/api/vnc/enable-keyboard-repeat") else {
            return .failure(NSError(domain: "VNCService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]))
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 10.0
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                return .failure(NSError(domain: "VNCService", code: -2, userInfo: [NSLocalizedDescriptionKey: "Invalid response"]))
            }
            
            guard httpResponse.statusCode == 200 else {
                return .failure(NSError(domain: "VNCService", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Server returned status \(httpResponse.statusCode)"]))
            }
            
            if let result = try? JSONDecoder().decode([String: Bool].self, from: data),
               let success = result["success"] {
                return .success(success)
            }
            return .success(true)
        } catch {
            return .failure(error)
        }
    }
    
    // MARK: - Logs
    
    struct VNCLogs: Codable {
        let logs: String
        let lines: Int
    }
    
    func getLogs(server: RemoteServer, lines: Int = 50) async -> Result<VNCLogs, Error> {
        guard let url = URL(string: "\(backendURL)/api/vnc/logs?lines=\(lines)") else {
            return .failure(NSError(domain: "VNCService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]))
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 10.0
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                return .failure(NSError(domain: "VNCService", code: -2, userInfo: [NSLocalizedDescriptionKey: "Invalid response"]))
            }
            
            guard httpResponse.statusCode == 200 else {
                return .failure(NSError(domain: "VNCService", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Server returned status \(httpResponse.statusCode)"]))
            }
            
            let logs = try JSONDecoder().decode(VNCLogs.self, from: data)
            return .success(logs)
        } catch {
            return .failure(error)
        }
    }
}


