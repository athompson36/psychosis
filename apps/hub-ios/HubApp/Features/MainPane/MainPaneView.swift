//
//  MainPaneView.swift
//  Psychosis
//
//  Created on [Current Date]
//

import SwiftUI

struct MainPaneView: View {
    let selectedTool: String
    @Binding var currentFile: FileItem?
    
    @State private var selectedTab: Tab = .chat
    @State private var isSplit: Bool = false
    
    enum Tab: String, CaseIterable {
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
            // Tab Bar
            HStack(spacing: 0) {
                ForEach(Tab.allCases, id: \.self) { tab in
                    Button(action: {
                        selectedTab = tab
                    }) {
                        VStack(spacing: 4) {
                            Image(systemName: tab.icon)
                            Text(tab.rawValue)
                                .font(.caption2)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(selectedTab == tab ? Color.blue.opacity(0.2) : Color.clear)
                        .foregroundColor(selectedTab == tab ? .blue : .secondary)
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
                            tabContent(selectedTab)
                                .frame(width: geometry.size.width / 2)
                            
                            Divider()
                            
                            tabContent(secondaryTab)
                                .frame(width: geometry.size.width / 2)
                        }
                    } else {
                        // Portrait: Top and bottom
                        VStack(spacing: 0) {
                            tabContent(selectedTab)
                                .frame(height: geometry.size.height / 2)
                            
                            Divider()
                            
                            tabContent(secondaryTab)
                                .frame(height: geometry.size.height / 2)
                        }
                    }
                } else {
                    // Single View
                    tabContent(selectedTab)
                }
            }
        }
        .padding(.horizontal)
        .padding(.bottom)
    }
    
    private var secondaryTab: Tab {
        let tabs = Tab.allCases
        guard let currentIndex = tabs.firstIndex(of: selectedTab) else {
            return .chat
        }
        let nextIndex = (currentIndex + 1) % tabs.count
        return tabs[nextIndex]
    }
    
    @ViewBuilder
    private func tabContent(_ tab: Tab) -> some View {
        switch tab {
        case .chat:
            ChatView(file: currentFile)
        case .editor:
            EditorView(file: $currentFile)
        case .files:
            FileBrowserView(selectedFile: $currentFile)
        }
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
    MainPaneView(selectedTool: "dev-remote", currentFile: .constant(nil))
        .background(Color.black)
}

