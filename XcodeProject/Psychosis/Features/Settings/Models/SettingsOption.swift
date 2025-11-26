//
//  SettingsOption.swift
//  Psychosis
//
//  Created on [Current Date]
//

import Foundation
import SwiftUI

/// Model representing a settings option
struct SettingsOption: Identifiable {
    let id: UUID
    let title: String
    let iconName: String
    let type: SettingsOptionType
    let action: (() -> Void)?
    
    init(
        id: UUID = UUID(),
        title: String,
        iconName: String,
        type: SettingsOptionType,
        action: (() -> Void)? = nil
    ) {
        self.id = id
        self.title = title
        self.iconName = iconName
        self.type = type
        self.action = action
    }
}

enum SettingsOptionType {
    case navigation
    case toggle(Binding<Bool>)
    case action
    case info(String)
}

/// Settings section model
struct SettingsSection: Identifiable {
    let id: UUID
    let title: String?
    let options: [SettingsOption]
    
    init(id: UUID = UUID(), title: String? = nil, options: [SettingsOption]) {
        self.id = id
        self.title = title
        self.options = options
    }
}

