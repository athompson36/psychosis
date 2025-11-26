//
//  SearchView.swift
//  Psychosis
//
//  Created on [Current Date]
//

import SwiftUI

/// Search screen view
struct SearchView: View {
    @State private var viewModel = SearchViewModel()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search Bar
                searchBarSection
                
                // Category Filter
                categoryFilterSection
                
                // Results
                resultsSection
            }
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    // MARK: - Search Bar Section
    
    private var searchBarSection: some View {
        HStack(spacing: AppTheme.Spacing.medium) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(AppTheme.Colors.secondary)
                
                TextField("Search...", text: $viewModel.searchText)
                    .textFieldStyle(.plain)
                    .onSubmit {
                        viewModel.performSearch()
                    }
                    .onChange(of: viewModel.searchText) { _, _ in
                        viewModel.performSearch()
                    }
                
                if !viewModel.searchText.isEmpty {
                    Button(action: {
                        viewModel.clearSearch()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(AppTheme.Colors.secondary)
                    }
                }
            }
            .padding(AppTheme.Spacing.medium)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                    .fill(Color(.systemGray6))
            )
        }
        .padding(AppTheme.Spacing.medium)
    }
    
    // MARK: - Category Filter Section
    
    private var categoryFilterSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppTheme.Spacing.small) {
                ForEach(SearchCategory.allCases, id: \.self) { category in
                    categoryChip(category: category)
                }
            }
            .padding(.horizontal, AppTheme.Spacing.medium)
        }
        .padding(.bottom, AppTheme.Spacing.small)
    }
    
    private func categoryChip(category: SearchCategory) -> some View {
        Button(action: {
            viewModel.filterByCategory(category)
        }) {
            Text(category.rawValue)
                .font(AppTheme.Typography.caption)
                .padding(.horizontal, AppTheme.Spacing.medium)
                .padding(.vertical, AppTheme.Spacing.small)
                .background(
                    RoundedRectangle(cornerRadius: AppTheme.CornerRadius.large)
                        .fill(viewModel.selectedCategory == category ? AppTheme.Colors.primary : Color(.systemGray5))
                )
                .foregroundColor(viewModel.selectedCategory == category ? .white : AppTheme.Colors.foreground)
        }
    }
    
    // MARK: - Results Section
    
    private var resultsSection: some View {
        Group {
            if viewModel.isSearching {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.searchText.isEmpty {
                emptySearchState
            } else if viewModel.results.isEmpty {
                noResultsState
            } else {
                resultsList
            }
        }
    }
    
    private var emptySearchState: some View {
        VStack(spacing: AppTheme.Spacing.large) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(AppTheme.Colors.secondary)
            
            Text("Start Searching")
                .font(AppTheme.Typography.title2)
                .foregroundColor(AppTheme.Colors.foreground)
            
            Text("Enter a search term to find content")
                .font(AppTheme.Typography.body)
                .foregroundColor(AppTheme.Colors.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
    
    private var noResultsState: some View {
        VStack(spacing: AppTheme.Spacing.large) {
            Image(systemName: "tray")
                .font(.system(size: 60))
                .foregroundColor(AppTheme.Colors.secondary)
            
            Text("No Results")
                .font(AppTheme.Typography.title2)
                .foregroundColor(AppTheme.Colors.foreground)
            
            Text("Try a different search term")
                .font(AppTheme.Typography.body)
                .foregroundColor(AppTheme.Colors.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
    
    private var resultsList: some View {
        List {
            ForEach(viewModel.results) { result in
                SearchResultRow(result: result)
            }
        }
        .listStyle(.plain)
    }
}

// MARK: - Search Result Row

struct SearchResultRow: View {
    let result: SearchResult
    
    var body: some View {
        HStack(spacing: AppTheme.Spacing.medium) {
            // Icon
            Image(systemName: result.iconName)
                .font(.title2)
                .foregroundColor(AppTheme.Colors.primary)
                .frame(width: 40, height: 40)
                .background(
                    Circle()
                        .fill(AppTheme.Colors.primary.opacity(0.1))
                )
            
            // Content
            VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
                Text(result.title)
                    .font(AppTheme.Typography.body)
                    .foregroundColor(AppTheme.Colors.foreground)
                
                Text(result.description)
                    .font(AppTheme.Typography.caption)
                    .foregroundColor(AppTheme.Colors.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            // Category Badge
            Text(result.category.rawValue)
                .font(AppTheme.Typography.caption)
                .padding(.horizontal, AppTheme.Spacing.small)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(AppTheme.Colors.primary.opacity(0.2))
                )
                .foregroundColor(AppTheme.Colors.primary)
        }
        .padding(.vertical, AppTheme.Spacing.small)
    }
}

// MARK: - Preview

#Preview {
    SearchView()
}

