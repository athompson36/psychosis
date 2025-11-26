//
//  ContentView.swift
//  Psychosis
//
//  Created on [Current Date]
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTool: String = "dev-remote"
    @State private var connectionStatus: String = "connected"
    @State private var currentFile: FileItem? = nil
    
    var body: some View {
        VStack(spacing: 0) {
            EditorBarView(
                selectedTool: $selectedTool,
                connectionStatus: connectionStatus
            )
            
            MainPaneView(
                selectedTool: selectedTool,
                currentFile: $currentFile
            )
        }
        .background(
            LinearGradient(
                colors: [Color(hex: "050811"), Color(hex: "0a0e27")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .ignoresSafeArea()
    }
}

#Preview {
    ContentView()
}

