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
    @StateObject private var keyboardController = KeyboardController()
    @State private var lastTapTime: Date = .distantPast
    @State private var isDragging: Bool = false
    @State private var keyboardHeight: CGFloat = 0
    
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
                        .highPriorityGesture(
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
                                }
                        )
                        .gesture(
                            // Drag to pan (with tap detection)
                            DragGesture(minimumDistance: 5)
                                .onChanged { value in
                                    isDragging = true
                                    offset = CGSize(
                                        width: lastOffset.width + value.translation.width,
                                        height: lastOffset.height + value.translation.height
                                    )
                                }
                                .onEnded { _ in
                                    isDragging = false
                                    lastOffset = offset
                                }
                        )
                        .simultaneousGesture(
                            // Tap gesture - use TapGesture for more reliable detection
                            TapGesture()
                                .onEnded {
                                    // Only handle if we weren't dragging
                                    if !isDragging {
                                        // Get tap location from screen center (approximate)
                                        // Use a better approach with gesture location
                                    }
                                }
                        )
                        .overlay(
                            // Invisible tap detector that doesn't conflict with gestures
                            TapDetectorView(
                                onTap: { location in
                                    handleTap(at: location, in: geometry.size)
                                },
                                onDoubleTap: { location in
                                    handleDoubleTap(at: location, in: geometry.size)
                                }
                            )
                        )
                    
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
                
                // Keyboard input bar - visible at bottom when keyboard is active
                if connection.isConnected {
                    VStack {
                        Spacer()
                        
                        // Custom keyboard view
                        CustomKeyboardView(
                            connection: connection,
                            isVisible: Binding(
                                get: { keyboardController.isKeyboardVisible },
                                set: { keyboardController.setKeyboardVisible($0) }
                            )
                        )
                        .padding(.bottom, keyboardHeight > 0 ? keyboardHeight : 0)
                        
                        // Keyboard toggle button
                        HStack {
                            Spacer()
                            Button(action: {
                                print("⌨️ Keyboard button tapped")
                                withAnimation {
                                    keyboardController.toggleKeyboard()
                                }
                            }) {
                                Image(systemName: keyboardController.isKeyboardVisible ? "keyboard.chevron.compact.down" : "keyboard")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                    .padding(12)
                                    .background(Color.black.opacity(0.6))
                                    .clipShape(Circle())
                            }
                            .padding(.trailing, 16)
                            .padding(.bottom, keyboardController.isKeyboardVisible ? 280 : 16) // Adjust when keyboard is visible
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
        .animation(.easeOut(duration: 0.25), value: keyboardHeight)
        // No longer need iOS keyboard notifications - using custom keyboard
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
        scale = 1.0
        lastScale = 1.0
        offset = .zero
        lastOffset = .zero
        
        let screenSize = UIScreen.main.bounds.size
        print("📐 Image size: \(imageSize.width)x\(imageSize.height), screen: \(screenSize.width)x\(screenSize.height), initial scale: 1.0")
    }
    
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
            
            // Always show keyboard after any tap on VNC screen
            print("🖱️ Showing keyboard after tap")
            await MainActor.run {
                keyboardController.showKeyboard()
            }
        }
    }
    
    private func handleDoubleTap(at location: CGPoint, in viewSize: CGSize) {
        guard let frameBuffer = connection.frameBuffer else { return }
        
        Task {
            let vncSize = await frameBuffer.size
            let displayedWidth = viewSize.width * scale
            let displayedHeight = viewSize.height * scale
            let relativeX = location.x - offset.width
            let relativeY = location.y - offset.height
            let vncX = max(0, min(Int((relativeX / displayedWidth) * vncSize.width), Int(vncSize.width) - 1))
            let vncY = max(0, min(Int((relativeY / displayedHeight) * vncSize.height), Int(vncSize.height) - 1))
            
            print("🖱️ Double-tap at VNC (\(vncX), \(vncY))")
            
            // Send double-click
            for _ in 0..<2 {
                connection.sendMouse(x: vncX, y: vncY, buttonMask: 1)
                try? await Task.sleep(nanoseconds: 30_000_000)
                connection.sendMouse(x: vncX, y: vncY, buttonMask: 0)
                try? await Task.sleep(nanoseconds: 30_000_000)
            }
        }
    }
}

// MARK: - Tap Detector View

struct TapDetectorView: UIViewRepresentable {
    let onTap: (CGPoint) -> Void
    let onDoubleTap: (CGPoint) -> Void
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        
        let singleTap = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleSingleTap(_:)))
        singleTap.numberOfTapsRequired = 1
        
        let doubleTap = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleDoubleTap(_:)))
        doubleTap.numberOfTapsRequired = 2
        
        // Single tap should wait for double tap to fail
        singleTap.require(toFail: doubleTap)
        
        view.addGestureRecognizer(singleTap)
        view.addGestureRecognizer(doubleTap)
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onTap: onTap, onDoubleTap: onDoubleTap)
    }
    
    class Coordinator: NSObject {
        let onTap: (CGPoint) -> Void
        let onDoubleTap: (CGPoint) -> Void
        
        init(onTap: @escaping (CGPoint) -> Void, onDoubleTap: @escaping (CGPoint) -> Void) {
            self.onTap = onTap
            self.onDoubleTap = onDoubleTap
        }
        
        @objc func handleSingleTap(_ gesture: UITapGestureRecognizer) {
            let location = gesture.location(in: gesture.view)
            onTap(location)
        }
        
        @objc func handleDoubleTap(_ gesture: UITapGestureRecognizer) {
            let location = gesture.location(in: gesture.view)
            onDoubleTap(location)
        }
    }
}

// MARK: - Keyboard Controller

class KeyboardController: ObservableObject {
    // Use non-published property to avoid AttributeGraph cycles
    private var _isKeyboardVisible: Bool = false {
        didSet {
            // Only update if changed and use objectWillChange to avoid cycles
            if oldValue != _isKeyboardVisible {
                DispatchQueue.main.async { [weak self] in
                    self?.objectWillChange.send()
                }
            }
        }
    }
    
    var isKeyboardVisible: Bool {
        get { _isKeyboardVisible }
        set { _isKeyboardVisible = newValue }
    }
    
    // Use a flag instead of @Published to avoid cycles
    var shouldShowKeyboard: Bool = false {
        didSet {
            if oldValue != shouldShowKeyboard {
                DispatchQueue.main.async { [weak self] in
                    self?.objectWillChange.send()
                }
            }
        }
    }
    
    private weak var textField: UITextField?
    private weak var textView: UITextView?
    
    func register(_ input: Any) {
        if let tf = input as? UITextField {
            print("⌨️ KeyboardController: registered text field, window: \(tf.window != nil)")
            self.textField = tf
        } else if let tv = input as? UITextView {
            print("⌨️ KeyboardController: registered text view, window: \(tv.window != nil)")
            self.textView = tv
        }
    }
    
    func showKeyboard() {
        print("⌨️ showKeyboard called, textField: \(textField != nil), textView: \(textView != nil)")
        
        // Set flag without triggering @Published
        shouldShowKeyboard = true
        
        // Try multiple times with delays to ensure it works
        func attemptBecomeFirstResponder(attempt: Int) {
            // Try text view first
            if let tv = textView, tv.window != nil {
                DispatchQueue.main.async {
                    let success = tv.becomeFirstResponder()
                    print("⌨️ textView becomeFirstResponder attempt \(attempt) result: \(success)")
                    if success {
                        // Update without triggering cycle
                        self._isKeyboardVisible = true
                        return
                    }
                }
            }
            
            // Fall back to text field
            guard let tf = textField else {
                print("⚠️ No text field or text view registered!")
                if attempt < 5 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        attemptBecomeFirstResponder(attempt: attempt + 1)
                    }
                }
                return
            }
            
            DispatchQueue.main.async {
                if tf.window == nil {
                    print("⚠️ Text field not in window yet, attempt \(attempt)")
                    if attempt < 5 {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            attemptBecomeFirstResponder(attempt: attempt + 1)
                        }
                    }
                    return
                }
                
                let success = tf.becomeFirstResponder()
                print("⌨️ textField becomeFirstResponder attempt \(attempt) result: \(success)")
                
                if success {
                    // Update without triggering cycle
                    self._isKeyboardVisible = true
                } else if attempt < 3 {
                    // Try again after a short delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        attemptBecomeFirstResponder(attempt: attempt + 1)
                    }
                } else {
                    print("⚠️ Failed to become first responder after \(attempt) attempts")
                }
            }
        }
        
        attemptBecomeFirstResponder(attempt: 1)
    }
    
    func hideKeyboard() {
        print("⌨️ hideKeyboard called")
        shouldShowKeyboard = false
        _isKeyboardVisible = false
        textView?.resignFirstResponder()
        textField?.resignFirstResponder()
    }
    
    func toggleKeyboard() {
        print("⌨️ toggleKeyboard called, current state: \(_isKeyboardVisible)")
        if _isKeyboardVisible {
            hideKeyboard()
        } else {
            showKeyboard()
        }
    }
    
    // Safe method to update keyboard state without triggering cycles
    func setKeyboardVisible(_ visible: Bool) {
        if _isKeyboardVisible != visible {
            _isKeyboardVisible = visible
        }
    }
}

// MARK: - VNC Keyboard Input View

struct VNCKeyboardInputView: UIViewRepresentable {
    let connection: VNCConnection
    @ObservedObject var controller: KeyboardController
    
    func makeUIView(context: Context) -> VNCKeyboardTextField {
        let textField = VNCKeyboardTextField()
        textField.delegate = context.coordinator
        textField.connection = connection
        textField.keyboardController = controller
        
        // Configure for invisible but functional input
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.spellCheckingType = .no
        textField.smartQuotesType = .no
        textField.smartDashesType = .no
        textField.smartInsertDeleteType = .no
        textField.keyboardType = .asciiCapable
        textField.returnKeyType = .default
        
        // Make invisible but still functional
        textField.alpha = 0.02 // Nearly invisible but not zero
        textField.backgroundColor = UIColor.clear
        textField.textColor = UIColor.clear
        textField.tintColor = UIColor.clear
        
        // Ensure it can become first responder
        textField.isUserInteractionEnabled = true
        textField.isEnabled = true
        
        // Set placeholder to help with input system
        textField.placeholder = " "
        textField.text = " " // Keep some text so input system stays active
        
        // Register with controller
        controller.register(textField)
        print("⌨️ VNCKeyboardTextField created and registered")
        
        return textField
    }
    
    func updateUIView(_ uiView: VNCKeyboardTextField, context: Context) {
        uiView.connection = connection
        uiView.keyboardController = controller
        
        // Re-register in case view was recreated
        controller.register(uiView)
        
        // Respond to shouldShowKeyboard
        if controller.shouldShowKeyboard && !uiView.isFirstResponder {
            // Use async to ensure we're not in a layout pass
            DispatchQueue.main.async {
                if uiView.window != nil {
                    let success = uiView.becomeFirstResponder()
                    print("⌨️ updateUIView becomeFirstResponder: \(success), window: \(uiView.window != nil)")
                } else {
                    print("⌨️ updateUIView: text field not in window yet")
                }
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(connection: connection, controller: controller)
    }
    
    class Coordinator: NSObject, UITextFieldDelegate {
        let connection: VNCConnection
        let controller: KeyboardController
        
        init(connection: VNCConnection, controller: KeyboardController) {
            self.connection = connection
            self.controller = controller
        }
        
        func textFieldDidEndEditing(_ textField: UITextField) {
            DispatchQueue.main.async {
                self.controller.setKeyboardVisible(false)
                self.controller.shouldShowKeyboard = false
            }
        }
        
        func textFieldDidBeginEditing(_ textField: UITextField) {
            DispatchQueue.main.async {
                self.controller.setKeyboardVisible(true)
            }
        }
        
        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            // Send keys to VNC
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
            
            // Allow text to update in field for visual feedback and input session
            return true
        }
        
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            // Send Enter key
            print("⌨️ Enter pressed")
            connection.sendKey(key: 0xFF0D, pressed: true)  // XK_Return
            connection.sendKey(key: 0xFF0D, pressed: false)
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
    weak var keyboardController: KeyboardController?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupTextField()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupTextField()
    }
    
    private func setupTextField() {
        // Text field will be configured by the view controller
        self.borderStyle = .none
        self.backgroundColor = .clear
    }
    
    override var canBecomeFirstResponder: Bool { 
        let result = super.canBecomeFirstResponder
        print("⌨️ canBecomeFirstResponder called, returning \(result), window: \(window != nil)")
        return result
    }
    
    override var canResignFirstResponder: Bool { 
        return super.canResignFirstResponder
    }
    
    @discardableResult
    override func becomeFirstResponder() -> Bool {
        print("⌨️ VNCKeyboardTextField.becomeFirstResponder() called, window: \(window != nil), superview: \(superview != nil)")
        
        // Ensure we have text for input session
        if text?.isEmpty != false {
            text = " "
        }
        
        let result = super.becomeFirstResponder()
        print("⌨️ VNCKeyboardTextField.becomeFirstResponder() = \(result), isFirstResponder: \(isFirstResponder)")
        
        if result {
            DispatchQueue.main.async {
                self.keyboardController?.setKeyboardVisible(true)
            }
        } else {
            // Try again after a delay
            let workItem = DispatchWorkItem {
                if self.window != nil {
                    let retry = super.becomeFirstResponder()
                    print("⌨️ Retry becomeFirstResponder: \(retry)")
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: workItem)
        }
        return result
    }
    
    @discardableResult
    override func resignFirstResponder() -> Bool {
        let result = super.resignFirstResponder()
        print("⌨️ VNCKeyboardTextField.resignFirstResponder() = \(result)")
        if result {
            DispatchQueue.main.async {
                self.keyboardController?.setKeyboardVisible(false)
                self.keyboardController?.shouldShowKeyboard = false
            }
        }
        return result
    }
    
    override func deleteBackward() {
        // Handle backspace - send to VNC
        if let connection = connection {
            print("⌨️ Backspace")
            connection.sendKey(key: 0xFF08, pressed: true)
            connection.sendKey(key: 0xFF08, pressed: false)
        }
        // Allow normal text deletion for visual feedback
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

// MARK: - Simple Keyboard Text Field View

struct VNCKeyboardTextFieldView: UIViewRepresentable {
    let connection: VNCConnection
    @ObservedObject var controller: KeyboardController
    
    func makeUIView(context: Context) -> VNCKeyboardTextField {
        print("⌨️ VNCKeyboardTextFieldView makeUIView")
        let textField = VNCKeyboardTextField()
        textField.delegate = context.coordinator
        textField.connection = connection
        textField.keyboardController = controller
        
        // Configure for visible, functional input
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.spellCheckingType = .no
        textField.smartQuotesType = .no
        textField.smartDashesType = .no
        textField.smartInsertDeleteType = .no
        textField.keyboardType = .default
        textField.returnKeyType = .default
        textField.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        textField.textColor = UIColor.white
        textField.tintColor = UIColor.white
        textField.placeholder = "VNC Input"
        textField.text = ""
        textField.borderStyle = .roundedRect
        textField.layer.cornerRadius = 8
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.white.withAlphaComponent(0.5).cgColor
        textField.font = UIFont.systemFont(ofSize: 16)
        
        // Register with controller
        controller.register(textField)
        
        return textField
    }
    
    func updateUIView(_ uiView: VNCKeyboardTextField, context: Context) {
        uiView.connection = connection
        uiView.keyboardController = controller
        controller.register(uiView)
        
        // Become first responder when requested
        if controller.shouldShowKeyboard && !uiView.isFirstResponder {
            print("⌨️ updateUIView: attempting to show keyboard, window: \(uiView.window != nil)")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                if uiView.window != nil {
                    let success = uiView.becomeFirstResponder()
                    print("⌨️ updateUIView becomeFirstResponder: \(success)")
                } else {
                    print("⚠️ updateUIView: text field not in window")
                }
            }
        } else if !controller.shouldShowKeyboard && uiView.isFirstResponder {
            uiView.resignFirstResponder()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(connection: connection, controller: controller)
    }
    
    class Coordinator: NSObject, UITextFieldDelegate {
        let connection: VNCConnection
        let controller: KeyboardController
        
        init(connection: VNCConnection, controller: KeyboardController) {
            self.connection = connection
            self.controller = controller
        }
        
        func textFieldDidEndEditing(_ textField: UITextField) {
            DispatchQueue.main.async {
                self.controller.setKeyboardVisible(false)
                self.controller.shouldShowKeyboard = false
            }
        }
        
        func textFieldDidBeginEditing(_ textField: UITextField) {
            DispatchQueue.main.async {
                self.controller.setKeyboardVisible(true)
            }
        }
        
        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            if string.isEmpty {
                print("⌨️ Backspace pressed")
                connection.sendKey(key: 0xFF08, pressed: true)
                connection.sendKey(key: 0xFF08, pressed: false)
            } else {
                for char in string {
                    if let keysym = charToKeysym(char) {
                        print("⌨️ Key pressed: '\(char)' -> keysym: \(keysym)")
                        connection.sendKey(key: keysym, pressed: true)
                        connection.sendKey(key: keysym, pressed: false)
                    }
                }
            }
            return true // Allow text to update
        }
        
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            print("⌨️ Enter pressed")
            connection.sendKey(key: 0xFF0D, pressed: true)
            connection.sendKey(key: 0xFF0D, pressed: false)
            return false
        }
        
        private func charToKeysym(_ char: Character) -> UInt32? {
            guard let ascii = char.asciiValue else { return nil }
            if ascii >= 0x20 && ascii <= 0x7E {
                return UInt32(ascii)
            }
            switch char {
            case "\t": return 0xFF09
            case "\n", "\r": return 0xFF0D
            default: return nil
            }
        }
    }
}

// MARK: - OLD Keyboard Input View Controller Wrapper (keeping for reference but not used)

struct KeyboardInputViewControllerWrapper_OLD: UIViewControllerRepresentable {
    let connection: VNCConnection
    @ObservedObject var controller: KeyboardController
    
    func makeUIViewController(context: Context) -> KeyboardInputViewController {
        print("⌨️ KeyboardInputViewControllerWrapper makeUIViewController")
        let vc = KeyboardInputViewController()
        vc.connection = connection
        vc.controller = controller
        return vc
    }
    
    func updateUIViewController(_ uiViewController: KeyboardInputViewController, context: Context) {
        uiViewController.connection = connection
        uiViewController.controller = controller
        
        // Re-register text field
        controller.register(uiViewController.textField)
        
        // Respond to shouldShowKeyboard - try text view first
        if controller.shouldShowKeyboard {
            print("⌨️ updateUIViewController: attempting to show keyboard")
            let workItem = DispatchWorkItem {
                // Try text view first
                if let tv = uiViewController.textView, tv.window != nil, !tv.isFirstResponder {
                    let success = tv.becomeFirstResponder()
                    print("⌨️ updateUIViewController textView becomeFirstResponder: \(success)")
                    if success { return }
                }
                
                // Fall back to text field
                if uiViewController.textField.window != nil && !uiViewController.textField.isFirstResponder {
                    let success = uiViewController.textField.becomeFirstResponder()
                    print("⌨️ updateUIViewController textField becomeFirstResponder: \(success), window: \(uiViewController.textField.window != nil)")
                } else {
                    print("⚠️ updateUIViewController: text field not in window yet")
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: workItem)
        } else {
            // Hide keyboard
            uiViewController.textView?.resignFirstResponder()
            if uiViewController.textField.isFirstResponder {
                uiViewController.textField.resignFirstResponder()
            }
        }
    }
}

class KeyboardInputViewController: UIViewController {
    var connection: VNCConnection?
    var controller: KeyboardController?
    let textField = VNCKeyboardTextField()
    var textView: UITextView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        
        print("⌨️ KeyboardInputViewController viewDidLoad START")
        
        // Configure text field - make it VISIBLE and functional
        textField.delegate = self
        textField.connection = connection
        textField.keyboardController = controller
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.spellCheckingType = .no
        textField.smartQuotesType = .no
        textField.smartDashesType = .no
        textField.smartInsertDeleteType = .no
        textField.keyboardType = .default
        textField.returnKeyType = .send
        
        // Make it VISIBLE and styled
        textField.backgroundColor = UIColor.systemGray6
        textField.textColor = UIColor.label
        textField.tintColor = UIColor.systemBlue
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.placeholder = "Type to send to remote desktop..."
        textField.text = ""
        textField.borderStyle = .roundedRect
        textField.clearButtonMode = .whileEditing
        textField.isUserInteractionEnabled = true
        textField.isEnabled = true
        textField.isHidden = false
        
        // Add a label to show context
        let label = UILabel()
        label.text = "Remote Input"
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = UIColor.secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        
        // Position text field with proper layout
        textField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(textField)
        
        NSLayoutConstraint.activate([
            // Label at top
            label.topAnchor.constraint(equalTo: view.topAnchor, constant: 4),
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            
            // Text field below label
            textField.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 2),
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            textField.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -4),
            textField.heightAnchor.constraint(equalToConstant: 36)
        ])
        
        // Register with controller
        controller?.register(textField)
        print("⌨️ KeyboardInputViewController viewDidLoad COMPLETE, textField: \(textField)")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("⌨️ KeyboardInputViewController viewDidAppear, window: \(view.window != nil), textField.window: \(textField.window != nil)")
        
        // Update references
        textField.connection = connection
        textField.keyboardController = controller
        controller?.register(textField)
        
        // Automatically focus text field to show keyboard
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if self.textField.window != nil {
                let success = self.textField.becomeFirstResponder()
                print("⌨️ viewDidAppear auto-focus textField: \(success)")
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("⌨️ KeyboardInputViewController viewWillAppear")
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
}

extension KeyboardInputViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        DispatchQueue.main.async {
            self.controller?.isKeyboardVisible = false
            self.controller?.shouldShowKeyboard = false
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        DispatchQueue.main.async {
            self.controller?.isKeyboardVisible = true
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let vncTextField = textField as? VNCKeyboardTextField,
              let connection = vncTextField.connection else {
            return false
        }
        
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
        
        // Allow text to show in field for visual feedback
        // Clear it after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if let text = textField.text, text.count > 20 {
                // Keep field clean - clear if it gets too long
                textField.text = ""
            }
        }
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let vncTextField = textField as? VNCKeyboardTextField,
              let connection = vncTextField.connection else {
            return false
        }
        
        print("⌨️ Enter pressed")
        connection.sendKey(key: 0xFF0D, pressed: true)  // XK_Return
        connection.sendKey(key: 0xFF0D, pressed: false)
        return false
    }
}

extension KeyboardInputViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        DispatchQueue.main.async {
            self.controller?.setKeyboardVisible(true)
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        DispatchQueue.main.async {
            self.controller?.setKeyboardVisible(false)
            self.controller?.shouldShowKeyboard = false
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard let connection = connection else { return false }
        
        if text.isEmpty {
            // Backspace
            print("⌨️ Backspace pressed (from text view)")
            connection.sendKey(key: 0xFF08, pressed: true)
            connection.sendKey(key: 0xFF08, pressed: false)
        } else if text == "\n" {
            // Enter
            print("⌨️ Enter pressed (from text view)")
            connection.sendKey(key: 0xFF0D, pressed: true)
            connection.sendKey(key: 0xFF0D, pressed: false)
        } else {
            // Regular characters
            for char in text {
                if let keysym = charToKeysym(char) {
                    print("⌨️ Key pressed: '\(char)' -> keysym: \(keysym) (from text view)")
                    connection.sendKey(key: keysym, pressed: true)
                    connection.sendKey(key: keysym, pressed: false)
                }
            }
        }
        
        // Keep dummy text
        if textView.text.isEmpty {
            textView.text = " "
        }
        return false
    }
}

// MARK: - KeyboardInputViewController Helper Methods

private extension KeyboardInputViewController {
    func charToKeysym(_ char: Character) -> UInt32? {
        guard let ascii = char.asciiValue else { return nil }
        
        if ascii >= 0x20 && ascii <= 0x7E {
            return UInt32(ascii)
        }
        
        switch char {
        case "\t": return 0xFF09  // Tab
        case "\n", "\r": return 0xFF0D  // Return
        default: return nil
        }
    }
}

