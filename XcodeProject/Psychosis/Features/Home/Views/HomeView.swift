//
//  HomeView.swift
//  Psychosis
//
//  Created on [Current Date]
//

import SwiftUI

/// Main home screen view
struct HomeView: View {
    @State private var viewModel = HomeViewModel()
    
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
                            await viewModel.loadData()
                        }
                    }
                } else {
                    contentView
                }
            }
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.large)
            .task {
                await viewModel.loadData()
            }
            .refreshable {
                await viewModel.refresh()
            }
            .navigationDestination(for: UUID.self) { id in
                DetailView(itemId: id)
            }
        }
    }
    
    // MARK: - Content View
    
    private var contentView: some View {
        ScrollView {
            VStack(spacing: AppTheme.Spacing.medium) {
                // Header Section
                headerSection
                
                // Items List
                itemsSection
            }
            .padding(AppTheme.Spacing.medium)
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(spacing: AppTheme.Spacing.small) {
            Image(systemName: "house.fill")
                .font(.system(size: 60))
                .foregroundColor(AppTheme.Colors.primary)
            
            Text("Welcome to \(Constants.appName)")
                .font(AppTheme.Typography.title)
                .foregroundColor(AppTheme.Colors.foreground)
            
            Text("Version \(Constants.appVersion)")
                .font(AppTheme.Typography.caption)
                .foregroundColor(AppTheme.Colors.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(AppTheme.Spacing.large)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.large)
                .fill(Color(.systemGray6))
        )
    }
    
    // MARK: - Items Section
    
    private var itemsSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.medium) {
            Text("Quick Actions")
                .font(AppTheme.Typography.title2)
                .foregroundColor(AppTheme.Colors.foreground)
            
            if viewModel.items.isEmpty {
                emptyStateView
            } else {
                ForEach(viewModel.items) { item in
                    NavigationLink(value: item.id) {
                        HomeItemRow(item: item)
                    }
                }
            }
        }
    }
    
    // MARK: - Empty State
    
    private var emptyStateView: some View {
        VStack(spacing: AppTheme.Spacing.medium) {
            Image(systemName: "tray")
                .font(.system(size: 40))
                .foregroundColor(AppTheme.Colors.secondary)
            
            Text("No items yet")
                .font(AppTheme.Typography.body)
                .foregroundColor(AppTheme.Colors.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(AppTheme.Spacing.extraLarge)
    }
}

// MARK: - Home Item Row

struct HomeItemRow: View {
    let item: HomeItem
    
    var body: some View {
        HStack(spacing: AppTheme.Spacing.medium) {
            // Icon
            Image(systemName: item.iconName)
                .font(.title2)
                .foregroundColor(AppTheme.Colors.primary)
                .frame(width: 40, height: 40)
                .background(
                    Circle()
                        .fill(AppTheme.Colors.primary.opacity(0.1))
                )
            
            // Content
            VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
                Text(item.title)
                    .font(AppTheme.Typography.body)
                    .foregroundColor(AppTheme.Colors.foreground)
                
                Text(item.description)
                    .font(AppTheme.Typography.caption)
                    .foregroundColor(AppTheme.Colors.secondary)
            }
            
            Spacer()
        }
        .padding(AppTheme.Spacing.medium)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        )
    }
}

// MARK: - Error View

struct ErrorView: View {
    let message: String
    let retryAction: () -> Void
    
    var body: some View {
        VStack(spacing: AppTheme.Spacing.medium) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.orange)
            
            Text("Error")
                .font(AppTheme.Typography.title2)
                .foregroundColor(AppTheme.Colors.foreground)
            
            Text(message)
                .font(AppTheme.Typography.body)
                .foregroundColor(AppTheme.Colors.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button("Retry", action: retryAction)
                .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

// MARK: - Preview

#Preview {
    HomeView()
}

