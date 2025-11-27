//
//  ContentView.swift
//  Psychosis
//
//  Created on [Current Date]
//

import SwiftUI

struct ContentView: View {
    @State private var currentFile: FileItem? = nil
    
    var body: some View {
        MainPaneView(currentFile: $currentFile)
            .background(
                LinearGradient(
                    colors: [Color(hex: "050811"), Color(hex: "0a0e27")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .ignoresSafeArea(.container, edges: .bottom)
    }
}

#Preview {
    ContentView()
}

