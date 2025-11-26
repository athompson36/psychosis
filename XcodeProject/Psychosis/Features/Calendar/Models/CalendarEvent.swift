//
//  CalendarEvent.swift
//  Psychosis
//
//  Created on [Current Date]
//

import Foundation

/// Calendar event model
struct CalendarEvent: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var description: String
    var startDate: Date
    var endDate: Date
    var isAllDay: Bool
    var location: String?
    var color: EventColor
    var reminder: ReminderType
    
    init(
        id: UUID = UUID(),
        title: String,
        description: String = "",
        startDate: Date,
        endDate: Date? = nil,
        isAllDay: Bool = false,
        location: String? = nil,
        color: EventColor = .blue,
        reminder: ReminderType = .none
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.startDate = startDate
        self.endDate = endDate ?? startDate.addingTimeInterval(3600) // Default 1 hour
        self.isAllDay = isAllDay
        self.location = location
        self.color = color
        self.reminder = reminder
    }
}

enum EventColor: String, Codable, CaseIterable {
    case blue = "Blue"
    case green = "Green"
    case orange = "Orange"
    case red = "Red"
    case purple = "Purple"
    case pink = "Pink"
    
    var colorValue: String {
        rawValue.lowercased()
    }
}

enum ReminderType: String, Codable, CaseIterable {
    case none = "None"
    case fiveMinutes = "5 minutes before"
    case fifteenMinutes = "15 minutes before"
    case thirtyMinutes = "30 minutes before"
    case oneHour = "1 hour before"
    case oneDay = "1 day before"
}

