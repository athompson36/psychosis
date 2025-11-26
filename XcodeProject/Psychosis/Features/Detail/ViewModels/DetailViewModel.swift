//
//  DetailViewModel.swift
//  Psychosis
//
//  Created on [Current Date]
//

import Foundation

/// ViewModel for Detail screen
@Observable
final class DetailViewModel {
    // MARK: - Properties
    
    var item: DetailItem?
    var isLoading = false
    var errorMessage: String?
    
    // MARK: - Initialization
    
    init(item: DetailItem? = nil) {
        self.item = item
    }
    
    // MARK: - Public Methods
    
    /// Load detail item
    @MainActor
    func loadItem(id: UUID) async {
        isLoading = true
        errorMessage = nil
        
        // Simulate async loading
        do {
            try await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds
            
            // In a real app, this would fetch from API or storage
            // For now, create a sample item
            item = DetailItem(
                id: id,
                title: "Sample Detail",
                description: "This is a detail view example",
                content: """
                This is a detailed view demonstrating navigation in the Psychosis app.
                
                You can use this pattern to show detailed information about any item.
                
                Features:
                • Clean MVVM architecture
                • SwiftUI navigation
                • Async data loading
                • Error handling
                """,
                iconName: "doc.text.fill"
            )
            
            isLoading = false
        } catch {
            errorMessage = "Failed to load detail: \(error.localizedDescription)"
            isLoading = false
        }
    }
}

