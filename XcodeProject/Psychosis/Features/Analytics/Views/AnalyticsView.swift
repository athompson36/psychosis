//
//  AnalyticsView.swift
//  Psychosis
//
//  Created on [Current Date]
//

import SwiftUI

/// Analytics screen view
struct AnalyticsView: View {
    @State private var viewModel = AnalyticsViewModel()
    
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
                            await viewModel.loadAnalytics()
                        }
                    }
                } else {
                    analyticsContent
                }
            }
            .navigationTitle("Analytics")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        Task {
                            await viewModel.refreshAnalytics()
                        }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            .task {
                await viewModel.loadAnalytics()
            }
            .refreshable {
                await viewModel.refreshAnalytics()
            }
        }
    }
    
    // MARK: - Analytics Content
    
    private var analyticsContent: some View {
        ScrollView {
            VStack(spacing: AppTheme.Spacing.large) {
                // Overview Cards
                overviewSection
                
                // Task Analytics
                taskAnalyticsSection
                
                // Media Analytics
                mediaAnalyticsSection
                
                // Summary
                summarySection
            }
            .padding(AppTheme.Spacing.medium)
        }
    }
    
    // MARK: - Overview Section
    
    private var overviewSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.medium) {
            Text("Overview")
                .font(AppTheme.Typography.title2)
                .foregroundColor(AppTheme.Colors.foreground)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: AppTheme.Spacing.medium) {
                StatCard(title: "Tasks", value: "\(viewModel.analyticsData.totalTasks)", icon: "checklist", color: .blue)
                StatCard(title: "Notes", value: "\(viewModel.analyticsData.totalNotes)", icon: "note.text", color: .yellow)
                StatCard(title: "Events", value: "\(viewModel.analyticsData.totalEvents)", icon: "calendar", color: .green)
                StatCard(title: "Media", value: "\(viewModel.analyticsData.totalMedia)", icon: "photo.on.rectangle", color: .purple)
            }
        }
    }
    
    // MARK: - Task Analytics
    
    private var taskAnalyticsSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.medium) {
            Text("Task Analytics")
                .font(AppTheme.Typography.title2)
                .foregroundColor(AppTheme.Colors.foreground)
            
            VStack(spacing: AppTheme.Spacing.medium) {
                // Completion Rate
                HStack {
                    VStack(alignment: .leading) {
                        Text("Completion Rate")
                            .font(AppTheme.Typography.body)
                            .foregroundColor(AppTheme.Colors.foreground)
                        Text("\(Int(viewModel.taskCompletionRate))%")
                            .font(AppTheme.Typography.title)
                            .foregroundColor(AppTheme.Colors.primary)
                    }
                    
                    Spacer()
                    
                    // Progress Circle
                    ZStack {
                        Circle()
                            .stroke(Color(.systemGray5), lineWidth: 8)
                        
                        Circle()
                            .trim(from: 0, to: viewModel.taskCompletionRate / 100)
                            .stroke(Color.green, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                            .rotationEffect(.degrees(-90))
                    }
                    .frame(width: 60, height: 60)
                }
                
                // Task Breakdown
                HStack(spacing: AppTheme.Spacing.large) {
                    TaskStat(label: "Completed", value: "\(viewModel.analyticsData.completedTasks)", color: .green)
                    TaskStat(label: "Active", value: "\(viewModel.analyticsData.activeTasks)", color: .orange)
                }
            }
            .padding(AppTheme.Spacing.medium)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.large)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
            )
        }
    }
    
    // MARK: - Media Analytics
    
    private var mediaAnalyticsSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.medium) {
            Text("Media Analytics")
                .font(AppTheme.Typography.title2)
                .foregroundColor(AppTheme.Colors.foreground)
            
            HStack(spacing: AppTheme.Spacing.large) {
                MediaStat(label: "Total", value: "\(viewModel.analyticsData.totalMedia)", color: .blue)
                MediaStat(label: "Favorites", value: "\(viewModel.analyticsData.favoriteMedia)", color: .red)
            }
            .padding(AppTheme.Spacing.medium)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.large)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
            )
        }
    }
    
    // MARK: - Summary Section
    
    private var summarySection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.medium) {
            Text("Summary")
                .font(AppTheme.Typography.title2)
                .foregroundColor(AppTheme.Colors.foreground)
            
            VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
                SummaryRow(label: "Upcoming Events", value: "\(viewModel.analyticsData.upcomingEvents)")
                SummaryRow(label: "Last Updated", value: viewModel.analyticsData.lastUpdated.formatted(date: .abbreviated, time: .shortened))
            }
            .padding(AppTheme.Spacing.medium)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.large)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
            )
        }
    }
}

// MARK: - Stat Card

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: AppTheme.Spacing.small) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(AppTheme.Typography.title)
                .foregroundColor(AppTheme.Colors.foreground)
            
            Text(title)
                .font(AppTheme.Typography.caption)
                .foregroundColor(AppTheme.Colors.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(AppTheme.Spacing.medium)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 1)
        )
    }
}

// MARK: - Task Stat

struct TaskStat: View {
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack {
            Text(value)
                .font(AppTheme.Typography.title)
                .foregroundColor(color)
            
            Text(label)
                .font(AppTheme.Typography.caption)
                .foregroundColor(AppTheme.Colors.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Media Stat

struct MediaStat: View {
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack {
            Text(value)
                .font(AppTheme.Typography.title)
                .foregroundColor(color)
            
            Text(label)
                .font(AppTheme.Typography.caption)
                .foregroundColor(AppTheme.Colors.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Summary Row

struct SummaryRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(AppTheme.Typography.body)
                .foregroundColor(AppTheme.Colors.foreground)
            
            Spacer()
            
            Text(value)
                .font(AppTheme.Typography.body)
                .foregroundColor(AppTheme.Colors.secondary)
        }
    }
}

// MARK: - Preview

#Preview {
    AnalyticsView()
}

