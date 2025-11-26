//
//  MainPaneView.swift
//  Psychosis
//
//  Created on [Current Date]
//

import SwiftUI

struct MainPaneView: View {
    @Binding var currentFile: FileItem?
    
    @State private var selectedEditorTab: RemoteServer?
    @State private var selectedPaneTab: PaneTab = .chat
    @State private var isSplit: Bool = false
    @State private var remoteServers: [RemoteServer] = [
        RemoteServer(name: "fs-dev Ubuntu", host: "fs-dev.local", type: .ubuntu),
        RemoteServer(name: "Mac Studio", host: "mac-studio.local", type: .mac)
    ]
    
    enum PaneTab: String, CaseIterable {
        case chat = "Chat"
        case editor = "Editor"
        case files = "Files"
        
        var icon: String {
            switch self {
            case .chat: return "message.fill"
            case .editor: return "doc.text.fill"
            case .files: return "folder.fill"
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Editor Tabs (above pane tabs)
            if !remoteServers.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(remoteServers) { server in
                            Button(action: {
                                selectedEditorTab = server
                            }) {
                                HStack(spacing: 6) {
                                    Text(server.type.icon)
                                    Text(server.name)
                                        .font(.caption)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(selectedEditorTab?.id == server.id ? Color.blue.opacity(0.3) : Color.blue.opacity(0.1))
                                .foregroundColor(selectedEditorTab?.id == server.id ? .blue : .secondary)
                                .cornerRadius(8)
                            }
                        }
                        
                        // Add Editor Button
                        Button(action: {
                            addNewEditor()
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "plus.circle.fill")
                                Text("Add Editor")
                                    .font(.caption)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.green.opacity(0.2))
                            .foregroundColor(.green)
                            .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 8)
                .background(.ultraThinMaterial)
            }
            
            // Pane Tab Bar
            HStack(spacing: 0) {
                ForEach(PaneTab.allCases, id: \.self) { tab in
                    Button(action: {
                        selectedPaneTab = tab
                    }) {
                        VStack(spacing: 4) {
                            Image(systemName: tab.icon)
                            Text(tab.rawValue)
                                .font(.caption2)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(selectedPaneTab == tab ? Color.blue.opacity(0.2) : Color.clear)
                        .foregroundColor(selectedPaneTab == tab ? .blue : .secondary)
                    }
                }
                
                Spacer()
                
                // Split Toggle
                Button(action: {
                    isSplit.toggle()
                }) {
                    Image(systemName: isSplit ? "rectangle.split.2x1" : "rectangle")
                        .font(.title3)
                        .padding(8)
                        .background(isSplit ? Color.blue.opacity(0.2) : Color.clear)
                        .foregroundColor(isSplit ? .blue : .secondary)
                        .cornerRadius(8)
                }
                .padding(.trailing)
            }
            .background(.ultraThinMaterial)
            .cornerRadius(12, corners: [.topLeft, .topRight])
            .padding(.horizontal)
            
            // Content Area
            GeometryReader { geometry in
                if isSplit {
                    // Split View
                    if geometry.size.width > geometry.size.height {
                        // Landscape: Side by side
                        HStack(spacing: 0) {
                            paneContent(selectedPaneTab)
                                .frame(width: geometry.size.width / 2)
                            
                            Divider()
                            
                            paneContent(secondaryPaneTab)
                                .frame(width: geometry.size.width / 2)
                        }
                    } else {
                        // Portrait: Top and bottom
                        VStack(spacing: 0) {
                            paneContent(selectedPaneTab)
                                .frame(height: geometry.size.height / 2)
                            
                            Divider()
                            
                            paneContent(secondaryPaneTab)
                                .frame(height: geometry.size.height / 2)
                        }
                    }
                } else {
                    // Single View
                    paneContent(selectedPaneTab)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
        }
        .padding(.horizontal)
        .padding(.bottom)
        .onAppear {
            // Select first editor by default
            if selectedEditorTab == nil && !remoteServers.isEmpty {
                selectedEditorTab = remoteServers.first
            }
        }
    }
    
    private var secondaryPaneTab: PaneTab {
        let tabs = PaneTab.allCases
        guard let currentIndex = tabs.firstIndex(of: selectedPaneTab) else {
            return .chat
        }
        let nextIndex = (currentIndex + 1) % tabs.count
        return tabs[nextIndex]
    }
    
    @ViewBuilder
    private func paneContent(_ tab: PaneTab) -> some View {
        switch tab {
        case .chat:
            // Chat is now the remote desktop view of Cursor chat
            if let server = selectedEditorTab {
                RemoteDesktopView(remoteServer: server)
            } else {
                VStack(spacing: 16) {
                    Image(systemName: "server.rack")
                        .font(.system(size: 60))
                        .foregroundColor(.secondary)
                    
                    Text("No Editor Selected")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("Select a remote editor from the tabs above")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.ultraThinMaterial)
                .cornerRadius(12)
            }
        case .editor:
            EditorView(file: $currentFile)
        case .files:
            FileBrowserView(selectedFile: $currentFile)
        }
    }
    
    private func addNewEditor() {
        // TODO: Show a sheet to add a new remote editor
        // For now, just add a placeholder
        let newServer = RemoteServer(
            name: "New Editor",
            host: "new-editor.local",
            type: .ubuntu
        )
        remoteServers.append(newServer)
        selectedEditorTab = newServer
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

#Preview {
    MainPaneView(currentFile: .constant(nil))
        .background(Color.black)
}

