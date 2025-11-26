//
//  MediaView.swift
//  Psychosis
//
//  Created on [Current Date]
//

import SwiftUI

/// Media screen view
struct MediaView: View {
    @State private var viewModel = MediaViewModel()
    
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
                            await viewModel.loadMedia()
                        }
                    }
                } else {
                    mediaContent
                }
            }
            .navigationTitle("Media")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        viewModel.showingAddMedia = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $viewModel.showingAddMedia) {
                AddMediaView(viewModel: viewModel)
            }
            .sheet(item: $viewModel.viewingMedia) { media in
                MediaDetailView(media: media, viewModel: viewModel)
            }
            .task {
                await viewModel.loadMedia()
            }
            .refreshable {
                await viewModel.loadMedia()
            }
        }
    }
    
    // MARK: - Media Content
    
    private var mediaContent: some View {
        VStack(spacing: 0) {
            // Search Bar
            searchBar
            
            // Filters
            filtersSection
            
            // Media Grid
            if viewModel.filteredMedia.isEmpty {
                emptyStateView
            } else {
                mediaGrid
            }
        }
    }
    
    // MARK: - Search Bar
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(AppTheme.Colors.secondary)
            
            TextField("Search media...", text: $viewModel.searchText)
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
    
    // MARK: - Filters
    
    private var filtersSection: some View {
        VStack(spacing: AppTheme.Spacing.small) {
            // Type Filter
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppTheme.Spacing.small) {
                    typeChip(title: "All", isSelected: viewModel.selectedType == nil) {
                        viewModel.setTypeFilter(nil)
                    }
                    
                    ForEach(MediaType.allCases, id: \.self) { type in
                        typeChip(title: type.rawValue, isSelected: viewModel.selectedType == type) {
                            viewModel.setTypeFilter(type)
                        }
                    }
                }
                .padding(.horizontal, AppTheme.Spacing.medium)
            }
            
            // Tag Filter
            if !viewModel.allTags.isEmpty {
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
                }
            }
        }
        .padding(.vertical, AppTheme.Spacing.small)
    }
    
    private func typeChip(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
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
    
    // MARK: - Media Grid
    
    private var mediaGrid: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: AppTheme.Spacing.small),
                GridItem(.flexible(), spacing: AppTheme.Spacing.small),
                GridItem(.flexible(), spacing: AppTheme.Spacing.small)
            ], spacing: AppTheme.Spacing.small) {
                ForEach(viewModel.filteredMedia) { media in
                    MediaThumbnail(media: media) {
                        viewModel.viewingMedia = media
                    } onFavorite: {
                        viewModel.toggleFavorite(media)
                    }
                }
            }
            .padding(AppTheme.Spacing.medium)
        }
    }
    
    // MARK: - Empty State
    
    private var emptyStateView: some View {
        VStack(spacing: AppTheme.Spacing.large) {
            Image(systemName: "photo.on.rectangle")
                .font(.system(size: 60))
                .foregroundColor(AppTheme.Colors.secondary)
            
            Text("No Media")
                .font(AppTheme.Typography.title2)
                .foregroundColor(AppTheme.Colors.foreground)
            
            Text("Tap + to add media")
                .font(AppTheme.Typography.body)
                .foregroundColor(AppTheme.Colors.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

// MARK: - Media Thumbnail

struct MediaThumbnail: View {
    let media: MediaItem
    let onTap: () -> Void
    let onFavorite: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .topTrailing) {
                // Thumbnail Image
                if let thumbnailURL = media.thumbnailURL {
                    AsyncImage(url: thumbnailURL) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Rectangle()
                            .fill(Color(.systemGray4))
                            .overlay {
                                ProgressView()
                            }
                    }
                    .frame(height: 120)
                    .clipped()
                } else {
                    Rectangle()
                        .fill(Color(.systemGray4))
                        .frame(height: 120)
                        .overlay {
                            Image(systemName: media.mediaType.iconName)
                                .font(.title)
                                .foregroundColor(AppTheme.Colors.secondary)
                        }
                }
                
                // Favorite Badge
                if media.isFavorite {
                    Image(systemName: "heart.fill")
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(4)
                        .background(Circle().fill(Color.white))
                        .padding(4)
                }
                
                // Type Badge
                VStack {
                    Spacer()
                    HStack {
                        Image(systemName: media.mediaType.iconName)
                            .font(.caption2)
                        Spacer()
                    }
                    .padding(4)
                    .background(Color.black.opacity(0.6))
                }
            }
            .cornerRadius(AppTheme.CornerRadius.medium)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Media Detail View

struct MediaDetailView: View {
    @Environment(\.dismiss) var dismiss
    let media: MediaItem
    @Bindable var viewModel: MediaViewModel
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.large) {
                    // Image
                    if let imageURL = media.imageURL {
                        AsyncImage(url: imageURL) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(maxWidth: .infinity)
                    }
                    
                    // Details
                    VStack(alignment: .leading, spacing: AppTheme.Spacing.medium) {
                        Text(media.title)
                            .font(AppTheme.Typography.title)
                            .foregroundColor(AppTheme.Colors.foreground)
                        
                        if !media.description.isEmpty {
                            Text(media.description)
                                .font(AppTheme.Typography.body)
                                .foregroundColor(AppTheme.Colors.secondary)
                        }
                        
                        // Metadata
                        HStack {
                            Label(media.mediaType.rawValue, systemImage: media.mediaType.iconName)
                            Spacer()
                            Label(formatFileSize(media.fileSize), systemImage: "doc")
                        }
                        .font(AppTheme.Typography.caption)
                        .foregroundColor(AppTheme.Colors.secondary)
                        
                        // Tags
                        if !media.tags.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    ForEach(media.tags, id: \.self) { tag in
                                        Text("#\(tag)")
                                            .font(.system(size: 12))
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(
                                                Capsule()
                                                    .fill(AppTheme.Colors.primary.opacity(0.2))
                                            )
                                            .foregroundColor(AppTheme.Colors.primary)
                                    }
                                }
                            }
                        }
                    }
                    .padding(AppTheme.Spacing.medium)
                }
            }
            .navigationTitle("Media")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        viewModel.toggleFavorite(media)
                        dismiss()
                    } label: {
                        Image(systemName: media.isFavorite ? "heart.fill" : "heart")
                            .foregroundColor(media.isFavorite ? .red : AppTheme.Colors.foreground)
                    }
                }
            }
        }
    }
    
    private func formatFileSize(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB, .useGB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
}

// MARK: - Add Media View

struct AddMediaView: View {
    @Environment(\.dismiss) var dismiss
    @Bindable var viewModel: MediaViewModel
    
    @State private var title = ""
    @State private var description = ""
    @State private var imageURLString = ""
    @State private var mediaType: MediaType = .image
    @State private var tags: [String] = []
    @State private var tagInput = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Media Details") {
                    TextField("Title", text: $title)
                    TextField("Description", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                    TextField("Image URL", text: $imageURLString)
                        .keyboardType(.URL)
                        .autocapitalization(.none)
                }
                
                Section("Type") {
                    Picker("Media Type", selection: $mediaType) {
                        ForEach(MediaType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
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
                            .onSubmit { addTag() }
                        Button("Add") {
                            addTag()
                        }
                        .disabled(tagInput.isEmpty)
                    }
                }
            }
            .navigationTitle("Add Media")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let imageURL = URL(string: imageURLString)
                        let newMedia = MediaItem(
                            title: title,
                            description: description,
                            imageURL: imageURL,
                            thumbnailURL: imageURL,
                            mediaType: mediaType,
                            tags: tags
                        )
                        viewModel.addMedia(newMedia)
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
    MediaView()
}

