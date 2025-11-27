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
    @State private var selectedEditorTab: RemoteServer?
    @State private var selectedPaneTab: PaneTab = .chat
    @State private var isSplit: Bool = false
    @State private var showAddServerSheet: Bool = false
    @State private var serverToEdit: RemoteServer?
    @State private var showEditorTabs: Bool = false
    @State private var showPaneTabs: Bool = false
    @State private var tabsVisible: Bool = false
    @State private var dragOffset: CGFloat = 0
    @State private var autoHideTask: Task<Void, Never>?
    @State private var newServerName: String = ""
    @State private var newServerHost: String = ""
    @State private var newServerPort: String = "5900"
    @State private var newServerUsername: String = ""
    @State private var newServerPassword: String = ""
    @State private var newServerUseSSL: Bool = false
    @State private var newServerPath: String = "/vnc.html"
    @State private var newServerType: ServerType = .ubuntu
    @State private var showSettings: Bool = false
    @State private var cursorPane: CursorPane = .chat
    @FocusState private var focusedField: Field?
    
    enum Field: Hashable {
        case serverName, host, port, username, password
    }
    
    enum PaneTab: String, CaseIterable {
        case chat = "Chat"
        case editor = "Editor"
        case files = "Files"
        case terminal = "Terminal"
        
        var icon: String {
            switch self {
            case .chat: return "message.fill"
            case .editor: return "doc.text.fill"
            case .files: return "folder.fill"
            case .terminal: return "terminal.fill"
            }
        }
    }
    
    var body: some View {
        ZStack {
            backgroundView
            mainContentStack
        }
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
        .onChange(of: serverManager.servers) { oldServers, newServers in
            handleServersChange(oldServers: oldServers, newServers: newServers)
        }
        .onChange(of: selectedEditorTab) { oldServer, newServer in
            handleEditorTabChange(oldServer: oldServer, newServer: newServer)
        }
        .onChange(of: selectedPaneTab) { oldValue, newValue in
            handlePaneTabChange(newValue: newValue)
        }
    }
    
    // MARK: - Sub-views
    
    private var backgroundView: some View {
        Color.black.ignoresSafeArea()
    }
    
    private var mainContentStack: some View {
        VStack(spacing: 0) {
            headerBar
            
            if showEditorTabs {
                editorTabsScrollView
            }
            
            if showPaneTabs {
                paneTabsScrollView
            }
            
            contentArea
        }
    }
    
    private var headerBar: some View {
        VStack(spacing: 0) {
            headerButtons
                .padding(.horizontal, 16)
                .padding(.bottom, 4)
        }
        .padding(.top)
        .background(.ultraThinMaterial)
        .zIndex(100)
    }
    
    private var headerButtons: some View {
        HStack(spacing: 12) {
            editorTabsToggleButton
            paneTabsToggleButton
            Spacer()
            connectionQualityIndicator
            settingsButton
        }
    }
    
    private var editorTabsToggleButton: some View {
        Button(action: toggleEditorTabs) {
            HStack(spacing: 6) {
                Image(systemName: showEditorTabs ? "chevron.down" : "chevron.right")
                Text("Editors")
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(showEditorTabs ? Color.blue.opacity(0.2) : Color.blue.opacity(0.1))
            .foregroundColor(showEditorTabs ? .blue : .secondary)
            .cornerRadius(8)
        }
    }
    
    private var paneTabsToggleButton: some View {
        Button(action: togglePaneTabs) {
            HStack(spacing: 6) {
                Image(systemName: showPaneTabs ? "chevron.down" : "chevron.right")
                Text("Panes")
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(showPaneTabs ? Color.blue.opacity(0.2) : Color.blue.opacity(0.1))
            .foregroundColor(showPaneTabs ? .blue : .secondary)
            .cornerRadius(8)
        }
    }
    
    @ViewBuilder
    private var connectionQualityIndicator: some View {
        if selectedEditorTab != nil {
            let qualityMonitor = ConnectionQualityMonitor.shared
            HStack(spacing: 4) {
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
            .background(.ultraThinMaterial)
            .cornerRadius(6)
        }
    }
    
    private var settingsButton: some View {
        Button(action: { showSettings = true }) {
            Image(systemName: "gearshape.fill")
                .font(.title3)
                .padding(8)
                .background(Color.blue.opacity(0.1))
                .foregroundColor(.blue)
                .cornerRadius(8)
        }
    }
    
    private var editorTabsScrollView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(remoteServers) { server in
                    editorTabButton(for: server)
                }
                addEditorMenu
            }
            .padding(.horizontal, 16)
        }
        .padding(.vertical, 8)
        .background(.ultraThinMaterial)
        .transition(.move(edge: .top).combined(with: .opacity))
    }
    
    private func editorTabButton(for server: RemoteServer) -> some View {
        Button(action: {
            selectedEditorTab = server
            resetAutoHide()
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
        .contextMenu {
            Button(action: {
                serverToEdit = server
                showAddServerSheet = true
            }) {
                Label("Edit", systemImage: "pencil")
            }
            
            Button(role: .destructive, action: {
                deleteServer(server)
            }) {
                Label("Delete", systemImage: "trash")
            }
        }
    }
    
    private var addEditorMenu: some View {
        Menu {
            Button(action: {
                resetForm()
                serverToEdit = nil
                showAddServerSheet = true
            }) {
                Label("Custom Server", systemImage: "plus.circle")
            }
            
            Divider()
            
            ForEach(ServerPreset.presets, id: \.name) { preset in
                Button(action: {
                    addPresetServer(preset)
                }) {
                    HStack {
                        Text(preset.icon)
                        VStack(alignment: .leading) {
                            Text(preset.name)
                            Text(preset.description)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        } label: {
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
    
    private var paneTabsScrollView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(PaneTab.allCases, id: \.self) { tab in
                    paneTabButton(for: tab)
                }
                Spacer()
                splitToggleButton
            }
            .padding(.horizontal, 16)
        }
        .padding(.vertical, 8)
        .background(.ultraThinMaterial)
        .transition(.move(edge: .top).combined(with: .opacity))
    }
    
    private func paneTabButton(for tab: PaneTab) -> some View {
        Button(action: {
            selectedPaneTab = tab
            if tab == .terminal {
                isSplit = true
            }
            resetAutoHide()
        }) {
            HStack(spacing: 6) {
                Image(systemName: tab.icon)
                    .font(.system(size: 14))
                Text(tab.rawValue)
                    .font(.subheadline)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(selectedPaneTab == tab ? Color.blue.opacity(0.3) : Color.blue.opacity(0.1))
            .foregroundColor(selectedPaneTab == tab ? .blue : .secondary)
            .cornerRadius(8)
        }
    }
    
    private var splitToggleButton: some View {
        Button(action: {
            isSplit.toggle()
            resetAutoHide()
        }) {
            Image(systemName: isSplit ? "rectangle.split.2x1" : "rectangle")
                .font(.title3)
                .padding(8)
                .background(isSplit ? Color.blue.opacity(0.2) : Color.clear)
                .foregroundColor(isSplit ? .blue : .secondary)
                .cornerRadius(8)
        }
    }
    
    private var contentArea: some View {
        GeometryReader { geometry in
            if isSplit {
                splitView(geometry: geometry)
            } else {
                singleView
            }
        }
    }
    
    @ViewBuilder
    private func splitView(geometry: GeometryProxy) -> some View {
        if geometry.size.width > geometry.size.height {
            landscapeSplitView(geometry: geometry)
        } else {
            portraitSplitView(geometry: geometry)
        }
    }
    
    private func landscapeSplitView(geometry: GeometryProxy) -> some View {
        HStack(spacing: 0) {
            paneContent(selectedPaneTab, isPrimary: true)
                .frame(width: geometry.size.width / 2)
            
            Divider()
            
            paneContent(terminalPaneForSplit, isPrimary: false)
                .frame(width: geometry.size.width / 2)
        }
    }
    
    private func portraitSplitView(geometry: GeometryProxy) -> some View {
        VStack(spacing: 0) {
            paneContent(selectedPaneTab, isPrimary: true)
                .frame(height: geometry.size.height / 2)
            
            Divider()
            
            paneContent(terminalPaneForSplit, isPrimary: false)
                .frame(height: geometry.size.height / 2)
        }
    }
    
    private var singleView: some View {
        paneContent(selectedPaneTab, isPrimary: true)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var settingsSheet: some View {
        SettingsView(onConnect: { server in
            selectedEditorTab = server
            showEditorTabs = true
            tabsVisible = true
            if selectedPaneTab == .terminal && !isSplit {
                selectedPaneTab = .chat
            }
        })
    }
    
    private var addServerSheet: some View {
        ServerFormView(serverToEdit: serverToEdit) { server in
            if let existing = serverToEdit {
                serverManager.updateServer(server)
                if selectedEditorTab?.id == existing.id {
                    selectedEditorTab = server
                }
            } else {
                serverManager.addServer(server)
                selectedEditorTab = server
            }
            serverToEdit = nil
        }
    }
    
    // MARK: - Action Methods
    
    private func toggleEditorTabs() {
        withAnimation {
            if showEditorTabs {
                showEditorTabs = false
                hideTabsIfNeeded()
            } else {
                showEditorTabs = true
                showPaneTabs = false
                tabsVisible = true
                resetAutoHide()
            }
        }
    }
    
    private func togglePaneTabs() {
        withAnimation {
            if showPaneTabs {
                showPaneTabs = false
                hideTabsIfNeeded()
            } else {
                showPaneTabs = true
                showEditorTabs = false
                tabsVisible = true
                resetAutoHide()
            }
        }
    }
    
    private func deleteServer(_ server: RemoteServer) {
        serverManager.deleteServer(server)
        if selectedEditorTab?.id == server.id {
            selectedEditorTab = remoteServers.first
        }
    }
    
    private func addPresetServer(_ preset: ServerPreset) {
        let newServer = preset.server
        serverManager.addServer(newServer)
        selectedEditorTab = newServer
    }
    
    private func handleServersChange(oldServers: [RemoteServer], newServers: [RemoteServer]) {
        remoteServers = newServers
        if let selected = selectedEditorTab, !newServers.contains(where: { $0.id == selected.id }) {
            selectedEditorTab = newServers.first
        }
    }
    
    private func handleEditorTabChange(oldServer: RemoteServer?, newServer: RemoteServer?) {
        print("🔄 selectedEditorTab changed from \(oldServer?.name ?? "nil") to \(newServer?.name ?? "nil")")
        if newServer != nil {
            if selectedPaneTab == .terminal && !isSplit {
                selectedPaneTab = .chat
            }
        }
    }
    
    private func handlePaneTabChange(newValue: PaneTab) {
        switch newValue {
        case .chat: cursorPane = .chat
        case .editor: cursorPane = .editor
        case .files: cursorPane = .files
        case .terminal: cursorPane = .terminal
        }
    }
    
    private var terminalPaneForSplit: PaneTab {
        // When split is active, show terminal in secondary pane
        return .terminal
    }
    
    private func showTabs() {
        tabsVisible = true
        resetAutoHide()
    }
    
    private func hideTabsIfNeeded() {
        if !showEditorTabs && !showPaneTabs {
            withAnimation {
                tabsVisible = false
            }
        }
    }
    
    private func resetAutoHide() {
        autoHideTask?.cancel()
        // Only auto-hide if both toggles are off
        autoHideTask = Task {
            try? await Task.sleep(nanoseconds: 5_000_000_000)
            await MainActor.run {
                if !showEditorTabs && !showPaneTabs {
                    withAnimation {
                        tabsVisible = false
                    }
                }
            }
        }
    }
    
    private func resetForm() {
        newServerName = ""
        newServerHost = ""
        newServerPort = "5900"
        newServerUsername = ""
        newServerPassword = ""
        newServerUseSSL = false
        newServerPath = "/vnc.html"
        newServerType = .ubuntu
        serverToEdit = nil
    }
    
    @ViewBuilder
    private func paneContent(_ tab: PaneTab, isPrimary: Bool) -> some View {
        // When terminal is in split and this is the secondary pane, show terminal
        if !isPrimary && isSplit {
            terminalView()
        } else if let server = selectedEditorTab {
            // Native VNC view when server is selected
            RemoteDesktopViewV2(remoteServer: server, selectedPane: $cursorPane)
                .id(server.id)
                .onAppear {
                    print("✅ paneContent: RemoteDesktopViewV2 appeared for \(server.name)")
                }
        } else {
            // Show server list or appropriate content
            switch tab {
            case .chat, .editor, .files:
                serverListView()
            case .terminal:
                if isPrimary {
                    serverListView()
                } else {
                    terminalView()
                }
            }
        }
    }
    
    @ViewBuilder
    private func serverListView() -> some View {
        ScrollView {
            VStack(spacing: 16) {
                if remoteServers.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "server.rack")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary)
                        
                        Text("No Servers Configured")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("Add a server in Settings to get started")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        Button(action: {
                            showSettings = true
                        }) {
                            HStack {
                                Image(systemName: "gearshape.fill")
                                Text("Open Settings")
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
                    .padding(.top, 60)
                } else {
                    VStack(spacing: 12) {
                        ForEach(remoteServers) { server in
                            HStack(spacing: 12) {
                                Text(server.type.icon)
                                    .font(.title2)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(server.name)
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    
                                    Text("\(server.host):\(server.port)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    
                                    if server.autoConnect {
                                        HStack(spacing: 4) {
                                            Image(systemName: "bolt.fill")
                                                .font(.caption2)
                                            Text("Auto-connect")
                                                .font(.caption2)
                                        }
                                        .foregroundColor(.yellow)
                                        .padding(.top, 2)
                                    }
                                }
                                
                                Spacer()
                                
                                // Connect Button
                                Button(action: {
                                    print("🔌 Connect button tapped for server: \(server.name)")
                                    selectedEditorTab = server
                                    showEditorTabs = true
                                    tabsVisible = true
                                    // Ensure we show a pane that displays the VNC view
                                    if selectedPaneTab == .terminal && !isSplit {
                                        selectedPaneTab = .chat
                                    }
                                    cursorPane = .chat
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
                                
                                // Edit Button
                                Button(action: {
                                    serverToEdit = server
                                    showAddServerSheet = true
                                }) {
                                    Image(systemName: "pencil")
                                        .foregroundColor(.blue)
                                        .font(.title3)
                                        .padding(8)
                                        .background(Color.blue.opacity(0.15))
                                        .cornerRadius(6)
                                }
                                .buttonStyle(.plain)
                            }
                            .padding()
                            .background(.ultraThinMaterial)
                            .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 20)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    @ViewBuilder
    private func terminalView() -> some View {
        VStack(spacing: 16) {
            if let server = selectedEditorTab {
                Text("Terminal - \(server.name)")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                
                // Terminal content would go here
                // For now, show placeholder
                Text("Terminal interface will appear here")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                Text("Select a server to access terminal")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
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
