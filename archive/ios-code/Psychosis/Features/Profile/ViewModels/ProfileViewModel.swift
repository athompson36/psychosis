//
//  ProfileViewModel.swift
//  Psychosis
//
//  Created on [Current Date]
//

import Foundation
import SwiftUI

/// ViewModel for Profile screen
@Observable
final class ProfileViewModel {
    // MARK: - Properties
    
    var profile: UserProfile?
    var isLoading = false
    var errorMessage: String?
    var isEditing = false
    
    // MARK: - Dependencies
    
    private let storageManager: StorageManager
    
    // MARK: - Initialization
    
    init(storageManager: StorageManager = DefaultStorageManager()) {
        self.storageManager = storageManager
    }
    
    // MARK: - Public Methods
    
    /// Load user profile
    @MainActor
    func loadProfile() async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds
            
            // Try to load from storage
            if let savedProfile: UserProfile = try? storageManager.load(UserProfile.self, forKey: Constants.StorageKeys.userProfile) {
                profile = savedProfile
            } else {
                // Create default profile
                profile = UserProfile(
                    name: "User",
                    email: "user@example.com",
                    bio: "Welcome to Psychosis!"
                )
                try? saveProfile()
            }
            
            isLoading = false
        } catch {
            errorMessage = "Failed to load profile: \(error.localizedDescription)"
            isLoading = false
        }
    }
    
    /// Save profile
    func saveProfile() throws {
        guard let profile = profile else { return }
        try storageManager.save(profile, forKey: Constants.StorageKeys.userProfile)
    }
    
    /// Update profile name
    func updateName(_ name: String) {
        guard var profile = profile else { return }
        profile.name = name
        self.profile = profile
        try? saveProfile()
    }
    
    /// Update profile email
    func updateEmail(_ email: String) {
        guard var profile = profile else { return }
        profile.email = email
        self.profile = profile
        try? saveProfile()
    }
    
    /// Update profile bio
    func updateBio(_ bio: String) {
        guard var profile = profile else { return }
        profile.bio = bio
        self.profile = profile
        try? saveProfile()
    }
    
    /// Toggle edit mode
    func toggleEditMode() {
        isEditing.toggle()
    }
}

