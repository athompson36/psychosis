//
//  APIClient.swift
//  Psychosis
//
//  Created on [Current Date]
//

import Foundation

class APIClient {
    static let shared = APIClient()
    
    private let baseURL: String
    
    init(baseURL: String = "http://localhost:3000/api") {
        self.baseURL = baseURL
    }
    
    // MARK: - Tools API
    
    func getTools() async throws -> [Tool] {
        try await request<[Tool]>(endpoint: "/tools", method: "GET")
    }
    
    // MARK: - Files API
    
    func getFileTree(path: String = "/") async throws -> [FileItem] {
        let encodedPath = path.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? ""
        return try await request<[FileItem]>(endpoint: "/files/tree?path=\(encodedPath)", method: "GET")
    }
    
    func getFileContent(path: String) async throws -> FileItem {
        let encodedPath = path.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? ""
        return try await request<FileItem>(endpoint: "/files/content?path=\(encodedPath)", method: "GET")
    }
    
    func saveFile(path: String, content: String) async throws {
        struct SaveRequest: Codable {
            let path: String
            let content: String
        }
        
        struct SaveResponse: Codable {
            let success: Bool?
        }
        
        let body = SaveRequest(path: path, content: content)
        _ = try await request<SaveResponse, SaveRequest>(endpoint: "/files/save", method: "POST", body: body)
    }
    
    // MARK: - Chat API
    
    func sendChatMessage(message: String, context: ChatContext? = nil) async throws -> ChatResponse {
        struct ChatRequest: Codable {
            let message: String
            let context: ChatContext?
        }
        
        let body = ChatRequest(message: message, context: context)
        return try await request<ChatResponse>(endpoint: "/chat", method: "POST", body: body)
    }
    
    // MARK: - Generic Request
    
    private func request<T: Decodable>(
        endpoint: String,
        method: String
    ) async throws -> T {
        guard let url = URL(string: baseURL + endpoint) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIError.httpError(httpResponse.statusCode)
        }
        
        return try JSONDecoder().decode(T.self, from: data)
    }
    
    private func request<T: Decodable, B: Encodable>(
        endpoint: String,
        method: String,
        body: B
    ) async throws -> T {
        guard let url = URL(string: baseURL + endpoint) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIError.httpError(httpResponse.statusCode)
        }
        
        return try JSONDecoder().decode(T.self, from: data)
    }
}

// MARK: - Models

struct Tool: Identifiable, Codable {
    let id: String
    let name: String
    let type: String
    let url: String
}

struct ChatContext: Codable {
    let file: String?
    let code: String?
}

struct ChatResponse: Codable {
    let response: String
    let suggestions: [String]?
}

// MARK: - Errors

enum APIError: Error {
    case invalidURL
    case invalidResponse
    case httpError(Int)
    case decodingError
}

