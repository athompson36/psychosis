//
//  RemindersViewModel.swift
//  Psychosis
//
//  Created on [Current Date]
//

import Foundation

/// ViewModel for Reminders screen
@Observable
final class RemindersViewModel {
    // MARK: - Properties
    
    var reminders: [Reminder] = []
    var isLoading = false
    var errorMessage: String?
    var filter: ReminderFilter = .all
    var searchText = ""
    var selectedCategory: String? = nil
    var showingAddReminder = false
    var editingReminder: Reminder? = nil
    
    // MARK: - Dependencies
    
    private let storageManager: StorageManager
    
    // MARK: - Initialization
    
    init(storageManager: StorageManager = DefaultStorageManager()) {
        self.storageManager = storageManager
    }
    
    // MARK: - Computed Properties
    
    var categories: [String] {
        Array(Set(reminders.map { $0.category })).sorted()
    }
    
    var filteredReminders: [Reminder] {
        var result = reminders
        
        // Apply filter
        switch filter {
        case .all:
            break
        case .active:
            result = result.filter { !$0.isCompleted }
        case .completed:
            result = result.filter { $0.isCompleted }
        case .dueToday:
            result = result.filter { reminder in
                Calendar.current.isDateInToday(reminder.dueDate)
            }
        case .overdue:
            result = result.filter { reminder in
                reminder.dueDate < Date() && !reminder.isCompleted
            }
        }
        
        // Apply category filter
        if let category = selectedCategory {
            result = result.filter { $0.category == category }
        }
        
        // Apply search
        if !searchText.isEmpty {
            result = result.filter { reminder in
                reminder.title.localizedCaseInsensitiveContains(searchText) ||
                reminder.description.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Sort by due date
        return result.sorted { $0.dueDate < $1.dueDate }
    }
    
    var overdueCount: Int {
        reminders.filter { $0.dueDate < Date() && !$0.isCompleted }.count
    }
    
    var dueTodayCount: Int {
        reminders.filter { Calendar.current.isDateInToday($0.dueDate) && !$0.isCompleted }.count
    }
    
    // MARK: - Public Methods
    
    /// Load reminders
    @MainActor
    func loadReminders() async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds
            
            if let saved: [Reminder] = try? storageManager.load([Reminder].self, forKey: Constants.StorageKeys.reminders) {
                reminders = saved
            } else {
                reminders = createSampleReminders()
                try? saveReminders()
            }
            
            isLoading = false
        } catch {
            errorMessage = "Failed to load reminders: \(error.localizedDescription)"
            isLoading = false
        }
    }
    
    /// Add reminder
    func addReminder(_ reminder: Reminder) {
        reminders.append(reminder)
        try? saveReminders()
    }
    
    /// Update reminder
    func updateReminder(_ reminder: Reminder) {
        guard let index = reminders.firstIndex(where: { $0.id == reminder.id }) else { return }
        reminders[index] = reminder
        try? saveReminders()
    }
    
    /// Delete reminder
    func deleteReminder(_ reminder: Reminder) {
        reminders.removeAll { $0.id == reminder.id }
        try? saveReminders()
    }
    
    /// Toggle completion
    func toggleCompletion(_ reminder: Reminder) {
        guard let index = reminders.firstIndex(where: { $0.id == reminder.id }) else { return }
        reminders[index].isCompleted.toggle()
        reminders[index].completedAt = reminders[index].isCompleted ? Date() : nil
        try? saveReminders()
    }
    
    /// Set filter
    func setFilter(_ filter: ReminderFilter) {
        self.filter = filter
    }
    
    /// Set category filter
    func setCategoryFilter(_ category: String?) {
        selectedCategory = category
    }
    
    // MARK: - Private Methods
    
    private func createSampleReminders() -> [Reminder] {
        let today = Date()
        return [
            Reminder(
                title: "Call dentist",
                description: "Schedule appointment",
                dueDate: Calendar.current.date(byAdding: .hour, value: 2, to: today) ?? today,
                priority: .high,
                category: "Health"
            ),
            Reminder(
                title: "Buy groceries",
                description: "Milk, eggs, bread",
                dueDate: Calendar.current.date(byAdding: .day, value: 1, to: today) ?? today,
                priority: .normal,
                category: "Shopping"
            )
        ]
    }
    
    private func saveReminders() throws {
        try storageManager.save(reminders, forKey: Constants.StorageKeys.reminders)
    }
}

enum ReminderFilter: String, CaseIterable {
    case all = "All"
    case active = "Active"
    case completed = "Completed"
    case dueToday = "Due Today"
    case overdue = "Overdue"
}

