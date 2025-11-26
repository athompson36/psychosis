//
//  SearchViewModel.swift
//  Psychosis
//
//  Created on [Current Date]
//

import Foundation

/// ViewModel for Search screen
@Observable
final class SearchViewModel {
    // MARK: - Properties
    
    var searchText = ""
    var results: [SearchResult] = []
    var selectedCategory: SearchCategory = .all
    var isSearching = false
    
    // MARK: - Private Properties
    
    private let allItems: [SearchResult] = [
        SearchResult(
            title: "Welcome to Psychosis",
            description: "Main dashboard screen",
            category: .home,
            iconName: "house.fill"
        ),
        SearchResult(
            title: "Settings",
            description: "App preferences and configuration",
            category: .settings,
            iconName: "gearshape.fill"
        ),
        SearchResult(
            title: "Profile",
            description: "User profile and information",
            category: .profile,
            iconName: "person.fill"
        ),
        SearchResult(
            title: "Detail View",
            description: "Detailed information display",
            category: .detail,
            iconName: "doc.text.fill"
        )
    ]
    
    // MARK: - Public Methods
    
    /// Perform search
    func performSearch() {
        isSearching = true
        
        // Simulate search delay
        Task {
            try? await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds
            
            if searchText.isEmpty {
                results = []
            } else {
                results = allItems.filter { item in
                    let matchesText = item.title.localizedCaseInsensitiveContains(searchText) ||
                                    item.description.localizedCaseInsensitiveContains(searchText)
                    let matchesCategory = selectedCategory == .all || item.category == selectedCategory
                    return matchesText && matchesCategory
                }
            }
            
            isSearching = false
        }
    }
    
    /// Clear search
    func clearSearch() {
        searchText = ""
        results = []
    }
    
    /// Filter by category
    func filterByCategory(_ category: SearchCategory) {
        selectedCategory = category
        performSearch()
    }
}

