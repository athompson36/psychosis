//
//  MediaViewModel.swift
//  Psychosis
//
//  Created on [Current Date]
//

import Foundation

/// ViewModel for Media screen
@Observable
final class MediaViewModel {
    // MARK: - Properties
    
    var mediaItems: [MediaItem] = []
    var isLoading = false
    var errorMessage: String?
    var searchText = ""
    var selectedType: MediaType? = nil
    var selectedTag: String? = nil
    var showingAddMedia = false
    var viewingMedia: MediaItem? = nil
    
    // MARK: - Dependencies
    
    private let storageManager: StorageManager
    
    // MARK: - Initialization
    
    init(storageManager: StorageManager = DefaultStorageManager()) {
        self.storageManager = storageManager
    }
    
    // MARK: - Computed Properties
    
    var allTags: [String] {
        Array(Set(mediaItems.flatMap { $0.tags })).sorted()
    }
    
    var filteredMedia: [MediaItem] {
        var result = mediaItems
        
        // Filter by type
        if let type = selectedType {
            result = result.filter { $0.mediaType == type }
        }
        
        // Filter by tag
        if let tag = selectedTag {
            result = result.filter { $0.tags.contains(tag) }
        }
        
        // Filter by search
        if !searchText.isEmpty {
            result = result.filter { item in
                item.title.localizedCaseInsensitiveContains(searchText) ||
                item.description.localizedCaseInsensitiveContains(searchText) ||
                item.tags.contains { $0.localizedCaseInsensitiveContains(searchText) }
            }
        }
        
        // Sort by date (newest first)
        return result.sorted { $0.createdAt > $1.createdAt }
    }
    
    var favorites: [MediaItem] {
        mediaItems.filter { $0.isFavorite }
    }
    
    // MARK: - Public Methods
    
    /// Load media
    @MainActor
    func loadMedia() async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds
            
            if let saved: [MediaItem] = try? storageManager.load([MediaItem].self, forKey: Constants.StorageKeys.media) {
                mediaItems = saved
            } else {
                mediaItems = createSampleMedia()
                try? saveMedia()
            }
            
            isLoading = false
        } catch {
            errorMessage = "Failed to load media: \(error.localizedDescription)"
            isLoading = false
        }
    }
    
    /// Add media
    func addMedia(_ item: MediaItem) {
        mediaItems.append(item)
        try? saveMedia()
    }
    
    /// Update media
    func updateMedia(_ item: MediaItem) {
        guard let index = mediaItems.firstIndex(where: { $0.id == item.id }) else { return }
        mediaItems[index] = item
        try? saveMedia()
    }
    
    /// Delete media
    func deleteMedia(_ item: MediaItem) {
        mediaItems.removeAll { $0.id == item.id }
        try? saveMedia()
    }
    
    /// Toggle favorite
    func toggleFavorite(_ item: MediaItem) {
        guard let index = mediaItems.firstIndex(where: { $0.id == item.id }) else { return }
        mediaItems[index].isFavorite.toggle()
        try? saveMedia()
    }
    
    /// Set type filter
    func setTypeFilter(_ type: MediaType?) {
        selectedType = type
    }
    
    /// Set tag filter
    func setTagFilter(_ tag: String?) {
        selectedTag = tag
    }
    
    // MARK: - Private Methods
    
    private func createSampleMedia() -> [MediaItem] {
        [
            MediaItem(
                title: "Sunset Photo",
                description: "Beautiful sunset from yesterday",
                imageURL: URL(string: "https://picsum.photos/id/1015/800/600"),
                thumbnailURL: URL(string: "https://picsum.photos/id/1015/200/200"),
                mediaType: .image,
                fileSize: 2_500_000,
                tags: ["nature", "sunset"]
            ),
            MediaItem(
                title: "Project Video",
                description: "Demo video for the project",
                imageURL: URL(string: "https://picsum.photos/id/1018/800/600"),
                thumbnailURL: URL(string: "https://picsum.photos/id/1018/200/200"),
                mediaType: .video,
                fileSize: 15_000_000,
                tags: ["project", "demo"],
                isFavorite: true
            )
        ]
    }
    
    private func saveMedia() throws {
        try storageManager.save(mediaItems, forKey: Constants.StorageKeys.media)
    }
}

