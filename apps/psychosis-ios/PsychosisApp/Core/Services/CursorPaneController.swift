//
//  CursorPaneController.swift
//  PsychosisApp
//
//  Controller for switching Cursor panes via keyboard shortcuts
//

import Foundation

@MainActor
class CursorPaneController {
    private let vncConnection: VNCConnection
    
    init(vncConnection: VNCConnection) {
        self.vncConnection = vncConnection
    }
    
    // MARK: - Pane Switching
    
    func switchToEditor() async {
        print("🎯 Switching to Editor pane")
        
        // Sequence: Ctrl+K, Z (Zen mode), then Ctrl+1 (focus editor)
        await sendKeySequence([
            (0xFFE3, true),   // Ctrl down
            (0x006B, true),   // K down
            (0x006B, false),  // K up
            (0xFFE3, false),  // Ctrl up
        ])
        
        // Wait for chord recognition
        try? await Task.sleep(nanoseconds: 150_000_000) // 150ms
        
        await sendKeySequence([
            (0x007A, true),   // Z down
            (0x007A, false),  // Z up
        ])
        
        // Wait for Zen mode to activate
        try? await Task.sleep(nanoseconds: 400_000_000) // 400ms
        
        await sendKeySequence([
            (0xFFE3, true),   // Ctrl down
            (0x0031, true),   // 1 down
            (0x0031, false),  // 1 up
            (0xFFE3, false),  // Ctrl up
        ])
        
        print("✅ Editor pane activated")
    }
    
    func switchToChat() async {
        print("🎯 Switching to Chat pane")
        
        // Sequence: Ctrl+K, Z (Zen mode), then Ctrl+L (open chat)
        await sendKeySequence([
            (0xFFE3, true),   // Ctrl down
            (0x006B, true),   // K down
            (0x006B, false),  // K up
            (0xFFE3, false),  // Ctrl up
        ])
        
        try? await Task.sleep(nanoseconds: 150_000_000) // 150ms
        
        await sendKeySequence([
            (0x007A, true),   // Z down
            (0x007A, false),  // Z up
        ])
        
        try? await Task.sleep(nanoseconds: 400_000_000) // 400ms
        
        await sendKeySequence([
            (0xFFE3, true),   // Ctrl down
            (0x006C, true),   // L down
            (0x006C, false),  // L up
            (0xFFE3, false),  // Ctrl up
        ])
        
        print("✅ Chat pane activated")
    }
    
    func switchToFiles() async {
        print("🎯 Switching to Files pane")
        
        // Sequence: Ctrl+Shift+E (focus explorer), then Ctrl+K, Z (Zen mode)
        await sendKeySequence([
            (0xFFE3, true),   // Ctrl down
            (0xFFE1, true),   // Shift down
            (0x0065, true),   // E down
            (0x0065, false),   // E up
            (0xFFE1, false),  // Shift up
            (0xFFE3, false),  // Ctrl up
        ])
        
        try? await Task.sleep(nanoseconds: 300_000_000) // 300ms
        
        await sendKeySequence([
            (0xFFE3, true),   // Ctrl down
            (0x006B, true),   // K down
            (0x006B, false),  // K up
            (0xFFE3, false),  // Ctrl up
        ])
        
        try? await Task.sleep(nanoseconds: 150_000_000) // 150ms
        
        await sendKeySequence([
            (0x007A, true),   // Z down
            (0x007A, false),  // Z up
        ])
        
        print("✅ Files pane activated")
    }
    
    func switchToTerminal() async {
        print("🎯 Switching to Terminal pane")
        
        // Sequence: Ctrl+` (toggle terminal), then Ctrl+K, Z (Zen mode)
        await sendKeySequence([
            (0xFFE3, true),   // Ctrl down
            (0x0060, true),   // ` down
            (0x0060, false),  // ` up
            (0xFFE3, false),  // Ctrl up
        ])
        
        try? await Task.sleep(nanoseconds: 300_000_000) // 300ms
        
        await sendKeySequence([
            (0xFFE3, true),   // Ctrl down
            (0x006B, true),   // K down
            (0x006B, false),  // K up
            (0xFFE3, false),  // Ctrl up
        ])
        
        try? await Task.sleep(nanoseconds: 150_000_000) // 150ms
        
        await sendKeySequence([
            (0x007A, true),   // Z down
            (0x007A, false),  // Z up
        ])
        
        print("✅ Terminal pane activated")
    }
    
    // MARK: - Helper
    
    private func sendKeySequence(_ keys: [(keysym: UInt32, pressed: Bool)]) async {
        for (keysym, pressed) in keys {
            vncConnection.sendKey(key: keysym, pressed: pressed)
            // Small delay between keys
            try? await Task.sleep(nanoseconds: 20_000_000) // 20ms
        }
    }
}

// MARK: - Key Codes (X11 keysyms)

extension CursorPaneController {
    // Common keysyms for reference
    // Ctrl = 0xFFE3
    // Shift = 0xFFE1
    // Alt = 0xFFE9
    // K = 0x006B
    // Z = 0x007A
    // L = 0x006C
    // E = 0x0065
    // 1 = 0x0031
    // ` = 0x0060
}


