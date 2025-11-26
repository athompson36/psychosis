//
//  FavoritesViewModel.swift
//  Psychosis
//
//  Created on [Current Date]
//

import Foundation

/// ViewModel for Favorites screen
@Observable
final class FavoritesViewModel {
    // MARK: - Properties
    
    var favorites: [FavoriteItem] = []
    var isLoading = false
    var errorMessage: String?
    var selectedCategory: String? = nil
    
    // MARK: - Dependencies
    
    private let storageManager: StorageManager
    
    // MARK: - Initialization
    
    init(storageManager: StorageManager = DefaultStorageManager()) {
        self.storageManager = storageManager
    }
    
    // MARK: - Computed Properties
    
    var categories: [String] {
        Array(Set(favorites.map { $0.category })).sorted()
    }
    
    var filteredFavorites: [FavoriteItem] {
        if let category = selectedCategory {
            return favorites.filter { $0.category == category }
        }
        return favorites
    }
    
    // MARK: - Public Methods
    
    /// Load favorites
    @MainActor
    func loadFavorites() async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds
            
            if let saved: [FavoriteItem] = try? storageManager.load([FavoriteItem].self, forKey: Constants.StorageKeys.favorites) {
                favorites = saved
            } else {
                favorites = []
            }
            
            isLoading = false
        } catch {
            errorMessage = "Failed to load favorites: \(error.localizedDescription)"
            isLoading = false
        }
    }
    
    /// Add favorite
    func addFavorite(_ item: FavoriteItem) {
        if !favorites.contains(where: { $0.id == item.id }) {
            favorites.append(item)
            try? saveFavorites()
        }
    }
    
    /// Remove favorite
    func removeFavorite(_ item: FavoriteItem) {
        favorites.removeAll { $0.id == item.id }
        try? saveFavorites()
    }
    
    /// Toggle favorite
    func toggleFavorite(_ item: FavoriteItem) {
        if favorites.contains(where: { $0.id == item.id }) {
            removeFavorite(item)
        } else {
            addFavorite(item)
        }
    }
    
    /// Check if item is favorited
    func isFavorited(_ itemId: UUID) -> Bool {
        favorites.contains(where: { $0.id == itemId })
    }
    
    /// Filter by category
    func filterByCategory(_ category: String?) {
        selectedCategory = category
    }
    
    // MARK: - Private Methods
    
    private func saveFavorites() throws {
        try storageManager.save(favorites, forKey: Constants.StorageKeys.favorites)
    }
}

