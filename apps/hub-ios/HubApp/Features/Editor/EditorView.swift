//
//  EditorView.swift
//  Psychosis
//
//  Created on [Current Date]
//

import SwiftUI

struct EditorView: View {
    @Binding var file: FileItem?
    
    @State private var content: String = ""
    @State private var isDirty: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            if let file = file {
                // File Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(file.name)
                            .font(.headline)
                        Text(file.path)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    if isDirty {
                        Circle()
                            .fill(Color.orange)
                            .frame(width: 8, height: 8)
                    }
                    
                    Button("Save") {
                        saveFile()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(!isDirty)
                }
                .padding()
                .background(.ultraThinMaterial)
                
                Divider()
                
                // Editor
                TextEditor(text: $content)
                    .font(.system(.body, design: .monospaced))
                    .padding()
                    .background(Color(.systemBackground))
                    .onChange(of: content) { _ in
                        isDirty = true
                        file?.content = content
                    }
            } else {
                VStack(spacing: 16) {
                    Image(systemName: "doc.text")
                        .font(.system(size: 60))
                        .foregroundColor(.secondary)
                    
                    Text("No file open")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("Select a file from the Files tab to start editing")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .background(.ultraThinMaterial)
        .cornerRadius(12)
        .onChange(of: file?.content) { newContent in
            if let newContent = newContent {
                content = newContent
                isDirty = false
            }
        }
        .onAppear {
            content = file?.content ?? ""
        }
    }
    
    private func saveFile() {
        guard let file = file else { return }
        
        Task {
            do {
                try await APIClient.shared.saveFile(path: file.path, content: content)
                await MainActor.run {
                    isDirty = false
                }
            } catch {
                print("Failed to save file: \(error)")
            }
        }
    }
}

#Preview {
    EditorView(file: .constant(FileItem(name: "test.js", path: "/test.js", type: .file, content: "console.log('hello');")))
        .background(Color.black)
}

