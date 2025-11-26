//
//  NotesViewModel.swift
//  Psychosis
//
//  Created on [Current Date]
//

import Foundation

/// ViewModel for Notes screen
@Observable
final class NotesViewModel {
    // MARK: - Properties
    
    var notes: [Note] = []
    var isLoading = false
    var errorMessage: String?
    var searchText = ""
    var selectedTag: String? = nil
    var showingAddNote = false
    var editingNote: Note? = nil
    var sortOption: NoteSortOption = .updatedDate
    
    // MARK: - Dependencies
    
    private let storageManager: StorageManager
    
    // MARK: - Initialization
    
    init(storageManager: StorageManager = DefaultStorageManager()) {
        self.storageManager = storageManager
    }
    
    // MARK: - Computed Properties
    
    var allTags: [String] {
        Array(Set(notes.flatMap { $0.tags })).sorted()
    }
    
    var filteredNotes: [Note] {
        var result = notes
        
        // Apply tag filter
        if let tag = selectedTag {
            result = result.filter { $0.tags.contains(tag) }
        }
        
        // Apply search
        if !searchText.isEmpty {
            result = result.filter { note in
                note.title.localizedCaseInsensitiveContains(searchText) ||
                note.content.localizedCaseInsensitiveContains(searchText) ||
                note.tags.contains { $0.localizedCaseInsensitiveContains(searchText) }
            }
        }
        
        // Sort: pinned first, then by sort option
        result = result.sorted { note1, note2 in
            if note1.isPinned != note2.isPinned {
                return note1.isPinned
            }
            
            switch sortOption {
            case .updatedDate:
                return note1.updatedAt > note2.updatedAt
            case .createdDate:
                return note1.createdAt > note2.createdAt
            case .alphabetical:
                return note1.title < note2.title
            }
        }
        
        return result
    }
    
    var pinnedNotes: [Note] {
        filteredNotes.filter { $0.isPinned }
    }
    
    var unpinnedNotes: [Note] {
        filteredNotes.filter { !$0.isPinned }
    }
    
    // MARK: - Public Methods
    
    /// Load notes
    @MainActor
    func loadNotes() async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds
            
            if let saved: [Note] = try? storageManager.load([Note].self, forKey: Constants.StorageKeys.notes) {
                notes = saved
            } else {
                notes = createSampleNotes()
                try? saveNotes()
            }
            
            isLoading = false
        } catch {
            errorMessage = "Failed to load notes: \(error.localizedDescription)"
            isLoading = false
        }
    }
    
    /// Add note
    func addNote(_ note: Note) {
        notes.append(note)
        try? saveNotes()
    }
    
    /// Update note
    func updateNote(_ note: Note) {
        guard let index = notes.firstIndex(where: { $0.id == note.id }) else { return }
        var updatedNote = note
        updatedNote.updatedAt = Date()
        notes[index] = updatedNote
        try? saveNotes()
    }
    
    /// Delete note
    func deleteNote(_ note: Note) {
        notes.removeAll { $0.id == note.id }
        try? saveNotes()
    }
    
    /// Toggle pin
    func togglePin(_ note: Note) {
        guard let index = notes.firstIndex(where: { $0.id == note.id }) else { return }
        notes[index].isPinned.toggle()
        try? saveNotes()
    }
    
    /// Set tag filter
    func setTagFilter(_ tag: String?) {
        selectedTag = tag
    }
    
    /// Set sort option
    func setSortOption(_ option: NoteSortOption) {
        sortOption = option
    }
    
    // MARK: - Private Methods
    
    private func createSampleNotes() -> [Note] {
        [
            Note(
                title: "Welcome Note",
                content: "This is your first note in Psychosis!\n\nYou can create, edit, and organize your notes here.",
                isPinned: true,
                tags: ["welcome"],
                color: .yellow
            ),
            Note(
                title: "Project Ideas",
                content: "• Feature ideas\n• Improvements\n• Bug fixes",
                tags: ["ideas", "project"],
                color: .blue
            )
        ]
    }
    
    private func saveNotes() throws {
        try storageManager.save(notes, forKey: Constants.StorageKeys.notes)
    }
}

enum NoteSortOption: String, CaseIterable {
    case updatedDate = "Recently Updated"
    case createdDate = "Recently Created"
    case alphabetical = "Alphabetical"
}

