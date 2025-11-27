//
//  FileBrowserView.swift
//  Psychosis
//
//  Created on [Current Date]
//

import SwiftUI

struct FileBrowserView: View {
    @Binding var selectedFile: FileItem?
    
    @State private var files: [FileItem] = []
    @State private var currentPath: String = "/"
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    
    var body: some View {
        VStack(spacing: 0) {
            // Path Header
            HStack {
                Text("Path: \(currentPath)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                
                Spacer()
                
                Button(action: {
                    currentPath = "/"
                    loadFiles()
                }) {
                    Image(systemName: "house.fill")
                }
            }
            .padding()
            .background(.ultraThinMaterial)
            
            Divider()
            
            // File List
            if isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let errorMessage = errorMessage {
                VStack {
                    Text("Error")
                        .font(.headline)
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
            } else {
                List(files) { file in
                    Button(action: {
                        handleFileTap(file)
                    }) {
                        HStack {
                            Image(systemName: file.type == .directory ? "folder.fill" : "doc.fill")
                                .foregroundColor(file.type == .directory ? .blue : .secondary)
                            
                            Text(file.name)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            if file.type == .directory {
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                .listStyle(.plain)
            }
        }
        .background(.ultraThinMaterial)
        .cornerRadius(12)
        .onAppear {
            loadFiles()
        }
    }
    
    private func loadFiles() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let loadedFiles = try await APIClient.shared.getFileTree(path: currentPath)
                await MainActor.run {
                    files = loadedFiles
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    isLoading = false
                    // Mock data for development
                    files = [
                        FileItem(name: "src", path: "/src", type: .directory),
                        FileItem(name: "package.json", path: "/package.json", type: .file),
                        FileItem(name: "README.md", path: "/README.md", type: .file)
                    ]
                }
            }
        }
    }
    
    private func handleFileTap(_ file: FileItem) {
        if file.type == .directory {
            currentPath = file.path
            loadFiles()
        } else {
            Task {
                do {
                    let fileContent = try await APIClient.shared.getFileContent(path: file.path)
                    await MainActor.run {
                        selectedFile = fileContent
                    }
                } catch {
                    print("Failed to load file: \(error)")
                }
            }
        }
    }
}

#Preview {
    FileBrowserView(selectedFile: .constant(nil))
        .background(Color.black)
}

