//
//  LiquidGlassOverlay.swift
//  PsychosisApp
//
//  Liquid Glass UI overlay for pane switching
//

import SwiftUI

struct LiquidGlassOverlay: View {
    @Binding var selectedPane: CursorPane
    @State private var isVisible: Bool = true
    @State private var autoHideTask: Task<Void, Never>?
    
    let onPaneSelected: (CursorPane) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            if isVisible {
                // Top tab bar
                HStack(spacing: 12) {
                    ForEach(CursorPane.allCases, id: \.self) { pane in
                        Button(action: {
                            selectedPane = pane
                            onPaneSelected(pane)
                            resetAutoHide()
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: pane.icon)
                                    .font(.system(size: 14))
                                Text(pane.rawValue)
                                    .font(.caption)
                                    .fontWeight(.medium)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(
                                selectedPane == pane
                                    ? pane.color.opacity(0.3)
                                    : Color.white.opacity(0.1)
                            )
                            .foregroundColor(
                                selectedPane == pane
                                    ? pane.color
                                    : .white.opacity(0.8)
                            )
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(
                                        selectedPane == pane
                                            ? pane.color.opacity(0.5)
                                            : Color.white.opacity(0.2),
                                        lineWidth: selectedPane == pane ? 2 : 1
                                    )
                            )
                            .shadow(
                                color: selectedPane == pane
                                    ? pane.color.opacity(0.3)
                                    : Color.black.opacity(0.2),
                                radius: selectedPane == pane ? 8 : 4
                            )
                        }
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 12)
                .background(.ultraThinMaterial)
                .cornerRadius(16, corners: [.bottomLeft, .bottomRight])
                .transition(.move(edge: .top).combined(with: .opacity))
            }
            
            // Spacer that allows touches to pass through
            Spacer()
                .contentShape(Rectangle())
                .allowsHitTesting(false) // Allow touches to pass through to VNC view below
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle())
        .gesture(
            DragGesture(minimumDistance: 10)
                .onChanged { value in
                    if value.translation.height < -20 && !isVisible {
                        showOverlay()
                    }
                }
        )
        .onAppear {
            startAutoHide()
        }
    }
    
    private func showOverlay() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            isVisible = true
        }
        resetAutoHide()
    }
    
    private func startAutoHide() {
        resetAutoHide()
    }
    
    private func resetAutoHide() {
        autoHideTask?.cancel()
        autoHideTask = Task {
            try? await Task.sleep(nanoseconds: 5_000_000_000) // 5 seconds
            await MainActor.run {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    isVisible = false
                }
            }
        }
    }
}

