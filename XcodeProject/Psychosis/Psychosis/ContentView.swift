//
//  ContentView.swift
//  Psychosis
//
//  Created by Andrew Thompson on 11/25/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(spacing: AppTheme.Spacing.large) {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(AppTheme.Colors.primary)
            
            Text("Welcome to \(Constants.appName)")
                .font(AppTheme.Typography.title)
                .foregroundColor(AppTheme.Colors.foreground)
            
            Text("Version \(Constants.appVersion)")
                .font(AppTheme.Typography.caption)
                .foregroundColor(AppTheme.Colors.secondary)
        }
        .padding(AppTheme.Spacing.extraLarge)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppTheme.Colors.background)
    }
}

#Preview {
    ContentView()
}
