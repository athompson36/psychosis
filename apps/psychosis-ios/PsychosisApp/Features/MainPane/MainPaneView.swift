//
//  MainPaneView.swift
//  Psychosis
//
//  Created on [Current Date]
//

import SwiftUI

struct MainPaneView: View {
    @Binding var currentFile: FileItem?
    
    @StateObject private var serverManager = RemoteServerManager.shared
    @State private var remoteServers: [RemoteServer] = []
    @State private var selectedServer: RemoteServer?
    @State private var selectedPaneTab: PaneTab = .chat
    @State private var isSplit: Bool = false
    @State private var showAddServerSheet: Bool = false
    @State private var serverToEdit: RemoteServer?
    @State private var showSettings: Bool = false
    @State private var cursorPane: CursorPane = .chat
    
    // Header visibility state
    @State private var headerVisible: Bool = false
    @State private var showServerTabs: Bool = false
    @State private var showPaneTabs: Bool = false
    @State private var autoHideTask: Task<Void, Never>?
    @State private var dragOffset: CGFloat = 0
    
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
        ZStack(alignment: .top) {
            // Background
            Color.black.ignoresSafeArea()
            
            // Main content
            VStack(spacing: 0) {
                // Spacer for header when visible
                if headerVisible {
                    Color.clear
                        .frame(height: headerHeight)
                }
                
                // VNC content area
                contentArea
            }
            
            // Pull-down indicator (always visible at top)
            VStack(spacing: 0) {
                pullDownIndicator
                
                // Collapsible header
                if headerVisible {
                    headerContent
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
            .animation(.spring(response: 0.3, dampingFraction: 0.8), value: headerVisible)
        }
        .gesture(headerDragGesture)
        .ignoresSafeArea(.container, edges: .bottom)
        .sheet(isPresented: $showSettings) {
            settingsSheet
        }
        .sheet(isPresented: $showAddServerSheet) {
            addServerSheet
        }
        .onAppear {
            remoteServers = serverManager.servers
        }
        .onChange(of: serverManager.servers) { _, newServers in
            remoteServers = newServers
            if let selected = selectedServer, !newServers.contains(where: { $0.id == selected.id }) {
                selectedServer = newServers.first
            }
        }
        .onChange(of: selectedPaneTab) { _, newValue in
            switch newValue {
            case .chat: cursorPane = .chat
            case .editor: cursorPane = .editor
            case .files: cursorPane = .files
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var headerHeight: CGFloat {
        var height: CGFloat = 60 // Base header height
        if showServerTabs { height += 50 }
        if showPaneTabs { height += 50 }
        return height
    }
    
    // MARK: - Pull-down Indicator
    
    private var pullDownIndicator: some View {
        Button(action: toggleHeader) {
            VStack(spacing: 4) {
                // Arrow indicator
                Image(systemName: headerVisible ? "chevron.up" : "chevron.down")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white.opacity(0.6))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 24)
            .background(
                LinearGradient(
                    colors: [Color.black.opacity(0.8), Color.clear],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Header Content
    
    private var headerContent: some View {
        VStack(spacing: 0) {
            // Main header bar with Servers button and Settings
            HStack(spacing: 12) {
                // Servers toggle button
                Button(action: toggleServerTabs) {
                    HStack(spacing: 6) {
                        Image(systemName: showServerTabs ? "chevron.down" : "chevron.right")
                        Text("Servers")
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(showServerTabs ? Color.blue.opacity(0.3) : Color.blue.opacity(0.15))
                    .foregroundColor(showServerTabs ? .blue : .white.opacity(0.8))
                    .cornerRadius(8)
                }
                
                Spacer()
                
                // Connection quality indicator
                if selectedServer != nil {
                    connectionQualityIndicator
                }
                
                // Settings button
                Button(action: { showSettings = true }) {
                    Image(systemName: "gearshape.fill")
                        .font(.title3)
                        .padding(8)
                        .background(Color.white.opacity(0.1))
                        .foregroundColor(.white.opacity(0.8))
                        .cornerRadius(8)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(.ultraThinMaterial)
            
            // Server tabs (nested level 1)
            if showServerTabs {
                serverTabsBar
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
            
            // Pane tabs (nested level 2 - under selected server)
            if showPaneTabs && selectedServer != nil {
                paneTabsBar
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.25, dampingFraction: 0.8), value: showServerTabs)
        .animation(.spring(response: 0.25, dampingFraction: 0.8), value: showPaneTabs)
    }
    
    // MARK: - Server Tabs Bar
    
    private var serverTabsBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(remoteServers) { server in
                    serverTabButton(for: server)
                }
                
                // Add server button
                Button(action: {
                    serverToEdit = nil
                    showAddServerSheet = true
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "plus.circle.fill")
                        Text("Add")
                            .font(.caption)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.green.opacity(0.2))
                    .foregroundColor(.green)
                    .cornerRadius(8)
                }
            }
            .padding(.horizontal, 16)
        }
        .padding(.vertical, 8)
        .background(Color.black.opacity(0.3))
    }
    
    private func serverTabButton(for server: RemoteServer) -> some View {
        Button(action: {
            withAnimation {
                if selectedServer?.id == server.id {
                    // Toggle pane tabs if tapping the same server
                    showPaneTabs.toggle()
                } else {
                    selectedServer = server
                    showPaneTabs = true
                }
                resetAutoHide()
            }
        }) {
            HStack(spacing: 6) {
                Text(server.type.icon)
                Text(server.name)
                    .font(.caption)
                if selectedServer?.id == server.id {
                    Image(systemName: showPaneTabs ? "chevron.down" : "chevron.right")
                        .font(.caption2)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(selectedServer?.id == server.id ? Color.blue.opacity(0.3) : Color.white.opacity(0.1))
            .foregroundColor(selectedServer?.id == server.id ? .blue : .white.opacity(0.8))
            .cornerRadius(8)
        }
        .contextMenu {
            Button(action: {
                serverToEdit = server
                showAddServerSheet = true
            }) {
                Label("Edit", systemImage: "pencil")
            }
            
            Button(role: .destructive, action: {
                serverManager.deleteServer(server)
                if selectedServer?.id == server.id {
                    selectedServer = remoteServers.first
                }
            }) {
                Label("Delete", systemImage: "trash")
            }
        }
    }
    
    // MARK: - Pane Tabs Bar
    
    private var paneTabsBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(PaneTab.allCases, id: \.self) { tab in
                    paneTabButton(for: tab)
                }
            }
            .padding(.horizontal, 16)
        }
        .padding(.vertical, 8)
        .background(Color.black.opacity(0.2))
    }
    
    private func paneTabButton(for tab: PaneTab) -> some View {
        Button(action: {
            withAnimation {
                selectedPaneTab = tab
                resetAutoHide()
            }
        }) {
            HStack(spacing: 6) {
                Image(systemName: tab.icon)
                    .font(.system(size: 12))
                Text(tab.rawValue)
                    .font(.caption)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(selectedPaneTab == tab ? Color.purple.opacity(0.3) : Color.white.opacity(0.1))
            .foregroundColor(selectedPaneTab == tab ? .purple : .white.opacity(0.8))
            .cornerRadius(6)
        }
    }
    
    // MARK: - Connection Quality Indicator
    
    private var connectionQualityIndicator: some View {
        let qualityMonitor = ConnectionQualityMonitor.shared
        return HStack(spacing: 4) {
            Image(systemName: qualityMonitor.quality.icon)
                .foregroundColor(qualityMonitor.quality.color)
                .font(.caption2)
            
            if let latency = qualityMonitor.latency {
                Text("\(Int(latency))ms")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(Color.white.opacity(0.1))
        .cornerRadius(6)
    }
    
    // MARK: - Content Area
    
    private var contentArea: some View {
        GeometryReader { geometry in
            if let server = selectedServer {
                // Show VNC view for selected server
                RemoteDesktopViewV2(remoteServer: server, selectedPane: $cursorPane)
                    .id(server.id)
            } else {
                // Show server list when no server selected
                serverListView
            }
        }
    }
    
    // MARK: - Server List View
    
    private var serverListView: some View {
        ScrollView {
            VStack(spacing: 16) {
                if remoteServers.isEmpty {
                    emptyServerListView
                } else {
                    serverCardsView
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var emptyServerListView: some View {
        VStack(spacing: 16) {
            Image(systemName: "server.rack")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("No Servers Configured")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            Text("Add a server to get started")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button(action: { showAddServerSheet = true }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Add Server")
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .padding(.top, 8)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 100)
    }
    
    private var serverCardsView: some View {
        VStack(spacing: 12) {
            ForEach(remoteServers) { server in
                serverCard(for: server)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 20)
    }
    
    private func serverCard(for server: RemoteServer) -> some View {
        HStack(spacing: 12) {
            Text(server.type.icon)
                .font(.title2)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(server.name)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text("\(server.host):\(server.port)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Connect Button
            Button(action: {
                selectedServer = server
                headerVisible = true
                showServerTabs = true
                showPaneTabs = true
            }) {
                HStack(spacing: 6) {
                    Image(systemName: "play.circle.fill")
                    Text("Connect")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Color.green)
                .cornerRadius(8)
            }
            .buttonStyle(.plain)
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(12)
    }
    
    // MARK: - Sheets
    
    private var settingsSheet: some View {
        SettingsView(onConnect: { server in
            selectedServer = server
            headerVisible = true
            showServerTabs = true
            showPaneTabs = true
        })
    }
    
    private var addServerSheet: some View {
        ServerFormView(serverToEdit: serverToEdit) { server in
            if serverToEdit != nil {
                serverManager.updateServer(server)
                if selectedServer?.id == serverToEdit?.id {
                    selectedServer = server
                }
            } else {
                serverManager.addServer(server)
                selectedServer = server
            }
            serverToEdit = nil
        }
    }
    
    // MARK: - Gestures
    
    private var headerDragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                if value.translation.height > 30 && !headerVisible {
                    withAnimation {
                        headerVisible = true
                        showServerTabs = true
                        if selectedServer != nil {
                            showPaneTabs = true
                        }
                    }
                    resetAutoHide()
                } else if value.translation.height < -30 && headerVisible {
                    withAnimation {
                        hideHeader()
                    }
                }
            }
    }
    
    // MARK: - Actions
    
    private func toggleHeader() {
        withAnimation {
            if headerVisible {
                hideHeader()
            } else {
                headerVisible = true
                showServerTabs = true
                if selectedServer != nil {
                    showPaneTabs = true
                }
                resetAutoHide()
            }
        }
    }
    
    private func toggleServerTabs() {
        withAnimation {
            showServerTabs.toggle()
            if !showServerTabs {
                showPaneTabs = false
            }
            resetAutoHide()
        }
    }
    
    private func hideHeader() {
        headerVisible = false
        showServerTabs = false
        showPaneTabs = false
    }
    
    private func resetAutoHide() {
        autoHideTask?.cancel()
        autoHideTask = Task {
            try? await Task.sleep(nanoseconds: 4_000_000_000) // 4 seconds
            await MainActor.run {
                withAnimation {
                    hideHeader()
                }
            }
        }
    }
}

// MARK: - Extensions

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
