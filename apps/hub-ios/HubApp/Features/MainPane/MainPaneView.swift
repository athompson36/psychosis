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
    @State private var newServerPort: String = "6080"
    @State private var newServerUsername: String = ""
    @State private var newServerPassword: String = ""
    @State private var newServerUseSSL: Bool = false
    @State private var newServerPath: String = "/vnc.html"
    @State private var newServerType: ServerType = .ubuntu
    @State private var showSettings: Bool = false
    
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
            // Top Header Bar (always visible, pull down to show tabs)
            VStack(spacing: 0) {
                // Pull indicator (subtle hint when tabs are available but hidden)
                if !tabsVisible && (showEditorTabs || showPaneTabs) {
                    HStack {
                        Spacer()
                        VStack(spacing: 2) {
                            Image(systemName: "chevron.down")
                                .font(.caption2)
                                .foregroundColor(.secondary.opacity(0.5))
                            Text("Pull down")
                                .font(.caption2)
                                .foregroundColor(.secondary.opacity(0.4))
                        }
                        Spacer()
                    }
                    .frame(height: 20)
                    .padding(.top, 4)
                }
                
                // Header with buttons
                HStack(spacing: 12) {
                    // Editor Tabs Toggle
                    Button(action: {
                        withAnimation {
                            if showEditorTabs {
                                // Toggle off
                                showEditorTabs = false
                                hideTabsIfNeeded()
                            } else {
                                // Toggle on
                                showEditorTabs = true
                                showPaneTabs = false
                                showTabs()
                            }
                        }
                    }) {
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
                    
                    // Pane Tabs Toggle
                    Button(action: {
                        withAnimation {
                            if showPaneTabs {
                                // Toggle off
                                showPaneTabs = false
                                hideTabsIfNeeded()
                            } else {
                                // Toggle on
                                showPaneTabs = true
                                showEditorTabs = false
                                showTabs()
                            }
                        }
                    }) {
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
                    
                    Spacer()
                    
                    // Settings Button
                    Button(action: {
                        showSettings = true
                    }) {
                        Image(systemName: "gearshape.fill")
                            .font(.title3)
                            .padding(8)
                            .background(Color.blue.opacity(0.1))
                            .foregroundColor(.blue)
                            .cornerRadius(8)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom, 4)
            }
            .background(.ultraThinMaterial)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 5)
                    .onChanged { value in
                        // Pull down to show tabs
                        if value.translation.height > 0 && !tabsVisible {
                            dragOffset = min(value.translation.height, 50)
                            if dragOffset > 30 {
                                showTabs()
                            }
                        }
                    }
                    .onEnded { value in
                        dragOffset = 0
                        if value.translation.height > 30 {
                            showTabs()
                        }
                    }
            )
            
            // Editor Tabs (expandable, auto-hide)
            if showEditorTabs && tabsVisible {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(remoteServers) { server in
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
                                    serverManager.deleteServer(server)
                                    if selectedEditorTab?.id == server.id {
                                        selectedEditorTab = remoteServers.first
                                    }
                                }) {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                        
                        // Add Editor Button
                        Menu {
                        Button(action: {
                            // Reset form before opening for new server
                            resetForm()
                            serverToEdit = nil
                            showAddServerSheet = true
                        }) {
                            Label("Custom Server", systemImage: "plus.circle")
                        }
                            
                            Divider()
                            
                            ForEach(ServerPreset.presets, id: \.name) { preset in
                                Button(action: {
                                    let newServer = preset.server
                                    serverManager.addServer(newServer)
                                    selectedEditorTab = newServer
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
                    .padding(.horizontal)
                }
                .padding(.vertical, 8)
                .background(.ultraThinMaterial)
                .transition(.move(edge: .top).combined(with: .opacity))
                .onTapGesture {
                    resetAutoHide()
                }
            }
            
            // Pane Tab Bar (expandable, auto-hide)
            if showPaneTabs && tabsVisible {
                HStack(spacing: 0) {
                    ForEach(PaneTab.allCases, id: \.self) { tab in
                        Button(action: {
                            selectedPaneTab = tab
                            resetAutoHide()
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
                        resetAutoHide()
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
                .transition(.move(edge: .top).combined(with: .opacity))
                .onTapGesture {
                    resetAutoHide()
                }
            }
            
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
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
        .sheet(isPresented: $showAddServerSheet) {
            // Simple add server view (can be replaced with AddRemoteServerView when added to Xcode)
            NavigationView {
                Form {
                    Section(header: Text("Server Information")) {
                        TextField("Server Name", text: $newServerName)
                            .textContentType(.none)
                            .autocapitalization(.words)
                            .submitLabel(.next)
                        
                        TextField("Host or IP Address", text: $newServerHost)
                            .keyboardType(.URL)
                            .autocapitalization(.none)
                            .textContentType(.URL)
                            .submitLabel(.next)
                        
                        TextField("Port", text: $newServerPort)
                            .keyboardType(.numberPad)
                            .textContentType(.none)
                            .submitLabel(.done)
                        
                        Picker("Server Type", selection: $newServerType) {
                            ForEach(ServerType.allCases, id: \.self) { type in
                                HStack {
                                    Text(type.icon)
                                    Text(type.rawValue)
                                }
                                .tag(type)
                            }
                        }
                    }
                    
                    Section(header: Text("Connection Settings")) {
                        Toggle("Use SSL/HTTPS", isOn: $newServerUseSSL)
                        
                        TextField("Connection Path (e.g., /vnc.html)", text: $newServerPath)
                            .keyboardType(.default)
                            .autocapitalization(.none)
                            .textContentType(.none)
                            .submitLabel(.next)
                    }
                    
                    Section(header: Text("Authentication (Optional)")) {
                        TextField("Username", text: $newServerUsername)
                            .keyboardType(.default)
                            .autocapitalization(.none)
                            .textContentType(.username)
                            .submitLabel(.next)
                        
                        SecureField("Password", text: $newServerPassword)
                            .textContentType(.password)
                            .submitLabel(.done)
                    }
                    
                    Section {
                        Button("Save") {
                            saveServer()
                        }
                        .disabled(newServerName.isEmpty || newServerHost.isEmpty || Int(newServerPort) == nil)
                    }
                }
                .navigationTitle(serverToEdit == nil ? "Add Server" : "Edit Server")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") {
                            resetForm()
                            showAddServerSheet = false
                        }
                    }
                }
                .onAppear {
                    // Load existing server data when editing
                    if let existing = serverToEdit {
                        // Always load from the server being edited
                        newServerName = existing.name
                        newServerHost = existing.host
                        newServerPort = String(existing.port)
                        newServerUsername = existing.username ?? ""
                        newServerPassword = existing.password ?? ""
                        newServerUseSSL = existing.useSSL
                        newServerPath = existing.connectionPath ?? "/vnc.html"
                        newServerType = existing.type
                    } else {
                        // For new server, only set defaults if fields are truly empty
                        // This prevents overwriting user input if sheet re-appears
                        if newServerName.isEmpty {
                            newServerName = ""
                        }
                        if newServerHost.isEmpty {
                            newServerHost = ""
                        }
                        if newServerPort.isEmpty {
                            newServerPort = "6080"
                        }
                        if newServerPath.isEmpty {
                            newServerPath = "/vnc.html"
                        }
                    }
                }
                .interactiveDismissDisabled() // Prevent swipe to dismiss - user must use Cancel or Save
            }
        }
        .onAppear {
            // Load servers from manager
            remoteServers = serverManager.servers
            
            // Select first editor by default
            if selectedEditorTab == nil && !remoteServers.isEmpty {
                selectedEditorTab = remoteServers.first
            }
        }
        .onChange(of: serverManager.servers) { oldServers, newServers in
            remoteServers = newServers
            // Update selected tab if it was deleted
            if let selected = selectedEditorTab, !newServers.contains(where: { $0.id == selected.id }) {
                selectedEditorTab = newServers.first
            }
        }
        .onChange(of: showEditorTabs) { oldValue, newValue in
            if newValue {
                showTabs()
            } else {
                hideTabsIfNeeded()
            }
        }
        .onChange(of: showPaneTabs) { oldValue, newValue in
            if newValue {
                showTabs()
            } else {
                hideTabsIfNeeded()
            }
        }
    }
    
    private func showTabs() {
        tabsVisible = true
        resetAutoHide()
    }
    
    private func hideTabsIfNeeded() {
        // Only hide if both tabs are closed
        if !showEditorTabs && !showPaneTabs {
            withAnimation {
                tabsVisible = false
            }
        }
    }
    
    private func resetAutoHide() {
        // Cancel existing auto-hide task
        autoHideTask?.cancel()
        
        // Auto-hide tabs after 5 seconds of inactivity
        autoHideTask = Task {
            try? await Task.sleep(nanoseconds: 5_000_000_000) // 5 seconds
            await MainActor.run {
                if tabsVisible && (showEditorTabs || showPaneTabs) {
                    withAnimation {
                        tabsVisible = false
                    }
                }
            }
        }
    }
    
    private func saveServer() {
        // Validate input
        guard let port = Int(newServerPort), !newServerName.isEmpty, !newServerHost.isEmpty else {
            return
        }
        
        let username = newServerUsername.isEmpty ? nil : newServerUsername
        let password = newServerPassword.isEmpty ? nil : newServerPassword
        let path = newServerPath.isEmpty ? nil : newServerPath
        
        // Save the server
        if let existing = serverToEdit {
            // Update existing server
            let updatedServer = RemoteServer(
                id: existing.id,
                name: newServerName,
                host: newServerHost,
                port: port,
                type: newServerType,
                autoConnect: existing.autoConnect,
                username: username,
                password: password,
                useSSL: newServerUseSSL,
                connectionPath: path
            )
            serverManager.updateServer(updatedServer)
            if selectedEditorTab?.id == existing.id {
                selectedEditorTab = updatedServer
            }
        } else {
            // Create new server
            let newServer = RemoteServer(
                name: newServerName,
                host: newServerHost,
                port: port,
                type: newServerType,
                username: username,
                password: password,
                useSSL: newServerUseSSL,
                connectionPath: path
            )
            serverManager.addServer(newServer)
            selectedEditorTab = newServer
        }
        
        // Reset form first, then close sheet
        // This ensures form is clean for next use
        resetForm()
        showAddServerSheet = false
    }
    
    private func resetForm() {
        newServerName = ""
        newServerHost = ""
        newServerPort = "6080"
        newServerUsername = ""
        newServerPassword = ""
        newServerUseSSL = false
        newServerPath = "/vnc.html"
        newServerType = .ubuntu
        serverToEdit = nil
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

