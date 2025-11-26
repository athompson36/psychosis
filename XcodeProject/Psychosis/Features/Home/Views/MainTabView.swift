//
//  MainTabView.swift
//  Psychosis
//
//  Created on [Current Date]
//

import SwiftUI

/// Main tab view for app navigation
struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
        }
        .tint(AppTheme.Colors.primary)
    }
}

// MARK: - Preview

#Preview {
    MainTabView()
}

