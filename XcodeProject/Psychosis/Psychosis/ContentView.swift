//
//  ContentView.swift
//  Psychosis
//
//  Created by Andrew Thompson on 11/25/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            
            Text("Welcome to Psychosis")
                .font(.title)
            
            Text("Version 0.1.0")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(32)
    }
}

#Preview {
    ContentView()
}
