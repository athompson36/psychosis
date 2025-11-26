//
//  HomeViewModel.swift
//  Psychosis
//
//  Created on [Current Date]
//

import Foundation
import SwiftUI

/// ViewModel for the Home screen following MVVM pattern
@Observable
final class HomeViewModel {
    // MARK: - Properties
    
    var items: [HomeItem] = []
    var isLoading = false
    var errorMessage: String?
    
    // MARK: - Dependencies
    
    private let storageManager: StorageManager
    
    // MARK: - Initialization
    
    init(storageManager: StorageManager = DefaultStorageManager()) {
        self.storageManager = storageManager
    }
    
    // MARK: - Public Methods
    
    /// Load home screen data
    @MainActor
    func loadData() async {
        isLoading = true
        errorMessage = nil
        
        // Simulate async operation
        do {
            try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
            
            // Try to load from storage first
            if let savedItems: [HomeItem] = try? storageManager.load([HomeItem].self, forKey: Constants.StorageKeys.homeItems) {
                items = savedItems
            } else {
                // Load default items if nothing saved
                items = createDefaultItems()
                try? saveItems()
            }
            
            isLoading = false
        } catch {
            errorMessage = "Failed to load data: \(error.localizedDescription)"
            isLoading = false
        }
    }
    
    /// Refresh home screen data
    @MainActor
    func refresh() async {
        await loadData()
    }
    
    /// Add a new item
    @MainActor
    func addItem(title: String, description: String, iconName: String) {
        let newItem = HomeItem(
            title: title,
            description: description,
            iconName: iconName
        )
        items.append(newItem)
        try? saveItems()
    }
    
    /// Delete an item
    @MainActor
    func deleteItem(at indexSet: IndexSet) {
        items.remove(atOffsets: indexSet)
        try? saveItems()
    }
    
    // MARK: - Private Methods
    
    private func createDefaultItems() -> [HomeItem] {
        [
            HomeItem(
                title: "Welcome to Psychosis",
                description: "Your journey begins here",
                iconName: "star.fill"
            ),
            HomeItem(
                title: "Getting Started",
                description: "Explore the features and capabilities",
                iconName: "book.fill"
            ),
            HomeItem(
                title: "Settings",
                description: "Customize your experience",
                iconName: "gearshape.fill"
            )
        ]
    }
    
    private func saveItems() throws {
        try storageManager.save(items, forKey: Constants.StorageKeys.homeItems)
    }
}

