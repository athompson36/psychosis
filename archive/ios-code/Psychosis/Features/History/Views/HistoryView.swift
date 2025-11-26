//
//  HistoryView.swift
//  Psychosis
//
//  Created on [Current Date]
//

import SwiftUI

/// History screen view
struct HistoryView: View {
    @State private var viewModel = HistoryViewModel()
    
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
                            await viewModel.loadHistory()
                        }
                    }
                } else {
                    historyContent
                }
            }
            .navigationTitle("History")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !viewModel.historyItems.isEmpty {
                        Button("Clear") {
                            viewModel.clearHistory()
                        }
                    }
                }
            }
            .task {
                await viewModel.loadHistory()
            }
            .refreshable {
                await viewModel.loadHistory()
            }
        }
    }
    
    // MARK: - History Content
    
    private var historyContent: some View {
        Group {
            if viewModel.historyItems.isEmpty {
                emptyStateView
            } else {
                historyList
            }
        }
    }
    
    // MARK: - History List
    
    private var historyList: some View {
        List {
            ForEach(viewModel.sortedGroups, id: \.self) { group in
                Section(header: Text(group)) {
                    ForEach(viewModel.groupedHistory[group] ?? []) { item in
                        HistoryRow(item: item)
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    viewModel.deleteHistoryItem(item)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }
    
    // MARK: - Empty State
    
    private var emptyStateView: some View {
        VStack(spacing: AppTheme.Spacing.large) {
            Image(systemName: "clock")
                .font(.system(size: 60))
                .foregroundColor(AppTheme.Colors.secondary)
            
            Text("No History")
                .font(AppTheme.Typography.title2)
                .foregroundColor(AppTheme.Colors.foreground)
            
            Text("Your activity history will appear here")
                .font(AppTheme.Typography.body)
                .foregroundColor(AppTheme.Colors.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

// MARK: - History Row

struct HistoryRow: View {
    let item: HistoryItem
    
    var body: some View {
        HStack(spacing: AppTheme.Spacing.medium) {
            // Icon
            Image(systemName: item.iconName)
                .font(.title3)
                .foregroundColor(AppTheme.Colors.primary)
                .frame(width: 36, height: 36)
                .background(
                    Circle()
                        .fill(AppTheme.Colors.primary.opacity(0.1))
                )
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(AppTheme.Typography.body)
                    .foregroundColor(AppTheme.Colors.foreground)
                
                Text(item.description)
                    .font(AppTheme.Typography.caption)
                    .foregroundColor(AppTheme.Colors.secondary)
            }
            
            Spacer()
            
            // Time
            VStack(alignment: .trailing, spacing: 4) {
                Text(item.timestamp, style: .time)
                    .font(AppTheme.Typography.caption)
                    .foregroundColor(AppTheme.Colors.secondary)
                
                Text(item.action)
                    .font(.system(size: 10))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(
                        Capsule()
                            .fill(AppTheme.Colors.secondary.opacity(0.2))
                    )
                    .foregroundColor(AppTheme.Colors.secondary)
            }
        }
        .padding(.vertical, AppTheme.Spacing.small)
    }
}

// MARK: - Preview

#Preview {
    HistoryView()
}

