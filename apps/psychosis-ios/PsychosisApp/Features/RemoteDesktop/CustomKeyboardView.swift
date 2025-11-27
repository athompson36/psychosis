//
//  CustomKeyboardView.swift
//  PsychosisApp
//
//  Custom on-screen keyboard for VNC input
//

import SwiftUI

struct CustomKeyboardView: View {
    let connection: VNCConnection
    @Binding var isVisible: Bool
    @State private var shiftPressed: Bool = false
    @State private var capsLock: Bool = false
    
    var body: some View {
        if isVisible {
            VStack(spacing: 0) {
                // Top row with numbers
                HStack(spacing: 4) {
                    ForEach(["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"], id: \.self) { key in
                        KeyboardKey(text: key, action: { sendKey(key) })
                    }
                }
                .padding(.horizontal, 4)
                .padding(.vertical, 4)
                
                // Second row
                HStack(spacing: 4) {
                    ForEach(["Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P"], id: \.self) { key in
                        KeyboardKey(text: key, action: { sendKey(key) })
                    }
                }
                .padding(.horizontal, 4)
                .padding(.vertical, 4)
                
                // Third row
                HStack(spacing: 4) {
                    ForEach(["A", "S", "D", "F", "G", "H", "J", "K", "L"], id: \.self) { key in
                        KeyboardKey(text: key, action: { sendKey(key) })
                    }
                }
                .padding(.horizontal, 4)
                .padding(.vertical, 4)
                
                // Fourth row
                HStack(spacing: 4) {
                    // Shift key
                    Button(action: {
                        shiftPressed.toggle()
                    }) {
                        Image(systemName: shiftPressed ? "shift.fill" : "shift")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                            .frame(width: 50, height: 40)
                            .background(shiftPressed ? Color.blue : Color.gray.opacity(0.3))
                            .cornerRadius(6)
                    }
                    
                    ForEach(["Z", "X", "C", "V", "B", "N", "M"], id: \.self) { key in
                        KeyboardKey(text: key, action: { sendKey(key) })
                    }
                    
                    // Backspace
                    Button(action: {
                        sendKey("\u{8}") // Backspace
                    }) {
                        Image(systemName: "delete.left")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                            .frame(width: 50, height: 40)
                            .background(Color.gray.opacity(0.3))
                            .cornerRadius(6)
                    }
                }
                .padding(.horizontal, 4)
                .padding(.vertical, 4)
                
                // Bottom row
                HStack(spacing: 4) {
                    // Space bar
                    Button(action: {
                        sendKey(" ")
                    }) {
                        Text("Space")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, minHeight: 40)
                            .background(Color.gray.opacity(0.3))
                            .cornerRadius(6)
                    }
                    .frame(width: 150)
                    
                    // Enter
                    Button(action: {
                        sendKey("\r")
                    }) {
                        Text("Enter")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white)
                            .frame(width: 80, height: 40)
                            .background(Color.blue)
                            .cornerRadius(6)
                    }
                    
                    // Hide keyboard
                    Button(action: {
                        withAnimation {
                            isVisible = false
                        }
                    }) {
                        Image(systemName: "keyboard.chevron.compact.down")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                            .frame(width: 50, height: 40)
                            .background(Color.gray.opacity(0.3))
                            .cornerRadius(6)
                    }
                }
                .padding(.horizontal, 4)
                .padding(.vertical, 4)
            }
            .padding(.vertical, 8)
            .background(Color.black.opacity(0.9))
            .cornerRadius(12, corners: [.topLeft, .topRight])
            .transition(.move(edge: .bottom))
            .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isVisible)
        }
    }
    
    private func sendKey(_ key: String) {
        let char = shiftPressed || capsLock ? key.uppercased().first : key.lowercased().first
        guard let char = char else { return }
        
        if let keysym = charToKeysym(char) {
            print("⌨️ Custom keyboard: '\(char)' -> keysym: \(keysym)")
            connection.sendKey(key: keysym, pressed: true)
            connection.sendKey(key: keysym, pressed: false)
        }
        
        // Release shift after key press (unless caps lock)
        if shiftPressed && !capsLock {
            shiftPressed = false
        }
    }
    
    private func charToKeysym(_ char: Character) -> UInt32? {
        guard let ascii = char.asciiValue else { return nil }
        
        // Most printable ASCII characters have keysym equal to their ASCII value
        if ascii >= 0x20 && ascii <= 0x7E {
            return UInt32(ascii)
        }
        
        // Special keys
        switch char {
        case "\t": return 0xFF09  // Tab
        case "\n", "\r": return 0xFF0D  // Return
        case "\u{8}": return 0xFF08  // Backspace
        default: return nil
        }
    }
}

struct KeyboardKey: View {
    let text: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)
                .frame(width: 32, height: 40)
                .background(Color.gray.opacity(0.3))
                .cornerRadius(6)
        }
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

