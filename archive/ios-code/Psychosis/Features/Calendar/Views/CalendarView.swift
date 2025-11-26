//
//  CalendarView.swift
//  Psychosis
//
//  Created on [Current Date]
//

import SwiftUI

/// Calendar screen view
struct CalendarView: View {
    @State private var viewModel = CalendarViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.Colors.background
                    .ignoresSafeArea()
                
                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                } else if let errorMessage = viewModel.errorMessage {
                    ErrorView(message: errorMessage) {
                        Task {
                            await viewModel.loadEvents()
                        }
                    }
                } else {
                    calendarContent
                }
            }
            .navigationTitle("Calendar")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        viewModel.showingAddEvent = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $viewModel.showingAddEvent) {
                AddEventView(viewModel: viewModel)
            }
            .sheet(item: $viewModel.editingEvent) { event in
                EditEventView(event: event, viewModel: viewModel)
            }
            .task {
                await viewModel.loadEvents()
            }
            .refreshable {
                await viewModel.loadEvents()
            }
        }
    }
    
    // MARK: - Calendar Content
    
    private var calendarContent: some View {
        ScrollView {
            VStack(spacing: AppTheme.Spacing.large) {
                // Calendar Picker
                calendarPicker
                
                // Selected Date Events
                selectedDateEvents
                
                // Upcoming Events
                upcomingEventsSection
            }
            .padding(AppTheme.Spacing.medium)
        }
    }
    
    // MARK: - Calendar Picker
    
    private var calendarPicker: some View {
        VStack(spacing: AppTheme.Spacing.medium) {
            DatePicker(
                "Select Date",
                selection: $viewModel.selectedDate,
                displayedComponents: [.date]
            )
            .datePickerStyle(.graphical)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.large)
                    .fill(Color(.systemGray6))
            )
        }
    }
    
    // MARK: - Selected Date Events
    
    private var selectedDateEvents: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.medium) {
            Text("Events for \(formatDate(viewModel.selectedDate))")
                .font(AppTheme.Typography.title2)
                .foregroundColor(AppTheme.Colors.foreground)
            
            if viewModel.eventsForSelectedDate.isEmpty {
                emptyEventsView
            } else {
                ForEach(viewModel.eventsForSelectedDate) { event in
                    EventRow(event: event) {
                        viewModel.editingEvent = event
                    }
                }
            }
        }
    }
    
    private var emptyEventsView: some View {
        VStack(spacing: AppTheme.Spacing.medium) {
            Image(systemName: "calendar")
                .font(.system(size: 40))
                .foregroundColor(AppTheme.Colors.secondary)
            
            Text("No events")
                .font(AppTheme.Typography.body)
                .foregroundColor(AppTheme.Colors.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(AppTheme.Spacing.large)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                .fill(Color(.systemGray6))
        )
    }
    
    // MARK: - Upcoming Events
    
    private var upcomingEventsSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.medium) {
            Text("Upcoming")
                .font(AppTheme.Typography.title2)
                .foregroundColor(AppTheme.Colors.foreground)
            
            if viewModel.upcomingEvents.isEmpty {
                Text("No upcoming events")
                    .font(AppTheme.Typography.body)
                    .foregroundColor(AppTheme.Colors.secondary)
                    .padding()
            } else {
                ForEach(viewModel.upcomingEvents) { event in
                    EventRow(event: event) {
                        viewModel.editingEvent = event
                    }
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter.string(from: date)
    }
}

// MARK: - Event Row

struct EventRow: View {
    let event: CalendarEvent
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: AppTheme.Spacing.medium) {
                // Color Indicator
                RoundedRectangle(cornerRadius: 4)
                    .fill(colorForEvent(event.color))
                    .frame(width: 4)
                
                // Content
                VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
                    Text(event.title)
                        .font(AppTheme.Typography.body)
                        .foregroundColor(AppTheme.Colors.foreground)
                        .fontWeight(.semibold)
                    
                    if !event.description.isEmpty {
                        Text(event.description)
                            .font(AppTheme.Typography.caption)
                            .foregroundColor(AppTheme.Colors.secondary)
                            .lineLimit(2)
                    }
                    
                    HStack {
                        Image(systemName: "clock")
                            .font(.system(size: 11))
                        Text(formatTimeRange(event.startDate, endDate: event.endDate, isAllDay: event.isAllDay))
                            .font(.system(size: 11))
                        
                        if let location = event.location {
                            Spacer()
                            Image(systemName: "location")
                                .font(.system(size: 11))
                            Text(location)
                                .font(.system(size: 11))
                        }
                    }
                    .foregroundColor(AppTheme.Colors.secondary)
                }
                
                Spacer()
            }
            .padding(AppTheme.Spacing.medium)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
            )
        }
        .buttonStyle(.plain)
    }
    
    private func colorForEvent(_ color: EventColor) -> Color {
        switch color {
        case .blue: return .blue
        case .green: return .green
        case .orange: return .orange
        case .red: return .red
        case .purple: return .purple
        case .pink: return .pink
        }
    }
    
    private func formatTimeRange(_ startDate: Date, endDate: Date, isAllDay: Bool) -> String {
        if isAllDay {
            return "All Day"
        }
        
        let timeFormatter = DateFormatter()
        timeFormatter.timeStyle = .short
        
        let startTime = timeFormatter.string(from: startDate)
        let endTime = timeFormatter.string(from: endDate)
        
        return "\(startTime) - \(endTime)"
    }
}

// MARK: - Add Event View

struct AddEventView: View {
    @Environment(\.dismiss) var dismiss
    @Bindable var viewModel: CalendarViewModel
    
    @State private var title = ""
    @State private var description = ""
    @State private var startDate = Date()
    @State private var endDate = Date().addingTimeInterval(3600)
    @State private var isAllDay = false
    @State private var location = ""
    @State private var color: EventColor = .blue
    @State private var reminder: ReminderType = .none
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Event Details") {
                    TextField("Title", text: $title)
                    TextField("Description", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                    TextField("Location", text: $location)
                }
                
                Section("Time") {
                    Toggle("All Day", isOn: $isAllDay)
                    
                    DatePicker("Start", selection: $startDate, displayedComponents: isAllDay ? [.date] : [.date, .hourAndMinute])
                    DatePicker("End", selection: $endDate, displayedComponents: isAllDay ? [.date] : [.date, .hourAndMinute])
                }
                
                Section("Options") {
                    Picker("Color", selection: $color) {
                        ForEach(EventColor.allCases, id: \.self) { color in
                            Text(color.rawValue).tag(color)
                        }
                    }
                    
                    Picker("Reminder", selection: $reminder) {
                        ForEach(ReminderType.allCases, id: \.self) { reminder in
                            Text(reminder.rawValue).tag(reminder)
                        }
                    }
                }
            }
            .navigationTitle("New Event")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let newEvent = CalendarEvent(
                            title: title,
                            description: description,
                            startDate: startDate,
                            endDate: endDate,
                            isAllDay: isAllDay,
                            location: location.isEmpty ? nil : location,
                            color: color,
                            reminder: reminder
                        )
                        viewModel.addEvent(newEvent)
                        dismiss()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
}

// MARK: - Edit Event View

struct EditEventView: View {
    @Environment(\.dismiss) var dismiss
    let event: CalendarEvent
    @Bindable var viewModel: CalendarViewModel
    
    @State private var title: String
    @State private var description: String
    @State private var startDate: Date
    @State private var endDate: Date
    @State private var isAllDay: Bool
    @State private var location: String
    @State private var color: EventColor
    @State private var reminder: ReminderType
    
    init(event: CalendarEvent, viewModel: CalendarViewModel) {
        self.event = event
        self.viewModel = viewModel
        _title = State(initialValue: event.title)
        _description = State(initialValue: event.description)
        _startDate = State(initialValue: event.startDate)
        _endDate = State(initialValue: event.endDate)
        _isAllDay = State(initialValue: event.isAllDay)
        _location = State(initialValue: event.location ?? "")
        _color = State(initialValue: event.color)
        _reminder = State(initialValue: event.reminder)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Event Details") {
                    TextField("Title", text: $title)
                    TextField("Description", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                    TextField("Location", text: $location)
                }
                
                Section("Time") {
                    Toggle("All Day", isOn: $isAllDay)
                    
                    DatePicker("Start", selection: $startDate, displayedComponents: isAllDay ? [.date] : [.date, .hourAndMinute])
                    DatePicker("End", selection: $endDate, displayedComponents: isAllDay ? [.date] : [.date, .hourAndMinute])
                }
                
                Section("Options") {
                    Picker("Color", selection: $color) {
                        ForEach(EventColor.allCases, id: \.self) { color in
                            Text(color.rawValue).tag(color)
                        }
                    }
                    
                    Picker("Reminder", selection: $reminder) {
                        ForEach(ReminderType.allCases, id: \.self) { reminder in
                            Text(reminder.rawValue).tag(reminder)
                        }
                    }
                }
            }
            .navigationTitle("Edit Event")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        var updatedEvent = event
                        updatedEvent.title = title
                        updatedEvent.description = description
                        updatedEvent.startDate = startDate
                        updatedEvent.endDate = endDate
                        updatedEvent.isAllDay = isAllDay
                        updatedEvent.location = location.isEmpty ? nil : location
                        updatedEvent.color = color
                        updatedEvent.reminder = reminder
                        viewModel.updateEvent(updatedEvent)
                        dismiss()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    CalendarView()
}

