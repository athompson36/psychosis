//
//  ConnectionQualityMonitor.swift
//  HubApp
//
//  Created on [Current Date]
//

import Foundation
import SwiftUI

@MainActor
class ConnectionQualityMonitor: ObservableObject {
    static let shared = ConnectionQualityMonitor()
    
    @Published var quality: ConnectionQuality = .unknown
    @Published var latency: TimeInterval?
    @Published var lastUpdate: Date?
    
    private var monitoringTask: Task<Void, Never>?
    private var testURL: URL?
    
    enum ConnectionQuality {
        case excellent
        case good
        case fair
        case poor
        case disconnected
        case unknown
        
        var color: Color {
            switch self {
            case .excellent: return .green
            case .good: return .blue
            case .fair: return .yellow
            case .poor: return .orange
            case .disconnected: return .red
            case .unknown: return .gray
            }
        }
        
        var icon: String {
            switch self {
            case .excellent: return "signal.3.bars"
            case .good: return "signal.2.bars"
            case .fair: return "signal.1.bar"
            case .poor: return "exclamationmark.triangle"
            case .disconnected: return "xmark.circle"
            case .unknown: return "questionmark.circle"
            }
        }
        
        var description: String {
            switch self {
            case .excellent: return "Excellent"
            case .good: return "Good"
            case .fair: return "Fair"
            case .poor: return "Poor"
            case .disconnected: return "Disconnected"
            case .unknown: return "Unknown"
            }
        }
        
        static func fromLatency(_ latency: TimeInterval?) -> ConnectionQuality {
            guard let latency = latency else { return .unknown }
            
            if latency < 50 {
                return .excellent
            } else if latency < 100 {
                return .good
            } else if latency < 200 {
                return .fair
            } else {
                return .poor
            }
        }
    }
    
    private init() {}
    
    func startMonitoring(url: URL) {
        stopMonitoring()
        testURL = url
        
        monitoringTask = Task {
            while !Task.isCancelled {
                await measureLatency()
                try? await Task.sleep(nanoseconds: 5_000_000_000) // Check every 5 seconds
            }
        }
    }
    
    func stopMonitoring() {
        monitoringTask?.cancel()
        monitoringTask = nil
        quality = .unknown
        latency = nil
        lastUpdate = nil
    }
    
    private func measureLatency() async {
        guard let url = testURL else {
            quality = .disconnected
            return
        }
        
        let startTime = Date()
        
        do {
            var request = URLRequest(url: url)
            request.timeoutInterval = 3.0
            request.httpMethod = "HEAD"
            request.cachePolicy = .reloadIgnoringLocalCacheData
            
            let (_, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse,
               (200...299).contains(httpResponse.statusCode) {
                let measuredLatency = Date().timeIntervalSince(startTime) * 1000 // Convert to milliseconds
                
                await MainActor.run {
                    latency = measuredLatency
                    quality = .fromLatency(measuredLatency)
                    lastUpdate = Date()
                }
            } else {
                await MainActor.run {
                    quality = .disconnected
                }
            }
        } catch {
            await MainActor.run {
                quality = .disconnected
                latency = nil
            }
        }
    }
}

