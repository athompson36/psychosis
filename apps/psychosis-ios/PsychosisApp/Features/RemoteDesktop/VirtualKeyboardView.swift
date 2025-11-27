//
//  VirtualKeyboardView.swift
//  PsychosisApp
//
//  Created on [Current Date]
//

import SwiftUI

struct VirtualKeyboardView: View {
    @Binding var isVisible: Bool
    @Binding var textInput: String
    let onSend: (String) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            if isVisible {
                VStack(spacing: 8) {
                    // Text Input
                    HStack(spacing: 8) {
                        TextField("Type text to send to remote desktop...", text: $textInput, axis: .vertical)
                            .textFieldStyle(.roundedBorder)
                            .lineLimit(1...3)
                            .onSubmit {
                                sendText()
                            }
                        
                        Button(action: sendText) {
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.title2)
                                .foregroundColor(textInput.isEmpty ? .gray : .blue)
                        }
                        .disabled(textInput.isEmpty)
                    }
                    
                    // Quick Keys Row
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            QuickKeyButton(title: "Ctrl+C", action: { sendKey("Ctrl+C") })
                            QuickKeyButton(title: "Ctrl+V", action: { sendKey("Ctrl+V") })
                            QuickKeyButton(title: "Ctrl+Z", action: { sendKey("Ctrl+Z") })
                            QuickKeyButton(title: "Ctrl+S", action: { sendKey("Ctrl+S") })
                            QuickKeyButton(title: "Esc", action: { sendKey("Esc") })
                            QuickKeyButton(title: "Tab", action: { sendKey("Tab") })
                            QuickKeyButton(title: "Enter", action: { sendKey("Enter") })
                        }
                        .padding(.horizontal, 4)
                    }
                }
                .padding()
                .background(.ultraThinMaterial)
                .transition(.move(edge: .bottom))
            }
        }
        .animation(.easeInOut, value: isVisible)
    }
    
    private func sendText() {
        guard !textInput.isEmpty else { return }
        onSend(textInput)
        textInput = ""
    }
    
    private func sendKey(_ key: String) {
        onSend(key)
    }
}

struct QuickKeyButton: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.blue.opacity(0.2))
                .foregroundColor(.blue)
                .cornerRadius(6)
        }
    }
}

#Preview {
    VirtualKeyboardView(
        isVisible: .constant(true),
        textInput: .constant(""),
        onSend: { text in
            print("Send: \(text)")
        }
    )
    .background(Color.black)
}

