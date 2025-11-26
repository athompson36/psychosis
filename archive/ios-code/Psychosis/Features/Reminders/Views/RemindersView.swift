//
//  RemindersView.swift
//  Psychosis
//
//  Created on [Current Date]
//

import SwiftUI

/// Reminders screen view
struct RemindersView: View {
    @State private var viewModel = RemindersViewModel()
    
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
                            await viewModel.loadReminders()
                        }
                    }
                } else {
                    remindersContent
                }
            }
            .navigationTitle("Reminders")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        viewModel.showingAddReminder = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu {
                        ForEach(ReminderFilter.allCases, id: \.self) { filter in
                            Button(filter.rawValue) {
                                viewModel.setFilter(filter)
                            }
                        }
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                }
            }
            .sheet(isPresented: $viewModel.showingAddReminder) {
                AddReminderView(viewModel: viewModel)
            }
            .sheet(item: $viewModel.editingReminder) { reminder in
                EditReminderView(reminder: reminder, viewModel: viewModel)
            }
            .task {
                await viewModel.loadReminders()
            }
            .refreshable {
                await viewModel.loadReminders()
            }
        }
    }
    
    // MARK: - Reminders Content
    
    private var remindersContent: some View {
        VStack(spacing: 0) {
            // Stats Bar
            statsBar
            
            // Search Bar
            searchBar
            
            // Category Filter
            if !viewModel.categories.isEmpty {
                categoryFilter
            }
            
            // Reminders List
            if viewModel.filteredReminders.isEmpty {
                emptyStateView
            } else {
                remindersList
            }
        }
    }
    
    // MARK: - Stats Bar
    
    private var statsBar: some View {
        HStack(spacing: AppTheme.Spacing.large) {
            ReminderStat(title: "Overdue", value: "\(viewModel.overdueCount)", color: .red)
            ReminderStat(title: "Due Today", value: "\(viewModel.dueTodayCount)", color: .orange)
            ReminderStat(title: "Total", value: "\(viewModel.reminders.count)", color: .blue)
        }
        .padding(AppTheme.Spacing.medium)
        .background(Color(.systemGray6))
    }
    
    // MARK: - Search Bar
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(AppTheme.Colors.secondary)
            
            TextField("Search reminders...", text: $viewModel.searchText)
                .textFieldStyle(.plain)
            
            if !viewModel.searchText.isEmpty {
                Button {
                    viewModel.searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(AppTheme.Colors.secondary)
                }
            }
        }
        .padding(AppTheme.Spacing.medium)
        .background(Color(.systemGray6))
    }
    
    // MARK: - Category Filter
    
    private var categoryFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppTheme.Spacing.small) {
                categoryChip(title: "All", isSelected: viewModel.selectedCategory == nil) {
                    viewModel.setCategoryFilter(nil)
                }
                
                ForEach(viewModel.categories, id: \.self) { category in
                    categoryChip(title: category, isSelected: viewModel.selectedCategory == category) {
                        viewModel.setCategoryFilter(category)
                    }
                }
            }
            .padding(.horizontal, AppTheme.Spacing.medium)
            .padding(.vertical, AppTheme.Spacing.small)
        }
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
    
    // MARK: - Reminders List
    
    private var remindersList: some View {
        List {
            ForEach(viewModel.filteredReminders) { reminder in
                ReminderRow(reminder: reminder) {
                    viewModel.toggleCompletion(reminder)
                } onEdit: {
                    viewModel.editingReminder = reminder
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button(role: .destructive) {
                        viewModel.deleteReminder(reminder)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                    
                    Button {
                        viewModel.editingReminder = reminder
                    } label: {
                        Label("Edit", systemImage: "pencil")
                    }
                }
            }
        }
        .listStyle(.plain)
    }
    
    // MARK: - Empty State
    
    private var emptyStateView: some View {
        VStack(spacing: AppTheme.Spacing.large) {
            Image(systemName: "bell.slash")
                .font(.system(size: 60))
                .foregroundColor(AppTheme.Colors.secondary)
            
            Text("No Reminders")
                .font(AppTheme.Typography.title2)
                .foregroundColor(AppTheme.Colors.foreground)
            
            Text("Tap + to add a reminder")
                .font(AppTheme.Typography.body)
                .foregroundColor(AppTheme.Colors.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

// MARK: - Reminder Stat

struct ReminderStat: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(AppTheme.Typography.title3)
                .foregroundColor(color)
            
            Text(title)
                .font(AppTheme.Typography.caption)
                .foregroundColor(AppTheme.Colors.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Reminder Row

struct ReminderRow: View {
    let reminder: Reminder
    let onToggle: () -> Void
    let onEdit: () -> Void
    
    var body: some View {
        Button(action: onEdit) {
            HStack(spacing: AppTheme.Spacing.medium) {
                // Checkbox
                Button(action: onToggle) {
                    Image(systemName: reminder.isCompleted ? "checkmark.circle.fill" : "circle")
                        .font(.title2)
                        .foregroundColor(reminder.isCompleted ? .green : AppTheme.Colors.secondary)
                }
                .buttonStyle(.plain)
                
                // Content
                VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
                    Text(reminder.title)
                        .font(AppTheme.Typography.body)
                        .foregroundColor(reminder.isCompleted ? AppTheme.Colors.secondary : AppTheme.Colors.foreground)
                        .strikethrough(reminder.isCompleted)
                    
                    if !reminder.description.isEmpty {
                        Text(reminder.description)
                            .font(AppTheme.Typography.caption)
                            .foregroundColor(AppTheme.Colors.secondary)
                            .lineLimit(2)
                    }
                    
                    HStack {
                        // Priority Badge
                        HStack(spacing: 4) {
                            Image(systemName: reminder.priority.iconName)
                                .font(.system(size: 10))
                            Text(reminder.priority.rawValue)
                                .font(.system(size: 10))
                        }
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(colorForPriority(reminder.priority).opacity(0.2))
                        )
                        .foregroundColor(colorForPriority(reminder.priority))
                        
                        // Category
                        Text(reminder.category)
                            .font(.system(size: 10))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(
                                Capsule()
                                    .fill(AppTheme.Colors.secondary.opacity(0.2))
                            )
                            .foregroundColor(AppTheme.Colors.secondary)
                        
                        Spacer()
                        
                        // Due Date
                        Text(reminder.dueDate, style: .relative)
                            .font(.system(size: 10))
                            .foregroundColor(isOverdue(reminder) ? .red : AppTheme.Colors.secondary)
                    }
                }
            }
            .padding(.vertical, AppTheme.Spacing.small)
            .opacity(reminder.isCompleted ? 0.6 : 1.0)
        }
        .buttonStyle(.plain)
    }
    
    private func colorForPriority(_ priority: ReminderPriority) -> Color {
        switch priority {
        case .low: return .blue
        case .normal: return .orange
        case .high: return .red
        }
    }
    
    private func isOverdue(_ reminder: Reminder) -> Bool {
        reminder.dueDate < Date() && !reminder.isCompleted
    }
}

// MARK: - Add Reminder View

struct AddReminderView: View {
    @Environment(\.dismiss) var dismiss
    @Bindable var viewModel: RemindersViewModel
    
    @State private var title = ""
    @State private var description = ""
    @State private var dueDate = Date().addingTimeInterval(3600)
    @State private var priority: ReminderPriority = .normal
    @State private var category = "General"
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Reminder Details") {
                    TextField("Title", text: $title)
                    TextField("Description", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section("Due Date") {
                    DatePicker("Due Date", selection: $dueDate, displayedComponents: [.date, .hourAndMinute])
                }
                
                Section("Options") {
                    Picker("Priority", selection: $priority) {
                        ForEach(ReminderPriority.allCases, id: \.self) { priority in
                            Text(priority.rawValue).tag(priority)
                        }
                    }
                    
                    TextField("Category", text: $category)
                }
            }
            .navigationTitle("New Reminder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let newReminder = Reminder(
                            title: title,
                            description: description,
                            dueDate: dueDate,
                            priority: priority,
                            category: category
                        )
                        viewModel.addReminder(newReminder)
                        dismiss()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
}

// MARK: - Edit Reminder View

struct EditReminderView: View {
    @Environment(\.dismiss) var dismiss
    let reminder: Reminder
    @Bindable var viewModel: RemindersViewModel
    
    @State private var title: String
    @State private var description: String
    @State private var dueDate: Date
    @State private var priority: ReminderPriority
    @State private var category: String
    
    init(reminder: Reminder, viewModel: RemindersViewModel) {
        self.reminder = reminder
        self.viewModel = viewModel
        _title = State(initialValue: reminder.title)
        _description = State(initialValue: reminder.description)
        _dueDate = State(initialValue: reminder.dueDate)
        _priority = State(initialValue: reminder.priority)
        _category = State(initialValue: reminder.category)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Reminder Details") {
                    TextField("Title", text: $title)
                    TextField("Description", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section("Due Date") {
                    DatePicker("Due Date", selection: $dueDate, displayedComponents: [.date, .hourAndMinute])
                }
                
                Section("Options") {
                    Picker("Priority", selection: $priority) {
                        ForEach(ReminderPriority.allCases, id: \.self) { priority in
                            Text(priority.rawValue).tag(priority)
                        }
                    }
                    
                    TextField("Category", text: $category)
                }
            }
            .navigationTitle("Edit Reminder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        var updatedReminder = reminder
                        updatedReminder.title = title
                        updatedReminder.description = description
                        updatedReminder.dueDate = dueDate
                        updatedReminder.priority = priority
                        updatedReminder.category = category
                        viewModel.updateReminder(updatedReminder)
                        dismiss()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    RemindersView()
}

