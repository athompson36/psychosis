//
//  AnalyticsViewModel.swift
//  Psychosis
//
//  Created on [Current Date]
//

import Foundation

/// ViewModel for Analytics screen
@Observable
final class AnalyticsViewModel {
    // MARK: - Properties
    
    var analyticsData: AnalyticsData = AnalyticsData()
    var isLoading = false
    var errorMessage: String?
    
    // MARK: - Dependencies
    
    private let storageManager: StorageManager
    
    // MARK: - Initialization
    
    init(storageManager: StorageManager = DefaultStorageManager()) {
        self.storageManager = storageManager
    }
    
    // MARK: - Computed Properties
    
    var taskCompletionRate: Double {
        guard analyticsData.totalTasks > 0 else { return 0 }
        return Double(analyticsData.completedTasks) / Double(analyticsData.totalTasks) * 100
    }
    
    var taskChartData: [ChartDataPoint] {
        [
            ChartDataPoint(label: "Completed", value: Double(analyticsData.completedTasks), color: "green"),
            ChartDataPoint(label: "Active", value: Double(analyticsData.activeTasks), color: "orange")
        ]
    }
    
    var mediaChartData: [ChartDataPoint] {
        [
            ChartDataPoint(label: "Favorites", value: Double(analyticsData.favoriteMedia), color: "red"),
            ChartDataPoint(label: "Total", value: Double(analyticsData.totalMedia - analyticsData.favoriteMedia), color: "blue")
        ]
    }
    
    // MARK: - Public Methods
    
    /// Load analytics
    @MainActor
    func loadAnalytics() async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds
            
            // Load data from all features
            await updateAnalyticsData()
            
            isLoading = false
        } catch {
            errorMessage = "Failed to load analytics: \(error.localizedDescription)"
            isLoading = false
        }
    }
    
    /// Refresh analytics
    @MainActor
    func refreshAnalytics() async {
        await updateAnalyticsData()
    }
    
    // MARK: - Private Methods
    
    private func updateAnalyticsData() async {
        // Load tasks
        if let tasks: [TaskItem] = try? storageManager.load([TaskItem].self, forKey: Constants.StorageKeys.tasks) {
            analyticsData.totalTasks = tasks.count
            analyticsData.completedTasks = tasks.filter { $0.isCompleted }.count
            analyticsData.activeTasks = tasks.filter { !$0.isCompleted }.count
        }
        
        // Load notes
        if let notes: [Note] = try? storageManager.load([Note].self, forKey: Constants.StorageKeys.notes) {
            analyticsData.totalNotes = notes.count
        }
        
        // Load events
        if let events: [CalendarEvent] = try? storageManager.load([CalendarEvent].self, forKey: Constants.StorageKeys.calendarEvents) {
            analyticsData.totalEvents = events.count
            analyticsData.upcomingEvents = events.filter { $0.startDate >= Date() }.count
        }
        
        // Load media
        if let media: [MediaItem] = try? storageManager.load([MediaItem].self, forKey: Constants.StorageKeys.media) {
            analyticsData.totalMedia = media.count
            analyticsData.favoriteMedia = media.filter { $0.isFavorite }.count
        }
        
        analyticsData.lastUpdated = Date()
        
        // Save analytics
        try? storageManager.save(analyticsData, forKey: Constants.StorageKeys.analytics)
    }
}

