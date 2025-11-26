//
//  FavoritesView.swift
//  Psychosis
//
//  Created on [Current Date]
//

import SwiftUI

/// Favorites screen view
struct FavoritesView: View {
    @State private var viewModel = FavoritesViewModel()
    
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
                            await viewModel.loadFavorites()
                        }
                    }
                } else {
                    favoritesContent
                }
            }
            .navigationTitle("Favorites")
            .navigationBarTitleDisplayMode(.large)
            .task {
                await viewModel.loadFavorites()
            }
            .refreshable {
                await viewModel.loadFavorites()
            }
        }
    }
    
    // MARK: - Favorites Content
    
    private var favoritesContent: some View {
        VStack(spacing: 0) {
            // Category Filter
            if !viewModel.categories.isEmpty {
                categoryFilter
            }
            
            // Favorites List
            if viewModel.filteredFavorites.isEmpty {
                emptyStateView
            } else {
                favoritesList
            }
        }
    }
    
    // MARK: - Category Filter
    
    private var categoryFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppTheme.Spacing.small) {
                categoryChip(title: "All", isSelected: viewModel.selectedCategory == nil) {
                    viewModel.filterByCategory(nil)
                }
                
                ForEach(viewModel.categories, id: \.self) { category in
                    categoryChip(title: category, isSelected: viewModel.selectedCategory == category) {
                        viewModel.filterByCategory(category)
                    }
                }
            }
            .padding(.horizontal, AppTheme.Spacing.medium)
            .padding(.vertical, AppTheme.Spacing.small)
        }
        .background(Color(.systemGray6))
    }
    
    private func categoryChip(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(AppTheme.Typography.caption)
                .padding(.horizontal, AppTheme.Spacing.medium)
                .padding(.vertical, AppTheme.Spacing.small)
                .background(
                    RoundedRectangle(cornerRadius: AppTheme.CornerRadius.large)
                        .fill(isSelected ? AppTheme.Colors.primary : Color(.systemGray5))
                )
                .foregroundColor(isSelected ? .white : AppTheme.Colors.foreground)
        }
    }
    
    // MARK: - Favorites List
    
    private var favoritesList: some View {
        List {
            ForEach(viewModel.filteredFavorites) { favorite in
                FavoriteRow(favorite: favorite) {
                    viewModel.removeFavorite(favorite)
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button(role: .destructive) {
                        viewModel.removeFavorite(favorite)
                    } label: {
                        Label("Remove", systemImage: "heart.slash")
                    }
                }
            }
        }
        .listStyle(.plain)
    }
    
    // MARK: - Empty State
    
    private var emptyStateView: some View {
        VStack(spacing: AppTheme.Spacing.large) {
            Image(systemName: "heart")
                .font(.system(size: 60))
                .foregroundColor(AppTheme.Colors.secondary)
            
            Text(viewModel.selectedCategory == nil ? "No Favorites" : "No Favorites in Category")
                .font(AppTheme.Typography.title2)
                .foregroundColor(AppTheme.Colors.foreground)
            
            Text("Items you favorite will appear here")
                .font(AppTheme.Typography.body)
                .foregroundColor(AppTheme.Colors.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

// MARK: - Favorite Row

struct FavoriteRow: View {
    let favorite: FavoriteItem
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: AppTheme.Spacing.medium) {
            // Icon
            Image(systemName: favorite.iconName)
                .font(.title2)
                .foregroundColor(AppTheme.Colors.primary)
                .frame(width: 40, height: 40)
                .background(
                    Circle()
                        .fill(AppTheme.Colors.primary.opacity(0.1))
                )
            
            // Content
            VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
                Text(favorite.title)
                    .font(AppTheme.Typography.body)
                    .foregroundColor(AppTheme.Colors.foreground)
                
                Text(favorite.description)
                    .font(AppTheme.Typography.caption)
                    .foregroundColor(AppTheme.Colors.secondary)
                    .lineLimit(2)
                
                HStack {
                    Text(favorite.category)
                        .font(.system(size: 11))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(AppTheme.Colors.primary.opacity(0.2))
                        )
                        .foregroundColor(AppTheme.Colors.primary)
                    
                    Spacer()
                    
                    Text(favorite.addedDate, style: .relative)
                        .font(.system(size: 11))
                        .foregroundColor(AppTheme.Colors.secondary)
                }
            }
            
            Spacer()
            
            // Favorite Button
            Button(action: onRemove) {
                Image(systemName: "heart.fill")
                    .foregroundColor(.red)
            }
        }
        .padding(.vertical, AppTheme.Spacing.small)
    }
}

// MARK: - Preview

#Preview {
    FavoritesView()
}

