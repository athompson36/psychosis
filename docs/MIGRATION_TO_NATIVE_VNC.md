# Migration to Native VNC Client

## Overview

**Complete architectural pivot:** From web-based (WKWebView + noVNC) to native VNC client (direct RFB protocol).

---

## What's Been Created

### ✅ Core VNC Implementation

1. **`VNCConnection.swift`**
   - Native RFB protocol implementation
   - Direct TCP connection to VNC server
   - Authentication handling
   - Frame buffer update receiving
   - Keyboard/mouse input sending

2. **`VNCFrameBuffer.swift`**
   - Frame buffer management
   - Pixel data storage
   - UIImage conversion
   - Rectangle updates

3. **`CursorPaneController.swift`**
   - Pane switching automation
   - Keyboard shortcut sequences
   - Zen mode activation
   - Timing coordination

### 📋 Still Needed

1. **SwiftUI View**
   - `NativeVNCView.swift` - Display frame buffer
   - Touch handling
   - Pinch/zoom/pan gestures

2. **Liquid Glass Overlay**
   - Tab buttons (Editor, Files, Chat, Terminal)
   - Auto-hide functionality
   - Transparent glass effect

3. **Update RemoteDesktopView**
   - Replace `WebViewWrapper` with `NativeVNCView`
   - Remove noVNC URL construction
   - Use direct VNC connection

4. **Remove Backend Dependencies**
   - Remove `ConnectionManager.getConnectionURL()`
   - Remove noVNC query parameters
   - Simplify connection logic

5. **Fix DES Encryption**
   - Current implementation is placeholder
   - Need full DES encryption for VNC auth
   - Or use alternative auth method

---

## Migration Steps

### Step 1: Complete VNC Client

**Priority: HIGH**

- [ ] Fix DES encryption in `VNCConnection.swift`
- [ ] Test basic connection to x11vnc
- [ ] Verify frame buffer updates work
- [ ] Test keyboard input
- [ ] Test mouse input

### Step 2: Create SwiftUI View

**Priority: HIGH**

- [ ] Create `NativeVNCView.swift`
- [ ] Display frame buffer as UIImage
- [ ] Implement touch → mouse conversion
- [ ] Implement pinch/zoom
- [ ] Implement pan/scroll

### Step 3: Create Liquid Glass UI

**Priority: MEDIUM**

- [ ] Create `LiquidGlassOverlay.swift`
- [ ] Add 4 tab buttons
- [ ] Implement auto-hide
- [ ] Add glass effect styling
- [ ] Connect to `CursorPaneController`

### Step 4: Update RemoteDesktopView

**Priority: HIGH**

- [ ] Replace `WebViewWrapper` with `NativeVNCView`
- [ ] Remove noVNC URL logic
- [ ] Simplify connection flow
- [ ] Update error handling

### Step 5: Remove Backend

**Priority: LOW (Can be done later)**

- [ ] Remove Node.js backend
- [ ] Remove Docker containers
- [ ] Remove noVNC container
- [ ] Clean up unused code

---

## Current Status

### ✅ Completed
- Architecture documentation
- VNC connection class structure
- Frame buffer class
- Cursor pane controller
- RFB protocol message handling

### 🚧 In Progress
- DES encryption (placeholder)
- Frame buffer rendering
- SwiftUI view integration

### ❌ Not Started
- Touch handling
- Gesture recognition
- Liquid Glass UI
- Backend removal

---

## Testing Plan

### Phase 1: Basic Connection
1. Connect to x11vnc on port 5900
2. Verify authentication works
3. Receive frame buffer updates
4. Display remote screen

### Phase 2: Input Testing
1. Test keyboard input
2. Test mouse input
3. Test touch → mouse conversion
4. Test gestures (pinch, pan)

### Phase 3: Cursor Automation
1. Test Editor pane switch
2. Test Chat pane switch
3. Test Files pane switch
4. Test Terminal pane switch
5. Verify Zen mode activation

### Phase 4: UI Polish
1. Test Liquid Glass overlay
2. Test auto-hide
3. Test tab switching
4. Test full-screen mode

---

## Key Differences from Old Architecture

| Aspect | Old (Web-based) | New (Native VNC) |
|--------|-----------------|------------------|
| **Connection** | WKWebView → noVNC → x11vnc | Direct TCP → x11vnc |
| **Protocol** | HTTP/WebSocket | RFB (VNC protocol) |
| **Rendering** | Web canvas | Native UIImage |
| **Input** | JavaScript injection | Direct VNC messages |
| **Backend** | Node.js required | None needed |
| **Dependencies** | Docker, noVNC | Just x11vnc |
| **Latency** | Higher (web layer) | Lower (direct) |
| **Reliability** | Safari blocks shortcuts | Native passthrough |

---

## Next Immediate Steps

1. **Fix DES Encryption**
   - Research VNC DES implementation
   - Implement proper encryption
   - Test authentication

2. **Create NativeVNCView**
   - SwiftUI view wrapper
   - Display frame buffer
   - Handle touch events

3. **Test Basic Connection**
   - Connect to x11vnc
   - Verify screen displays
   - Test basic input

4. **Integrate with RemoteDesktopView**
   - Replace WebViewWrapper
   - Update connection flow
   - Test end-to-end

---

## Benefits of New Architecture

✅ **Simpler**
- No web layer
- No backend
- No Docker
- Direct connection

✅ **Faster**
- Lower latency
- Native rendering
- Efficient updates

✅ **More Reliable**
- No Safari blocking
- No web UI issues
- Native input handling

✅ **Better UX**
- Native gestures
- Smooth performance
- Full control

---

## Notes

- **DES Encryption**: VNC uses a non-standard DES implementation. Need to research and implement correctly.
- **Frame Buffer**: Currently assumes 32-bit RGBA pixels. May need to handle different pixel formats.
- **Encoding**: Currently only handles Raw encoding. May need to support other encodings (CopyRect, Hextile, etc.) for better performance.
- **Threading**: Frame buffer updates happen on background thread, need to ensure UI updates on main thread.


