//
//  DetailView.swift
//  Psychosis
//
//  Created on [Current Date]
//

import SwiftUI

/// Detail screen view
struct DetailView: View {
    let itemId: UUID
    @State private var viewModel: DetailViewModel
    
    init(itemId: UUID) {
        self.itemId = itemId
        self._viewModel = State(initialValue: DetailViewModel())
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.large) {
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding(.top, AppTheme.Spacing.extraLarge)
                } else if let errorMessage = viewModel.errorMessage {
                    ErrorView(message: errorMessage) {
                        Task {
                            await viewModel.loadItem(id: itemId)
                        }
                    }
                } else if let item = viewModel.item {
                    contentView(for: item)
                }
            }
            .padding(AppTheme.Spacing.medium)
        }
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.large)
        .task {
            await viewModel.loadItem(id: itemId)
        }
    }
    
    // MARK: - Content View
    
    private func contentView(for item: DetailItem) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.large) {
            // Header
            headerSection(for: item)
            
            Divider()
            
            // Description
            descriptionSection(for: item)
            
            Divider()
            
            // Content
            contentSection(for: item)
            
            Divider()
            
            // Metadata
            metadataSection(for: item)
        }
    }
    
    // MARK: - Header Section
    
    private func headerSection(for item: DetailItem) -> some View {
        HStack(spacing: AppTheme.Spacing.medium) {
            Image(systemName: item.iconName)
                .font(.system(size: 50))
                .foregroundColor(AppTheme.Colors.primary)
                .frame(width: 60, height: 60)
                .background(
                    Circle()
                        .fill(AppTheme.Colors.primary.opacity(0.1))
                )
            
            VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
                Text(item.title)
                    .font(AppTheme.Typography.title)
                    .foregroundColor(AppTheme.Colors.foreground)
                
                Text(item.description)
                    .font(AppTheme.Typography.body)
                    .foregroundColor(AppTheme.Colors.secondary)
            }
            
            Spacer()
        }
    }
    
    // MARK: - Description Section
    
    private func descriptionSection(for item: DetailItem) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
            Text("Description")
                .font(AppTheme.Typography.title3)
                .foregroundColor(AppTheme.Colors.foreground)
            
            Text(item.description)
                .font(AppTheme.Typography.body)
                .foregroundColor(AppTheme.Colors.secondary)
        }
    }
    
    // MARK: - Content Section
    
    private func contentSection(for item: DetailItem) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
            Text("Content")
                .font(AppTheme.Typography.title3)
                .foregroundColor(AppTheme.Colors.foreground)
            
            Text(item.content)
                .font(AppTheme.Typography.body)
                .foregroundColor(AppTheme.Colors.foreground)
                .lineSpacing(4)
        }
    }
    
    // MARK: - Metadata Section
    
    private func metadataSection(for item: DetailItem) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
            Text("Information")
                .font(AppTheme.Typography.title3)
                .foregroundColor(AppTheme.Colors.foreground)
            
            HStack {
                Text("Created:")
                    .font(AppTheme.Typography.caption)
                    .foregroundColor(AppTheme.Colors.secondary)
                
                Spacer()
                
                Text(item.timestamp, style: .date)
                    .font(AppTheme.Typography.caption)
                    .foregroundColor(AppTheme.Colors.secondary)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        DetailView(itemId: UUID())
    }
}

