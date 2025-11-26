//
//  HistoryViewModel.swift
//  Psychosis
//
//  Created on [Current Date]
//

import Foundation

/// ViewModel for History screen
@Observable
final class HistoryViewModel {
    // MARK: - Properties
    
    var historyItems: [HistoryItem] = []
    var isLoading = false
    var errorMessage: String?
    
    // MARK: - Dependencies
    
    private let storageManager: StorageManager
    
    // MARK: - Initialization
    
    init(storageManager: StorageManager = DefaultStorageManager()) {
        self.storageManager = storageManager
    }
    
    // MARK: - Computed Properties
    
    var groupedHistory: [String: [HistoryItem]] {
        Dictionary(grouping: historyItems) { item in
            formatDateGroup(item.timestamp)
        }
    }
    
    var sortedGroups: [String] {
        groupedHistory.keys.sorted { date1, date2 in
            guard let d1 = parseDateGroup(date1),
                  let d2 = parseDateGroup(date2) else {
                return date1 > date2
            }
            return d1 > d2
        }
    }
    
    // MARK: - Public Methods
    
    /// Load history
    @MainActor
    func loadHistory() async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds
            
            if let saved: [HistoryItem] = try? storageManager.load([HistoryItem].self, forKey: Constants.StorageKeys.history) {
                historyItems = saved.sorted { $0.timestamp > $1.timestamp }
            } else {
                historyItems = createSampleHistory()
                try? saveHistory()
            }
            
            isLoading = false
        } catch {
            errorMessage = "Failed to load history: \(error.localizedDescription)"
            isLoading = false
        }
    }
    
    /// Add history item
    func addHistoryItem(_ item: HistoryItem) {
        historyItems.insert(item, at: 0)
        // Keep only last 100 items
        if historyItems.count > 100 {
            historyItems = Array(historyItems.prefix(100))
        }
        try? saveHistory()
    }
    
    /// Clear history
    func clearHistory() {
        historyItems.removeAll()
        try? saveHistory()
    }
    
    /// Delete history item
    func deleteHistoryItem(_ item: HistoryItem) {
        historyItems.removeAll { $0.id == item.id }
        try? saveHistory()
    }
    
    // MARK: - Private Methods
    
    private func createSampleHistory() -> [HistoryItem] {
        [
            HistoryItem(
                title: "Viewed Profile",
                description: "Opened profile screen",
                iconName: "person.fill",
                action: "view",
                timestamp: Date().addingTimeInterval(-3600)
            ),
            HistoryItem(
                title: "Searched",
                description: "Searched for 'settings'",
                iconName: "magnifyingglass",
                action: "search",
                timestamp: Date().addingTimeInterval(-7200)
            ),
            HistoryItem(
                title: "Opened Settings",
                description: "Accessed settings screen",
                iconName: "gearshape.fill",
                action: "open",
                timestamp: Date().addingTimeInterval(-86400)
            )
        ]
    }
    
    private func saveHistory() throws {
        try storageManager.save(historyItems, forKey: Constants.StorageKeys.history)
    }
    
    private func formatDateGroup(_ date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMMM d, yyyy"
            return formatter.string(from: date)
        }
    }
    
    private func parseDateGroup(_ group: String) -> Date? {
        if group == "Today" {
            return Date()
        } else if group == "Yesterday" {
            return Calendar.current.date(byAdding: .day, value: -1, to: Date())
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMMM d, yyyy"
            return formatter.date(from: group)
        }
    }
}

