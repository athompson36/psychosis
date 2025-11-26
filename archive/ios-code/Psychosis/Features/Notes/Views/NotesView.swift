//
//  NotesView.swift
//  Psychosis
//
//  Created on [Current Date]
//

import SwiftUI

/// Notes screen view
struct NotesView: View {
    @State private var viewModel = NotesViewModel()
    
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
                            await viewModel.loadNotes()
                        }
                    }
                } else {
                    notesContent
                }
            }
            .navigationTitle("Notes")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        viewModel.showingAddNote = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu {
                        ForEach(NoteSortOption.allCases, id: \.self) { option in
                            Button(option.rawValue) {
                                viewModel.setSortOption(option)
                            }
                        }
                    } label: {
                        Image(systemName: "arrow.up.arrow.down")
                    }
                }
            }
            .sheet(isPresented: $viewModel.showingAddNote) {
                AddNoteView(viewModel: viewModel)
            }
            .sheet(item: $viewModel.editingNote) { note in
                EditNoteView(note: note, viewModel: viewModel)
            }
            .task {
                await viewModel.loadNotes()
            }
            .refreshable {
                await viewModel.loadNotes()
            }
        }
    }
    
    // MARK: - Notes Content
    
    private var notesContent: some View {
        VStack(spacing: 0) {
            // Search Bar
            searchBar
            
            // Tag Filter
            if !viewModel.allTags.isEmpty {
                tagFilter
            }
            
            // Notes Grid
            if viewModel.filteredNotes.isEmpty {
                emptyStateView
            } else {
                notesGrid
            }
        }
    }
    
    // MARK: - Search Bar
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(AppTheme.Colors.secondary)
            
            TextField("Search notes...", text: $viewModel.searchText)
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
    
    // MARK: - Tag Filter
    
    private var tagFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppTheme.Spacing.small) {
                tagChip(title: "All", isSelected: viewModel.selectedTag == nil) {
                    viewModel.setTagFilter(nil)
                }
                
                ForEach(viewModel.allTags, id: \.self) { tag in
                    tagChip(title: tag, isSelected: viewModel.selectedTag == tag) {
                        viewModel.setTagFilter(tag)
                    }
                }
            }
            .padding(.horizontal, AppTheme.Spacing.medium)
            .padding(.vertical, AppTheme.Spacing.small)
        }
    }
    
    private func tagChip(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text("#\(title)")
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
    
    // MARK: - Notes Grid
    
    private var notesGrid: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: AppTheme.Spacing.medium),
                GridItem(.flexible(), spacing: AppTheme.Spacing.medium)
            ], spacing: AppTheme.Spacing.medium) {
                ForEach(viewModel.filteredNotes) { note in
                    NoteCard(note: note) {
                        viewModel.editingNote = note
                    } onPin: {
                        viewModel.togglePin(note)
                    }
                }
            }
            .padding(AppTheme.Spacing.medium)
        }
    }
    
    // MARK: - Empty State
    
    private var emptyStateView: some View {
        VStack(spacing: AppTheme.Spacing.large) {
            Image(systemName: "note.text")
                .font(.system(size: 60))
                .foregroundColor(AppTheme.Colors.secondary)
            
            Text("No Notes")
                .font(AppTheme.Typography.title2)
                .foregroundColor(AppTheme.Colors.foreground)
            
            Text("Tap + to create your first note")
                .font(AppTheme.Typography.body)
                .foregroundColor(AppTheme.Colors.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

// MARK: - Note Card

struct NoteCard: View {
    let note: Note
    let onTap: () -> Void
    let onPin: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
                // Header
                HStack {
                    Text(note.title)
                        .font(AppTheme.Typography.body)
                        .foregroundColor(AppTheme.Colors.foreground)
                        .fontWeight(.semibold)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    Button(action: onPin) {
                        Image(systemName: note.isPinned ? "pin.fill" : "pin")
                            .font(.system(size: 12))
                            .foregroundColor(AppTheme.Colors.secondary)
                    }
                }
                
                // Content Preview
                if !note.content.isEmpty {
                    Text(note.content)
                        .font(AppTheme.Typography.caption)
                        .foregroundColor(AppTheme.Colors.secondary)
                        .lineLimit(4)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                // Tags
                if !note.tags.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 4) {
                            ForEach(note.tags.prefix(3), id: \.self) { tag in
                                Text("#\(tag)")
                                    .font(.system(size: 9))
                                    .padding(.horizontal, 4)
                                    .padding(.vertical, 2)
                                    .background(
                                        Capsule()
                                            .fill(AppTheme.Colors.primary.opacity(0.2))
                                    )
                                    .foregroundColor(AppTheme.Colors.primary)
                            }
                        }
                    }
                }
                
                // Date
                Text(note.updatedAt, style: .relative)
                    .font(.system(size: 10))
                    .foregroundColor(AppTheme.Colors.secondary)
            }
            .padding(AppTheme.Spacing.medium)
            .frame(height: 150, alignment: .top)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                    .fill(colorForNote(note.color))
                    .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
            )
        }
        .buttonStyle(.plain)
    }
    
    private func colorForNote(_ color: NoteColor) -> Color {
        switch color {
        case .yellow: return Color(red: 1.0, green: 0.98, blue: 0.8)
        case .blue: return Color(red: 0.85, green: 0.9, blue: 1.0)
        case .green: return Color(red: 0.85, green: 1.0, blue: 0.85)
        case .pink: return Color(red: 1.0, green: 0.9, blue: 0.95)
        case .purple: return Color(red: 0.95, green: 0.9, blue: 1.0)
        case .orange: return Color(red: 1.0, green: 0.95, blue: 0.85)
        }
    }
}

// MARK: - Add Note View

struct AddNoteView: View {
    @Environment(\.dismiss) var dismiss
    @Bindable var viewModel: NotesViewModel
    
    @State private var title = ""
    @State private var content = ""
    @State private var tags: [String] = []
    @State private var tagInput = ""
    @State private var color: NoteColor = .yellow
    @State private var isPinned = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Note Details") {
                    TextField("Title", text: $title)
                    TextField("Content", text: $content, axis: .vertical)
                        .lineLimit(5...15)
                }
                
                Section("Tags") {
                    ForEach(tags, id: \.self) { tag in
                        HStack {
                            Text("#\(tag)")
                            Spacer()
                            Button("Remove") {
                                tags.removeAll { $0 == tag }
                            }
                            .foregroundColor(.red)
                        }
                    }
                    
                    HStack {
                        TextField("Add tag", text: $tagInput)
                            .onSubmit {
                                addTag()
                            }
                        Button("Add") {
                            addTag()
                        }
                        .disabled(tagInput.isEmpty)
                    }
                }
                
                Section("Options") {
                    Toggle("Pin Note", isOn: $isPinned)
                    
                    Picker("Color", selection: $color) {
                        ForEach(NoteColor.allCases, id: \.self) { color in
                            Text(color.rawValue).tag(color)
                        }
                    }
                }
            }
            .navigationTitle("New Note")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let newNote = Note(
                            title: title,
                            content: content,
                            isPinned: isPinned,
                            tags: tags,
                            color: color
                        )
                        viewModel.addNote(newNote)
                        dismiss()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
    
    private func addTag() {
        let trimmed = tagInput.trimmingCharacters(in: .whitespaces)
        if !trimmed.isEmpty && !tags.contains(trimmed) {
            tags.append(trimmed)
            tagInput = ""
        }
    }
}

// MARK: - Edit Note View

struct EditNoteView: View {
    @Environment(\.dismiss) var dismiss
    let note: Note
    @Bindable var viewModel: NotesViewModel
    
    @State private var title: String
    @State private var content: String
    @State private var tags: [String]
    @State private var tagInput = ""
    @State private var color: NoteColor
    @State private var isPinned: Bool
    
    init(note: Note, viewModel: NotesViewModel) {
        self.note = note
        self.viewModel = viewModel
        _title = State(initialValue: note.title)
        _content = State(initialValue: note.content)
        _tags = State(initialValue: note.tags)
        _color = State(initialValue: note.color)
        _isPinned = State(initialValue: note.isPinned)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Note Details") {
                    TextField("Title", text: $title)
                    TextField("Content", text: $content, axis: .vertical)
                        .lineLimit(5...15)
                }
                
                Section("Tags") {
                    ForEach(tags, id: \.self) { tag in
                        HStack {
                            Text("#\(tag)")
                            Spacer()
                            Button("Remove") {
                                tags.removeAll { $0 == tag }
                            }
                            .foregroundColor(.red)
                        }
                    }
                    
                    HStack {
                        TextField("Add tag", text: $tagInput)
                            .onSubmit {
                                addTag()
                            }
                        Button("Add") {
                            addTag()
                        }
                        .disabled(tagInput.isEmpty)
                    }
                }
                
                Section("Options") {
                    Toggle("Pin Note", isOn: $isPinned)
                    
                    Picker("Color", selection: $color) {
                        ForEach(NoteColor.allCases, id: \.self) { color in
                            Text(color.rawValue).tag(color)
                        }
                    }
                }
            }
            .navigationTitle("Edit Note")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        var updatedNote = note
                        updatedNote.title = title
                        updatedNote.content = content
                        updatedNote.tags = tags
                        updatedNote.color = color
                        updatedNote.isPinned = isPinned
                        viewModel.updateNote(updatedNote)
                        dismiss()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
    
    private func addTag() {
        let trimmed = tagInput.trimmingCharacters(in: .whitespaces)
        if !trimmed.isEmpty && !tags.contains(trimmed) {
            tags.append(trimmed)
            tagInput = ""
        }
    }
}

// MARK: - Preview

#Preview {
    NotesView()
}

