//
//  SettingsView.swift
//  Psychosis
//
//  Created on [Current Date]
//

import SwiftUI

/// Settings screen view
struct SettingsView: View {
    @State private var viewModel = SettingsViewModel()
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.sections) { section in
                    Section(header: section.title.map { Text($0) }) {
                        ForEach(section.options) { option in
                            SettingsRow(option: option)
                        }
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - Settings Row

struct SettingsRow: View {
    let option: SettingsOption
    
    var body: some View {
        HStack(spacing: AppTheme.Spacing.medium) {
            // Icon
            Image(systemName: option.iconName)
                .foregroundColor(AppTheme.Colors.primary)
                .frame(width: 24, height: 24)
            
            // Title
            Text(option.title)
                .font(AppTheme.Typography.body)
                .foregroundColor(AppTheme.Colors.foreground)
            
            Spacer()
            
            // Content based on type
            switch option.type {
            case .navigation:
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(AppTheme.Colors.secondary)
                
            case .toggle(let binding):
                Toggle("", isOn: binding)
                    .labelsHidden()
                
            case .action:
                EmptyView()
                
            case .info(let value):
                Text(value)
                    .font(AppTheme.Typography.caption)
                    .foregroundColor(AppTheme.Colors.secondary)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            if case .action = option.type {
                option.action?()
            }
        }
    }
}

// MARK: - Preview

#Preview {
    SettingsView()
}

