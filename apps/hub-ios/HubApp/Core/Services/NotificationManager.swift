//
//  NotificationManager.swift
//  HubApp
//
//  Created on [Current Date]
//

import Foundation
import UserNotifications

@MainActor
class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    
    private init() {
        requestAuthorization()
    }
    
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Notification authorization error: \(error)")
            }
        }
    }
    
    func notifyConnectionSuccess(serverName: String) {
        let content = UNMutableNotificationContent()
        content.title = "Connected"
        content.body = "Successfully connected to \(serverName)"
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    
    func notifyConnectionFailed(serverName: String, error: String) {
        let content = UNMutableNotificationContent()
        content.title = "Connection Failed"
        content.body = "Failed to connect to \(serverName): \(error)"
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    
    func notifyConnectionLost(serverName: String) {
        let content = UNMutableNotificationContent()
        content.title = "Connection Lost"
        content.body = "Connection to \(serverName) was lost"
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    
    func notifyQualityWarning(serverName: String, quality: String) {
        let content = UNMutableNotificationContent()
        content.title = "Connection Quality Warning"
        content.body = "\(serverName): Connection quality is \(quality)"
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )
        
        UNUserNotificationCenter.current().add(request)
    }
}

