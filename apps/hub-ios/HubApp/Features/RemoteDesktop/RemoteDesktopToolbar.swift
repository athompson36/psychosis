//
//  RemoteDesktopToolbar.swift
//  HubApp
//
//  Created on [Current Date]
//

import SwiftUI

public struct RemoteDesktopToolbar: View {
    @Binding var isConnected: Bool
    let onRefresh: () -> Void
    let onFullscreen: () -> Void
    let onScreenshot: () -> Void
    let onKeyboard: () -> Void
    let onDisconnect: () -> Void
    
    @State private var showFullscreen: Bool = false
    
    public init(
        isConnected: Binding<Bool>,
        onRefresh: @escaping () -> Void,
        onFullscreen: @escaping () -> Void,
        onScreenshot: @escaping () -> Void,
        onKeyboard: @escaping () -> Void,
        onDisconnect: @escaping () -> Void
    ) {
        self._isConnected = isConnected
        self.onRefresh = onRefresh
        self.onFullscreen = onFullscreen
        self.onScreenshot = onScreenshot
        self.onKeyboard = onKeyboard
        self.onDisconnect = onDisconnect
    }
    
    public var body: some View {
        HStack(spacing: 16) {
            // Refresh
            Button(action: onRefresh) {
                Image(systemName: "arrow.clockwise")
                    .font(.title3)
            }
            .disabled(!isConnected)
            
            // Keyboard Toggle
            Button(action: onKeyboard) {
                Image(systemName: "keyboard")
                    .font(.title3)
            }
            .disabled(!isConnected)
            
            // Screenshot
            Button(action: onScreenshot) {
                Image(systemName: "camera.fill")
                    .font(.title3)
            }
            .disabled(!isConnected)
            
            // Fullscreen Toggle
            Button(action: {
                showFullscreen.toggle()
                onFullscreen()
            }) {
                Image(systemName: showFullscreen ? "arrow.down.right.and.arrow.up.left" : "arrow.up.left.and.arrow.down.right")
                    .font(.title3)
            }
            .disabled(!isConnected)
            
            Spacer()
            
            // Disconnect
            if isConnected {
                Button(action: onDisconnect) {
                    HStack(spacing: 4) {
                        Image(systemName: "xmark.circle.fill")
                        Text("Disconnect")
                            .font(.caption)
                    }
                    .foregroundColor(.red)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial)
        .cornerRadius(8)
    }
}

#Preview {
    RemoteDesktopToolbar(
        isConnected: .constant(true),
        onRefresh: {},
        onFullscreen: {},
        onScreenshot: {},
        onKeyboard: {},
        onDisconnect: {}
    )
    .padding()
    .background(Color.black)
}

