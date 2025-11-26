//
//  AnalyticsData.swift
//  Psychosis
//
//  Created on [Current Date]
//

import Foundation

/// Analytics data model
struct AnalyticsData: Codable, Equatable {
    var totalTasks: Int
    var completedTasks: Int
    var activeTasks: Int
    var totalNotes: Int
    var totalEvents: Int
    var upcomingEvents: Int
    var totalMedia: Int
    var favoriteMedia: Int
    var lastUpdated: Date
    
    init(
        totalTasks: Int = 0,
        completedTasks: Int = 0,
        activeTasks: Int = 0,
        totalNotes: Int = 0,
        totalEvents: Int = 0,
        upcomingEvents: Int = 0,
        totalMedia: Int = 0,
        favoriteMedia: Int = 0,
        lastUpdated: Date = Date()
    ) {
        self.totalTasks = totalTasks
        self.completedTasks = completedTasks
        self.activeTasks = activeTasks
        self.totalNotes = totalNotes
        self.totalEvents = totalEvents
        self.upcomingEvents = upcomingEvents
        self.totalMedia = totalMedia
        self.favoriteMedia = favoriteMedia
        self.lastUpdated = lastUpdated
    }
}

struct ChartDataPoint: Identifiable {
    let id = UUID()
    let label: String
    let value: Double
    let color: String
}

