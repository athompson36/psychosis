//
//  CalendarViewModel.swift
//  Psychosis
//
//  Created on [Current Date]
//

import Foundation

/// ViewModel for Calendar screen
@Observable
final class CalendarViewModel {
    // MARK: - Properties
    
    var events: [CalendarEvent] = []
    var isLoading = false
    var errorMessage: String?
    var selectedDate: Date = Date()
    var showingAddEvent = false
    var editingEvent: CalendarEvent? = nil
    
    // MARK: - Dependencies
    
    private let storageManager: StorageManager
    
    // MARK: - Initialization
    
    init(storageManager: StorageManager = DefaultStorageManager()) {
        self.storageManager = storageManager
    }
    
    // MARK: - Computed Properties
    
    var eventsForSelectedDate: [CalendarEvent] {
        events.filter { event in
            Calendar.current.isDate(event.startDate, inSameDayAs: selectedDate) ||
            Calendar.current.isDate(event.endDate, inSameDayAs: selectedDate) ||
            (event.startDate <= selectedDate && event.endDate >= selectedDate)
        }
        .sorted { $0.startDate < $1.startDate }
    }
    
    var upcomingEvents: [CalendarEvent] {
        events.filter { $0.startDate >= Date() }
            .sorted { $0.startDate < $1.startDate }
            .prefix(5)
            .map { $0 }
    }
    
    // MARK: - Public Methods
    
    /// Load events
    @MainActor
    func loadEvents() async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds
            
            if let saved: [CalendarEvent] = try? storageManager.load([CalendarEvent].self, forKey: Constants.StorageKeys.calendarEvents) {
                events = saved
            } else {
                events = createSampleEvents()
                try? saveEvents()
            }
            
            isLoading = false
        } catch {
            errorMessage = "Failed to load events: \(error.localizedDescription)"
            isLoading = false
        }
    }
    
    /// Add event
    func addEvent(_ event: CalendarEvent) {
        events.append(event)
        try? saveEvents()
    }
    
    /// Update event
    func updateEvent(_ event: CalendarEvent) {
        guard let index = events.firstIndex(where: { $0.id == event.id }) else { return }
        events[index] = event
        try? saveEvents()
    }
    
    /// Delete event
    func deleteEvent(_ event: CalendarEvent) {
        events.removeAll { $0.id == event.id }
        try? saveEvents()
    }
    
    /// Select date
    func selectDate(_ date: Date) {
        selectedDate = date
    }
    
    // MARK: - Private Methods
    
    private func createSampleEvents() -> [CalendarEvent] {
        let today = Date()
        return [
            CalendarEvent(
                title: "Team Meeting",
                description: "Weekly team sync",
                startDate: Calendar.current.date(byAdding: .hour, value: 2, to: today) ?? today,
                endDate: Calendar.current.date(byAdding: .hour, value: 3, to: today) ?? today,
                color: .blue
            ),
            CalendarEvent(
                title: "Project Review",
                description: "Review progress on Psychosis app",
                startDate: Calendar.current.date(byAdding: .day, value: 1, to: today) ?? today,
                endDate: Calendar.current.date(byAdding: .day, value: 1, to: today) ?? today,
                isAllDay: true,
                color: .green
            )
        ]
    }
    
    private func saveEvents() throws {
        try storageManager.save(events, forKey: Constants.StorageKeys.calendarEvents)
    }
}

