//
//  TasksViewModel.swift
//  Psychosis
//
//  Created on [Current Date]
//

import Foundation

/// ViewModel for Tasks screen
@Observable
final class TasksViewModel {
    // MARK: - Properties
    
    var tasks: [TaskItem] = []
    var isLoading = false
    var errorMessage: String?
    var filter: TaskFilter = .all
    var sortOption: TaskSortOption = .createdDate
    var searchText = ""
    var selectedCategory: String? = nil
    var showingAddTask = false
    var editingTask: TaskItem? = nil
    
    // MARK: - Dependencies
    
    private let storageManager: StorageManager
    
    // MARK: - Initialization
    
    init(storageManager: StorageManager = DefaultStorageManager()) {
        self.storageManager = storageManager
    }
    
    // MARK: - Computed Properties
    
    var categories: [String] {
        Array(Set(tasks.map { $0.category })).sorted()
    }
    
    var filteredTasks: [TaskItem] {
        var result = tasks
        
        // Apply filter
        switch filter {
        case .all:
            break
        case .active:
            result = result.filter { !$0.isCompleted }
        case .completed:
            result = result.filter { $0.isCompleted }
        case .dueToday:
            result = result.filter { task in
                guard let dueDate = task.dueDate else { return false }
                return Calendar.current.isDateInToday(dueDate)
            }
        }
        
        // Apply category filter
        if let category = selectedCategory {
            result = result.filter { $0.category == category }
        }
        
        // Apply search
        if !searchText.isEmpty {
            result = result.filter { task in
                task.title.localizedCaseInsensitiveContains(searchText) ||
                task.description.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Apply sort
        switch sortOption {
        case .createdDate:
            result = result.sorted { $0.createdAt > $1.createdAt }
        case .dueDate:
            result = result.sorted { task1, task2 in
                guard let date1 = task1.dueDate else { return false }
                guard let date2 = task2.dueDate else { return true }
                return date1 < date2
            }
        case .priority:
            let priorityOrder: [TaskPriority] = [.urgent, .high, .medium, .low]
            result = result.sorted { task1, task2 in
                let index1 = priorityOrder.firstIndex(of: task1.priority) ?? 999
                let index2 = priorityOrder.firstIndex(of: task2.priority) ?? 999
                return index1 < index2
            }
        case .alphabetical:
            result = result.sorted { $0.title < $1.title }
        }
        
        return result
    }
    
    var completedCount: Int {
        tasks.filter { $0.isCompleted }.count
    }
    
    var activeCount: Int {
        tasks.filter { !$0.isCompleted }.count
    }
    
    // MARK: - Public Methods
    
    /// Load tasks
    @MainActor
    func loadTasks() async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds
            
            if let saved: [TaskItem] = try? storageManager.load([TaskItem].self, forKey: Constants.StorageKeys.tasks) {
                tasks = saved
            } else {
                tasks = createSampleTasks()
                try? saveTasks()
            }
            
            isLoading = false
        } catch {
            errorMessage = "Failed to load tasks: \(error.localizedDescription)"
            isLoading = false
        }
    }
    
    /// Add task
    func addTask(_ task: TaskItem) {
        tasks.append(task)
        try? saveTasks()
    }
    
    /// Update task
    func updateTask(_ task: TaskItem) {
        guard let index = tasks.firstIndex(where: { $0.id == task.id }) else { return }
        tasks[index] = task
        try? saveTasks()
    }
    
    /// Delete task
    func deleteTask(_ task: TaskItem) {
        tasks.removeAll { $0.id == task.id }
        try? saveTasks()
    }
    
    /// Toggle task completion
    func toggleTaskCompletion(_ task: TaskItem) {
        guard let index = tasks.firstIndex(where: { $0.id == task.id }) else { return }
        tasks[index].isCompleted.toggle()
        tasks[index].completedAt = tasks[index].isCompleted ? Date() : nil
        try? saveTasks()
    }
    
    /// Set filter
    func setFilter(_ filter: TaskFilter) {
        self.filter = filter
    }
    
    /// Set sort option
    func setSortOption(_ option: TaskSortOption) {
        self.sortOption = option
    }
    
    /// Set category filter
    func setCategoryFilter(_ category: String?) {
        selectedCategory = category
    }
    
    /// Clear completed tasks
    func clearCompleted() {
        tasks.removeAll { $0.isCompleted }
        try? saveTasks()
    }
    
    // MARK: - Private Methods
    
    private func createSampleTasks() -> [TaskItem] {
        [
            TaskItem(
                title: "Complete project setup",
                description: "Finish setting up the Psychosis app",
                priority: .high,
                category: "Development"
            ),
            TaskItem(
                title: "Review code",
                description: "Review all feature implementations",
                priority: .medium,
                category: "Development"
            ),
            TaskItem(
                title: "Write tests",
                description: "Add unit tests for ViewModels",
                priority: .high,
                category: "Testing"
            )
        ]
    }
    
    private func saveTasks() throws {
        try storageManager.save(tasks, forKey: Constants.StorageKeys.tasks)
    }
}

enum TaskFilter: String, CaseIterable {
    case all = "All"
    case active = "Active"
    case completed = "Completed"
    case dueToday = "Due Today"
}

enum TaskSortOption: String, CaseIterable {
    case createdDate = "Created Date"
    case dueDate = "Due Date"
    case priority = "Priority"
    case alphabetical = "Alphabetical"
}

