//
//  NativeVNCView.swift
//  PsychosisApp
//
//  SwiftUI view for displaying native VNC connection
//

import SwiftUI
import UIKit

struct NativeVNCView: View {
    @ObservedObject var connection: VNCConnection
    @State private var scale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastScale: CGFloat = 1.0
    @State private var lastOffset: CGSize = .zero
    @State private var image: UIImage?
    @State private var initialScaleCalculated: Bool = false
    @State private var imageSize: CGSize = .zero
    @State private var showKeyboard: Bool = false
    @State private var keyboardText: String = ""
    @FocusState private var isKeyboardFocused: Bool
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if let image = image {
                    // Fill the entire screen (stretch to fit)
                    Image(uiImage: image)
                        .resizable()
                        .frame(width: geometry.size.width * scale, height: geometry.size.height * scale)
                        .offset(offset)
                        .clipped()
                        .contentShape(Rectangle())
                        .gesture(
                            SimultaneousGesture(
                                // Pinch to zoom
                                MagnificationGesture()
                                    .onChanged { value in
                                        scale = lastScale * value
                                    }
                                    .onEnded { value in
                                        lastScale = scale
                                        // Clamp scale
                                        if scale < 0.5 { scale = 0.5; lastScale = 0.5 }
                                        if scale > 3.0 { scale = 3.0; lastScale = 3.0 }
                                    },
                                // Drag to pan
                                DragGesture()
                                    .onChanged { value in
                                        offset = CGSize(
                                            width: lastOffset.width + value.translation.width,
                                            height: lastOffset.height + value.translation.height
                                        )
                                    }
                                    .onEnded { _ in
                                        lastOffset = offset
                                    }
                            )
                        )
                        .onTapGesture { location in
                            handleTap(at: location, in: geometry.size)
                        }
                        .onLongPressGesture(minimumDuration: 0.5) {
                            handleLongPress(at: offset)
                        }
                    
                    // Hidden keyboard input field
                    VNCKeyboardInput(
                        connection: connection,
                        isActive: $showKeyboard
                    )
                    .frame(width: 1, height: 1)
                    .opacity(0.01)
                    .position(x: geometry.size.width / 2, y: geometry.size.height - 50)
                } else {
                    // Loading or disconnected state
                    if connection.isConnecting {
                        VStack(spacing: 16) {
                            ProgressView()
                                .scaleEffect(1.5)
                                .tint(.white)
                            Text("Connecting...")
                                .foregroundColor(.white)
                        }
                    } else if let error = connection.errorMessage {
                        VStack(spacing: 16) {
                            Image(systemName: "exclamationmark.triangle")
                                .font(.title)
                                .foregroundColor(.red)
                            Text("Connection Error")
                                .font(.headline)
                                .foregroundColor(.white)
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                    } else {
                        VStack(spacing: 16) {
                            Image(systemName: "display")
                                .font(.system(size: 60))
                                .foregroundColor(.secondary)
                            Text("Not Connected")
                                .font(.title2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
        .onChange(of: connection.frameBufferImage) { oldImage, newImage in
            if let newImage = newImage {
                image = newImage
                imageSize = newImage.size
                
                // Calculate initial scale to fit screen on first image
                if !initialScaleCalculated {
                    calculateInitialScale(imageSize: newImage.size)
                    initialScaleCalculated = true
                }
            } else {
                image = nil
                initialScaleCalculated = false
            }
        }
        .onChange(of: connection.isConnected) { oldValue, newValue in
            print("🔌 Connection status changed: \(newValue)")
            if !newValue {
                image = nil
                initialScaleCalculated = false
            }
        }
    }
    
    // MARK: - Scaling
    
    private func calculateInitialScale(imageSize: CGSize) {
        // Don't apply additional scaling - let aspectRatio(.fit) handle it
        // Start with scale 1.0 so the image displays at its natural fit size
        scale = 1.0
        lastScale = 1.0
        offset = .zero
        lastOffset = .zero
        
        let screenSize = UIScreen.main.bounds.size
        print("📐 Image size: \(imageSize.width)x\(imageSize.height), screen: \(screenSize.width)x\(screenSize.height), initial scale: 1.0")
    }
    
    // MARK: - Image Updates
    // Image updates are handled via connection.frameBufferImage @Published property
    // No need for separate update task - VNCConnection updates frameBufferImage directly
    
    // MARK: - Input Handling
    
    private func handleTap(at location: CGPoint, in viewSize: CGSize) {
        guard let frameBuffer = connection.frameBuffer,
              let _ = image else {
            print("⚠️ Cannot handle tap - no frame buffer or image")
            return
        }
        
        Task {
            // Get VNC frame buffer size
            let vncSize = await frameBuffer.size
            
            // Calculate the displayed image size (full screen fill mode)
            let displayedWidth = viewSize.width * scale
            let displayedHeight = viewSize.height * scale
            
            // Calculate position relative to image (accounting for pan offset)
            let relativeX = location.x - offset.width
            let relativeY = location.y - offset.height
            
            // Convert to VNC coordinates
            let vncX = Int((relativeX / displayedWidth) * vncSize.width)
            let vncY = Int((relativeY / displayedHeight) * vncSize.height)
            
            // Clamp to valid VNC coordinates
            let clampedX = max(0, min(vncX, Int(vncSize.width) - 1))
            let clampedY = max(0, min(vncY, Int(vncSize.height) - 1))
            
            print("🖱️ Tap at screen (\(Int(location.x)), \(Int(location.y))) -> VNC (\(clampedX), \(clampedY))")
            
            // Send mouse click (button 1 = left click)
            connection.sendMouse(x: clampedX, y: clampedY, buttonMask: 1)
            
            // Release after short delay
            try? await Task.sleep(nanoseconds: 50_000_000) // 50ms
            connection.sendMouse(x: clampedX, y: clampedY, buttonMask: 0)
            
            // Show keyboard after tap (for text fields)
            await MainActor.run {
                showKeyboard = true
            }
        }
    }
    
    private func handleLongPress(at location: CGSize) {
        guard let frameBuffer = connection.frameBuffer else { return }
        
        // Right click (button 2) - TODO: implement proper location calculation
        Task {
            let vncSize = await frameBuffer.size
            // For now, send right click at center
            let vncX = Int(vncSize.width / 2)
            let vncY = Int(vncSize.height / 2)
            connection.sendMouse(x: vncX, y: vncY, buttonMask: 2)
            try? await Task.sleep(nanoseconds: 50_000_000)
            connection.sendMouse(x: vncX, y: vncY, buttonMask: 0)
        }
    }
}

// MARK: - VNC Keyboard Input

struct VNCKeyboardInput: UIViewRepresentable {
    let connection: VNCConnection
    @Binding var isActive: Bool
    
    func makeUIView(context: Context) -> VNCKeyboardTextField {
        let textField = VNCKeyboardTextField()
        textField.delegate = context.coordinator
        textField.connection = connection
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.spellCheckingType = .no
        textField.smartQuotesType = .no
        textField.smartDashesType = .no
        textField.smartInsertDeleteType = .no
        textField.keyboardType = .asciiCapable
        textField.returnKeyType = .default
        textField.backgroundColor = .clear
        textField.textColor = .clear
        textField.tintColor = .clear
        return textField
    }
    
    func updateUIView(_ uiView: VNCKeyboardTextField, context: Context) {
        uiView.connection = connection
        if isActive && !uiView.isFirstResponder {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                uiView.becomeFirstResponder()
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UITextFieldDelegate {
        var parent: VNCKeyboardInput
        
        init(_ parent: VNCKeyboardInput) {
            self.parent = parent
        }
        
        func textFieldDidEndEditing(_ textField: UITextField) {
            parent.isActive = false
        }
        
        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            // Handle key presses
            if let vncTextField = textField as? VNCKeyboardTextField,
               let connection = vncTextField.connection {
                
                if string.isEmpty {
                    // Backspace pressed
                    print("⌨️ Backspace pressed")
                    connection.sendKey(key: 0xFF08, pressed: true)  // XK_BackSpace
                    connection.sendKey(key: 0xFF08, pressed: false)
                } else {
                    // Regular characters
                    for char in string {
                        if let keysym = charToKeysym(char) {
                            print("⌨️ Key pressed: '\(char)' -> keysym: \(keysym)")
                            connection.sendKey(key: keysym, pressed: true)
                            connection.sendKey(key: keysym, pressed: false)
                        }
                    }
                }
            }
            
            // Don't actually insert text into the hidden field
            return false
        }
        
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            // Send Enter key
            if let vncTextField = textField as? VNCKeyboardTextField,
               let connection = vncTextField.connection {
                print("⌨️ Enter pressed")
                connection.sendKey(key: 0xFF0D, pressed: true)  // XK_Return
                connection.sendKey(key: 0xFF0D, pressed: false)
            }
            return false
        }
        
        private func charToKeysym(_ char: Character) -> UInt32? {
            // Basic ASCII to X11 keysym mapping
            guard let ascii = char.asciiValue else { return nil }
            
            // Most printable ASCII characters have keysym equal to their ASCII value
            if ascii >= 0x20 && ascii <= 0x7E {
                return UInt32(ascii)
            }
            
            // Special keys
            switch char {
            case "\t": return 0xFF09  // Tab
            case "\n", "\r": return 0xFF0D  // Return
            default: return nil
            }
        }
    }
}

class VNCKeyboardTextField: UITextField {
    weak var connection: VNCConnection?
    
    override var canBecomeFirstResponder: Bool { true }
    
    override func deleteBackward() {
        // Handle hardware keyboard backspace
        if let connection = connection {
            print("⌨️ Hardware backspace")
            connection.sendKey(key: 0xFF08, pressed: true)
            connection.sendKey(key: 0xFF08, pressed: false)
        }
        super.deleteBackward()
    }
    
    // Capture all key commands for hardware keyboard
    override var keyCommands: [UIKeyCommand]? {
        var commands: [UIKeyCommand] = []
        
        // Arrow keys
        commands.append(UIKeyCommand(input: UIKeyCommand.inputUpArrow, modifierFlags: [], action: #selector(handleArrowUp)))
        commands.append(UIKeyCommand(input: UIKeyCommand.inputDownArrow, modifierFlags: [], action: #selector(handleArrowDown)))
        commands.append(UIKeyCommand(input: UIKeyCommand.inputLeftArrow, modifierFlags: [], action: #selector(handleArrowLeft)))
        commands.append(UIKeyCommand(input: UIKeyCommand.inputRightArrow, modifierFlags: [], action: #selector(handleArrowRight)))
        
        // Escape
        commands.append(UIKeyCommand(input: UIKeyCommand.inputEscape, modifierFlags: [], action: #selector(handleEscape)))
        
        return commands
    }
    
    @objc func handleArrowUp() {
        connection?.sendKey(key: 0xFF52, pressed: true)  // XK_Up
        connection?.sendKey(key: 0xFF52, pressed: false)
    }
    
    @objc func handleArrowDown() {
        connection?.sendKey(key: 0xFF54, pressed: true)  // XK_Down
        connection?.sendKey(key: 0xFF54, pressed: false)
    }
    
    @objc func handleArrowLeft() {
        connection?.sendKey(key: 0xFF51, pressed: true)  // XK_Left
        connection?.sendKey(key: 0xFF51, pressed: false)
    }
    
    @objc func handleArrowRight() {
        connection?.sendKey(key: 0xFF53, pressed: true)  // XK_Right
        connection?.sendKey(key: 0xFF53, pressed: false)
    }
    
    @objc func handleEscape() {
        connection?.sendKey(key: 0xFF1B, pressed: true)  // XK_Escape
        connection?.sendKey(key: 0xFF1B, pressed: false)
        resignFirstResponder()
    }
}

