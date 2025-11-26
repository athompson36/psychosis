//
//  ProfileView.swift
//  Psychosis
//
//  Created on [Current Date]
//

import SwiftUI

/// Profile screen view
struct ProfileView: View {
    @State private var viewModel = ProfileViewModel()
    @State private var editedName = ""
    @State private var editedEmail = ""
    @State private var editedBio = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.Colors.background
                    .ignoresSafeArea()
                
                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                } else if let errorMessage = viewModel.errorMessage {
                    ErrorView(message: errorMessage) {
                        Task {
                            await viewModel.loadProfile()
                        }
                    }
                } else if let profile = viewModel.profile {
                    profileContentView(profile: profile)
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(viewModel.isEditing ? "Done" : "Edit") {
                        if viewModel.isEditing {
                            saveChanges()
                        }
                        viewModel.toggleEditMode()
                    }
                }
            }
            .task {
                await viewModel.loadProfile()
            }
        }
    }
    
    // MARK: - Profile Content
    
    private func profileContentView(profile: UserProfile) -> some View {
        ScrollView {
            VStack(spacing: AppTheme.Spacing.large) {
                // Avatar Section
                avatarSection(profile: profile)
                
                // Profile Info
                profileInfoSection(profile: profile)
                
                // Stats Section
                statsSection(profile: profile)
            }
            .padding(AppTheme.Spacing.medium)
        }
    }
    
    // MARK: - Avatar Section
    
    private func avatarSection(profile: UserProfile) -> some View {
        VStack(spacing: AppTheme.Spacing.medium) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [AppTheme.Colors.primary, AppTheme.Colors.primary.opacity(0.6)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                
                Text(profile.name.prefix(1).uppercased())
                    .font(.system(size: 50, weight: .bold))
                    .foregroundColor(.white)
            }
            
            if !viewModel.isEditing {
                Text(profile.name)
                    .font(AppTheme.Typography.title)
                    .foregroundColor(AppTheme.Colors.foreground)
            }
        }
    }
    
    // MARK: - Profile Info Section
    
    private func profileInfoSection(profile: UserProfile) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.medium) {
            Text("Information")
                .font(AppTheme.Typography.title2)
                .foregroundColor(AppTheme.Colors.foreground)
            
            VStack(spacing: AppTheme.Spacing.medium) {
                if viewModel.isEditing {
                    VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
                        Text("Name")
                            .font(AppTheme.Typography.caption)
                            .foregroundColor(AppTheme.Colors.secondary)
                        TextField("Name", text: $editedName)
                            .textFieldStyle(.roundedBorder)
                    }
                    
                    VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
                        Text("Email")
                            .font(AppTheme.Typography.caption)
                            .foregroundColor(AppTheme.Colors.secondary)
                        TextField("Email", text: $editedEmail)
                            .textFieldStyle(.roundedBorder)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                    }
                    
                    VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
                        Text("Bio")
                            .font(AppTheme.Typography.caption)
                            .foregroundColor(AppTheme.Colors.secondary)
                        TextField("Bio", text: $editedBio, axis: .vertical)
                            .textFieldStyle(.roundedBorder)
                            .lineLimit(3...6)
                    }
                } else {
                    profileInfoRow(icon: "person.fill", title: "Name", value: profile.name)
                    profileInfoRow(icon: "envelope.fill", title: "Email", value: profile.email)
                    profileInfoRow(icon: "text.alignleft", title: "Bio", value: profile.bio.isEmpty ? "No bio" : profile.bio)
                }
            }
            .padding(AppTheme.Spacing.medium)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.large)
                    .fill(Color(.systemGray6))
            )
        }
    }
    
    private func profileInfoRow(icon: String, title: String, value: String) -> some View {
        HStack(spacing: AppTheme.Spacing.medium) {
            Image(systemName: icon)
                .foregroundColor(AppTheme.Colors.primary)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(AppTheme.Typography.caption)
                    .foregroundColor(AppTheme.Colors.secondary)
                Text(value)
                    .font(AppTheme.Typography.body)
                    .foregroundColor(AppTheme.Colors.foreground)
            }
            
            Spacer()
        }
    }
    
    // MARK: - Stats Section
    
    private func statsSection(profile: UserProfile) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.medium) {
            Text("Statistics")
                .font(AppTheme.Typography.title2)
                .foregroundColor(AppTheme.Colors.foreground)
            
            HStack(spacing: AppTheme.Spacing.large) {
                statCard(title: "Member Since", value: formatDate(profile.joinDate))
                statCard(title: "Theme", value: profile.preferences.theme.rawValue)
            }
        }
    }
    
    private func statCard(title: String, value: String) -> some View {
        VStack(spacing: AppTheme.Spacing.small) {
            Text(value)
                .font(AppTheme.Typography.title3)
                .foregroundColor(AppTheme.Colors.primary)
            
            Text(title)
                .font(AppTheme.Typography.caption)
                .foregroundColor(AppTheme.Colors.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(AppTheme.Spacing.medium)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                .fill(Color(.systemGray6))
        )
    }
    
    // MARK: - Helper Methods
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    private func saveChanges() {
        if !editedName.isEmpty {
            viewModel.updateName(editedName)
        }
        if !editedEmail.isEmpty {
            viewModel.updateEmail(editedEmail)
        }
        if !editedBio.isEmpty {
            viewModel.updateBio(editedBio)
        }
    }
}

// MARK: - Preview

#Preview {
    ProfileView()
}

