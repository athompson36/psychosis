//
//  NotificationsView.swift
//  Psychosis
//
//  Created on [Current Date]
//

import SwiftUI

/// Notifications screen view
struct NotificationsView: View {
    @State private var viewModel = NotificationsViewModel()
    
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
                            await viewModel.loadNotifications()
                        }
                    }
                } else {
                    notificationsList
                }
            }
            .navigationTitle("Notifications")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !viewModel.notifications.isEmpty {
                        Menu {
                            Button("Mark All Read") {
                                viewModel.markAllAsRead()
                            }
                            Button("Clear All", role: .destructive) {
                                viewModel.clearAll()
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                        }
                    }
                }
            }
            .task {
                await viewModel.loadNotifications()
            }
            .refreshable {
                await viewModel.loadNotifications()
            }
        }
    }
    
    // MARK: - Notifications List
    
    private var notificationsList: some View {
        Group {
            if viewModel.notifications.isEmpty {
                emptyStateView
            } else {
                List {
                    ForEach(viewModel.notifications) { notification in
                        NotificationRow(notification: notification) {
                            viewModel.markAsRead(notification)
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                viewModel.deleteNotification(notification)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
                .listStyle(.plain)
            }
        }
    }
    
    // MARK: - Empty State
    
    private var emptyStateView: some View {
        VStack(spacing: AppTheme.Spacing.large) {
            Image(systemName: "bell.slash")
                .font(.system(size: 60))
                .foregroundColor(AppTheme.Colors.secondary)
            
            Text("No Notifications")
                .font(AppTheme.Typography.title2)
                .foregroundColor(AppTheme.Colors.foreground)
            
            Text("You're all caught up!")
                .font(AppTheme.Typography.body)
                .foregroundColor(AppTheme.Colors.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

// MARK: - Notification Row

struct NotificationRow: View {
    let notification: NotificationItem
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: AppTheme.Spacing.medium) {
                // Icon
                Image(systemName: notification.type.iconName)
                    .font(.title2)
                    .foregroundColor(colorForType(notification.type))
                    .frame(width: 40, height: 40)
                    .background(
                        Circle()
                            .fill(colorForType(notification.type).opacity(0.1))
                    )
                
                // Content
                VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
                    HStack {
                        Text(notification.title)
                            .font(AppTheme.Typography.body)
                            .foregroundColor(AppTheme.Colors.foreground)
                            .fontWeight(notification.isRead ? .regular : .semibold)
                        
                        if !notification.isRead {
                            Circle()
                                .fill(AppTheme.Colors.primary)
                                .frame(width: 8, height: 8)
                        }
                    }
                    
                    Text(notification.message)
                        .font(AppTheme.Typography.caption)
                        .foregroundColor(AppTheme.Colors.secondary)
                        .lineLimit(2)
                    
                    Text(notification.timestamp, style: .relative)
                        .font(.system(size: 11))
                        .foregroundColor(AppTheme.Colors.secondary)
                }
                
                Spacer()
            }
            .padding(.vertical, AppTheme.Spacing.small)
            .opacity(notification.isRead ? 0.6 : 1.0)
        }
        .buttonStyle(.plain)
    }
    
    private func colorForType(_ type: NotificationType) -> Color {
        switch type {
        case .info: return .blue
        case .success: return .green
        case .warning: return .orange
        case .error: return .red
        }
    }
}

// MARK: - Preview

#Preview {
    NotificationsView()
}

