# Native VNC Client Implementation Plan

## Overview

Replace WKWebView + noVNC with a native VNC client using direct RFB protocol.

---

## VNC Client Options for iOS

### Option 1: SwiftVNC (Recommended - Start Here)
- Pure Swift implementation
- RFB protocol implementation
- No C dependencies
- Full control

### Option 2: libvncclient via Swift Package
- C library, bridge to Swift
- Well-tested, mature
- May need custom bridging

### Option 3: Custom RFB Implementation
- Implement RFB protocol from scratch
- Full control, more work
- Good learning experience

**Recommendation: Start with Option 1 (SwiftVNC) or implement minimal RFB client**

---

## Implementation Steps

### Phase 1: Basic VNC Connection

```swift
// VNCConnection.swift
class VNCConnection {
    private var socket: URLSessionStreamTask?
    private var host: String
    private var port: Int
    private var password: String
    
    func connect() async throws {
        // 1. Open TCP socket to host:port
        // 2. Read RFB protocol version
        // 3. Send security type (VNC Auth)
        // 4. Receive challenge
        // 5. Encrypt password with challenge
        // 6. Send encrypted response
        // 7. Receive security result
        // 8. Read server init
        // 9. Send client init
    }
    
    func disconnect() {
        socket?.closeRead()
        socket?.closeWrite()
    }
}
```

### Phase 2: Frame Buffer Updates

```swift
// VNCFrameBuffer.swift
class VNCFrameBuffer {
    private var pixelData: [UInt8]
    private var width: Int
    private var height: Int
    
    func update(rect: CGRect, data: Data) {
        // Update pixel data for rectangle
    }
    
    func toImage() -> UIImage {
        // Convert pixel data to UIImage
    }
}
```

### Phase 3: Input Handling

```swift
// VNCInput.swift
extension VNCConnection {
    func sendKey(key: UInt32, pressed: Bool) {
        // Send KeyEvent message
    }
    
    func sendMouse(x: Int, y: Int, button: Int) {
        // Send PointerEvent message
    }
}
```

### Phase 4: Cursor Pane Automation

```swift
// CursorPaneController.swift
class CursorPaneController {
    private let vnc: VNCConnection
    
    func switchToEditor() {
        // Send: Ctrl+K, Z, Ctrl+1
        vnc.sendKeySequence([
            (0xFFE3, true),  // Ctrl down
            (0x006B, true),  // K down
            (0x006B, false), // K up
            (0xFFE3, false), // Ctrl up
            (0x007A, true),  // Z down
            (0x007A, false), // Z up
            (0xFFE3, true),  // Ctrl down
            (0x0031, true),  // 1 down
            (0x0031, false), // 1 up
            (0xFFE3, false)  // Ctrl up
        ])
    }
    
    func switchToChat() {
        // Send: Ctrl+K, Z, Ctrl+L
    }
    
    func switchToFiles() {
        // Send: Ctrl+Shift+E, Ctrl+K, Z
    }
    
    func switchToTerminal() {
        // Send: Ctrl+`, Ctrl+K, Z
    }
}
```

---

## RFB Protocol Implementation

### RFB Protocol Messages

#### 1. Protocol Version
```
RFB 003.008\n
```

#### 2. Security Handshake
```
Server: [1 byte: number of security types]
        [N bytes: security types]
Client: [1 byte: selected security type]
```

#### 3. VNC Authentication
```
Server: [16 bytes: challenge]
Client: [16 bytes: DES-encrypted password]
Server: [4 bytes: result (0 = OK)]
```

#### 4. Client Init
```
Client: [1 byte: shared flag]
```

#### 5. Server Init
```
Server: [2 bytes: framebuffer width]
        [2 bytes: framebuffer height]
        [16 bytes: pixel format]
        [4 bytes: name length]
        [N bytes: name]
```

#### 6. Set Pixel Format
```
Client: [1 byte: message type (0)]
        [3 bytes: padding]
        [16 bytes: pixel format]
```

#### 7. Framebuffer Update Request
```
Client: [1 byte: message type (3)]
        [1 byte: incremental (0 or 1)]
        [2 bytes: x]
        [2 bytes: y]
        [2 bytes: width]
        [2 bytes: height]
```

#### 8. Framebuffer Update
```
Server: [1 byte: message type (0)]
        [1 byte: padding]
        [2 bytes: number of rectangles]
        For each rectangle:
          [2 bytes: x]
          [2 bytes: y]
          [2 bytes: width]
          [2 bytes: height]
          [4 bytes: encoding type]
          [N bytes: pixel data]
```

#### 9. Key Event
```
Client: [1 byte: message type (4)]
        [1 byte: down flag (0 or 1)]
        [2 bytes: padding]
        [4 bytes: key]
```

#### 10. Pointer Event
```
Client: [1 byte: message type (5)]
        [1 byte: button mask]
        [2 bytes: x]
        [2 bytes: y]
```

---

## Swift Implementation Structure

```
PsychosisApp/
├── Core/
│   ├── VNC/
│   │   ├── VNCConnection.swift      # Main connection class
│   │   ├── RFBProtocol.swift       # RFB protocol messages
│   │   ├── VNCFrameBuffer.swift    # Frame buffer management
│   │   ├── VNCInput.swift          # Keyboard/mouse input
│   │   └── VNCAuthentication.swift # VNC auth handling
│   └── Services/
│       └── CursorPaneController.swift # Cursor automation
├── Features/
│   └── RemoteDesktop/
│       ├── NativeVNCView.swift     # SwiftUI view
│       └── LiquidGlassOverlay.swift # UI overlay
```

---

## Key Implementation Details

### 1. TCP Socket Connection

```swift
import Network

class VNCConnection {
    private var connection: NWConnection?
    
    func connect(host: String, port: Int) async throws {
        let host = NWEndpoint.Host(host)
        let port = NWEndpoint.Port(integerLiteral: UInt16(port))
        let endpoint = NWEndpoint.hostPort(host: host, port: port)
        
        connection = NWConnection(host: host, port: port, using: .tcp)
        
        connection?.stateUpdateHandler = { state in
            switch state {
            case .ready:
                print("✅ VNC connection ready")
            case .failed(let error):
                print("❌ VNC connection failed: \(error)")
            default:
                break
            }
        }
        
        connection?.start(queue: .global())
    }
}
```

### 2. RFB Protocol Reading

```swift
func readRFBMessage() async throws -> Data {
    return try await withCheckedThrowingContinuation { continuation in
        connection?.receive(minimumIncompleteLength: 1, maximumLength: 65536) { data, context, isComplete, error in
            if let error = error {
                continuation.resume(throwing: error)
            } else if let data = data {
                continuation.resume(returning: data)
            }
        }
    }
}
```

### 3. DES Encryption for VNC Auth

```swift
import CommonCrypto

func encryptVNCPassword(password: String, challenge: Data) -> Data {
    // VNC uses DES with password padded/reversed
    // Implementation needed
}
```

### 4. Frame Buffer to UIImage

```swift
func frameBufferToImage() -> UIImage? {
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.noneSkipFirst.rawValue)
    
    guard let context = CGContext(
        data: pixelData,
        width: width,
        height: height,
        bitsPerComponent: 8,
        bytesPerRow: width * 4,
        space: colorSpace,
        bitmapInfo: bitmapInfo.rawValue
    ) else { return nil }
    
    guard let cgImage = context.makeImage() else { return nil }
    return UIImage(cgImage: cgImage)
}
```

---

## Migration from WKWebView

### Step 1: Create Native VNC View

Replace `WebViewWrapper` with `NativeVNCView`

### Step 2: Update RemoteDesktopView

Remove noVNC URL construction, use direct VNC connection

### Step 3: Remove Backend Dependencies

- Remove `ConnectionManager.getConnectionURL()`
- Remove noVNC query parameters
- Use direct VNC host:port

### Step 4: Simplify Connection

```swift
struct RemoteDesktopView: View {
    let server: RemoteServer
    @StateObject private var vncConnection = VNCConnection()
    
    var body: some View {
        ZStack {
            NativeVNCView(connection: vncConnection)
            LiquidGlassOverlay(selectedPane: $selectedPane)
        }
        .onAppear {
            Task {
                try? await vncConnection.connect(
                    host: server.host,
                    port: server.port,
                    password: server.password ?? ""
                )
            }
        }
    }
}
```

---

## Benefits

✅ **No Web Layer**
- Direct TCP connection
- No Safari keyboard blocking
- No noVNC scaling issues

✅ **Native Performance**
- Swift native code
- Efficient frame buffer updates
- Smooth rendering

✅ **Full Control**
- Direct RFB protocol
- Custom input handling
- Optimized for mobile

✅ **Simpler Architecture**
- No backend needed
- No Docker containers
- No web server

---

## Next Steps

1. **Implement basic VNC connection**
   - TCP socket
   - Protocol version handshake
   - Security handshake

2. **Implement authentication**
   - VNC Auth
   - DES encryption

3. **Implement frame buffer**
   - Receive updates
   - Render to UIImage
   - Display in SwiftUI

4. **Implement input**
   - Keyboard events
   - Mouse events
   - Touch handling

5. **Add Cursor automation**
   - Pane switching
   - Keyboard shortcuts
   - Zen mode


