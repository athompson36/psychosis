//
//  TasksView.swift
//  Psychosis
//
//  Created on [Current Date]
//

import SwiftUI

/// Tasks screen view
struct TasksView: View {
    @State private var viewModel = TasksViewModel()
    
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
                            await viewModel.loadTasks()
                        }
                    }
                } else {
                    tasksContent
                }
            }
            .navigationTitle("Tasks")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        viewModel.showingAddTask = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu {
                        ForEach(TaskFilter.allCases, id: \.self) { filter in
                            Button(filter.rawValue) {
                                viewModel.setFilter(filter)
                            }
                        }
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                }
            }
            .sheet(isPresented: $viewModel.showingAddTask) {
                AddTaskView(viewModel: viewModel)
            }
            .sheet(item: $viewModel.editingTask) { task in
                EditTaskView(task: task, viewModel: viewModel)
            }
            .task {
                await viewModel.loadTasks()
            }
            .refreshable {
                await viewModel.loadTasks()
            }
        }
    }
    
    // MARK: - Tasks Content
    
    private var tasksContent: some View {
        VStack(spacing: 0) {
            // Stats Bar
            statsBar
            
            // Search Bar
            searchBar
            
            // Category Filter
            if !viewModel.categories.isEmpty {
                categoryFilter
            }
            
            // Tasks List
            if viewModel.filteredTasks.isEmpty {
                emptyStateView
            } else {
                tasksList
            }
        }
    }
    
    // MARK: - Stats Bar
    
    private var statsBar: some View {
        HStack(spacing: AppTheme.Spacing.large) {
            StatBadge(title: "Total", value: "\(viewModel.tasks.count)", color: .blue)
            StatBadge(title: "Active", value: "\(viewModel.activeCount)", color: .orange)
            StatBadge(title: "Done", value: "\(viewModel.completedCount)", color: .green)
        }
        .padding(AppTheme.Spacing.medium)
        .background(Color(.systemGray6))
    }
    
    // MARK: - Search Bar
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(AppTheme.Colors.secondary)
            
            TextField("Search tasks...", text: $viewModel.searchText)
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
    
    // MARK: - Tasks List
    
    private var tasksList: some View {
        List {
            ForEach(viewModel.filteredTasks) { task in
                TaskRow(task: task) {
                    viewModel.toggleTaskCompletion(task)
                } onEdit: {
                    viewModel.editingTask = task
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button(role: .destructive) {
                        viewModel.deleteTask(task)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                    
                    Button {
                        viewModel.editingTask = task
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
            Image(systemName: "checklist")
                .font(.system(size: 60))
                .foregroundColor(AppTheme.Colors.secondary)
            
            Text(viewModel.searchText.isEmpty ? "No Tasks" : "No Results")
                .font(AppTheme.Typography.title2)
                .foregroundColor(AppTheme.Colors.foreground)
            
            Text(viewModel.searchText.isEmpty ? "Tap + to add a new task" : "Try a different search term")
                .font(AppTheme.Typography.body)
                .foregroundColor(AppTheme.Colors.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

// MARK: - Task Row

struct TaskRow: View {
    let task: TaskItem
    let onToggle: () -> Void
    let onEdit: () -> Void
    
    var body: some View {
        HStack(spacing: AppTheme.Spacing.medium) {
            // Checkbox
            Button(action: onToggle) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(task.isCompleted ? .green : AppTheme.Colors.secondary)
            }
            
            // Content
            VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
                Text(task.title)
                    .font(AppTheme.Typography.body)
                    .foregroundColor(task.isCompleted ? AppTheme.Colors.secondary : AppTheme.Colors.foreground)
                    .strikethrough(task.isCompleted)
                
                if !task.description.isEmpty {
                    Text(task.description)
                        .font(AppTheme.Typography.caption)
                        .foregroundColor(AppTheme.Colors.secondary)
                        .lineLimit(2)
                }
                
                HStack {
                    // Priority Badge
                    HStack(spacing: 4) {
                        Image(systemName: task.priority.iconName)
                            .font(.system(size: 10))
                        Text(task.priority.rawValue)
                            .font(.system(size: 10))
                    }
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(
                        Capsule()
                            .fill(colorForPriority(task.priority).opacity(0.2))
                    )
                    .foregroundColor(colorForPriority(task.priority))
                    
                    // Category
                    Text(task.category)
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
                    if let dueDate = task.dueDate {
                        Text(dueDate, style: .date)
                            .font(.system(size: 10))
                            .foregroundColor(isOverdue(dueDate) ? .red : AppTheme.Colors.secondary)
                    }
                }
            }
        }
        .padding(.vertical, AppTheme.Spacing.small)
        .opacity(task.isCompleted ? 0.6 : 1.0)
    }
    
    private func colorForPriority(_ priority: TaskPriority) -> Color {
        switch priority {
        case .low: return .blue
        case .medium: return .orange
        case .high: return .red
        case .urgent: return .purple
        }
    }
    
    private func isOverdue(_ date: Date) -> Bool {
        date < Date() && !Calendar.current.isDateInToday(date)
    }
}

// MARK: - Stat Badge

struct StatBadge: View {
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

// MARK: - Add Task View

struct AddTaskView: View {
    @Environment(\.dismiss) var dismiss
    @Bindable var viewModel: TasksViewModel
    
    @State private var title = ""
    @State private var description = ""
    @State private var priority: TaskPriority = .medium
    @State private var category = "General"
    @State private var dueDate: Date? = nil
    @State private var hasDueDate = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Task Details") {
                    TextField("Title", text: $title)
                    TextField("Description", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section("Priority") {
                    Picker("Priority", selection: $priority) {
                        ForEach(TaskPriority.allCases, id: \.self) { priority in
                            Text(priority.rawValue).tag(priority)
                        }
                    }
                }
                
                Section("Category") {
                    TextField("Category", text: $category)
                }
                
                Section("Due Date") {
                    Toggle("Set Due Date", isOn: $hasDueDate)
                    
                    if hasDueDate {
                        DatePicker("Due Date", selection: Binding(
                            get: { dueDate ?? Date() },
                            set: { dueDate = $0 }
                        ), displayedComponents: [.date, .hourAndMinute])
                    }
                }
            }
            .navigationTitle("New Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let newTask = TaskItem(
                            title: title,
                            description: description,
                            priority: priority,
                            dueDate: hasDueDate ? dueDate : nil,
                            category: category
                        )
                        viewModel.addTask(newTask)
                        dismiss()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
}

// MARK: - Edit Task View

struct EditTaskView: View {
    @Environment(\.dismiss) var dismiss
    let task: TaskItem
    @Bindable var viewModel: TasksViewModel
    
    @State private var title: String
    @State private var description: String
    @State private var priority: TaskPriority
    @State private var category: String
    @State private var dueDate: Date?
    @State private var hasDueDate: Bool
    
    init(task: TaskItem, viewModel: TasksViewModel) {
        self.task = task
        self.viewModel = viewModel
        _title = State(initialValue: task.title)
        _description = State(initialValue: task.description)
        _priority = State(initialValue: task.priority)
        _category = State(initialValue: task.category)
        _dueDate = State(initialValue: task.dueDate)
        _hasDueDate = State(initialValue: task.dueDate != nil)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Task Details") {
                    TextField("Title", text: $title)
                    TextField("Description", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section("Priority") {
                    Picker("Priority", selection: $priority) {
                        ForEach(TaskPriority.allCases, id: \.self) { priority in
                            Text(priority.rawValue).tag(priority)
                        }
                    }
                }
                
                Section("Category") {
                    TextField("Category", text: $category)
                }
                
                Section("Due Date") {
                    Toggle("Set Due Date", isOn: $hasDueDate)
                    
                    if hasDueDate {
                        DatePicker("Due Date", selection: Binding(
                            get: { dueDate ?? Date() },
                            set: { dueDate = $0 }
                        ), displayedComponents: [.date, .hourAndMinute])
                    }
                }
            }
            .navigationTitle("Edit Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        var updatedTask = task
                        updatedTask.title = title
                        updatedTask.description = description
                        updatedTask.priority = priority
                        updatedTask.category = category
                        updatedTask.dueDate = hasDueDate ? dueDate : nil
                        viewModel.updateTask(updatedTask)
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
    TasksView()
}

