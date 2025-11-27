# Psychosis Architecture V2 - Native VNC Client

## Core Principle

**The app is a remote desktop viewer + Cursor automation. Nothing more.**

No backend. No file APIs. No AI. Just VNC + keyboard shortcuts.

---

## Architecture

```
┌─────────────────────────────────────┐
│         iOS App (SwiftUI)           │
│                                     │
│  ┌───────────────────────────────┐ │
│  │   Native VNC Client           │ │
│  │   (libvncclient / CocoaVNC)   │ │
│  └───────────────────────────────┘ │
│              │                      │
│              │ VNC Protocol         │
│              ▼                      │
│  ┌───────────────────────────────┐ │
│  │   Liquid Glass UI Overlay     │ │
│  │   - Editor Tab                │ │
│  │   - Files Tab                 │ │
│  │   - Chat Tab                  │ │
│  │   - Terminal Tab              │ │
│  └───────────────────────────────┘ │
└─────────────────────────────────────┘
              │
              │ Direct VNC Connection
              │ (Port 5900)
              ▼
┌─────────────────────────────────────┐
│      Ubuntu Server (fs-dev)         │
│                                     │
│  ┌───────────────────────────────┐ │
│  │   x11vnc (VNC Server)         │ │
│  │   Port: 5900                  │ │
│  └───────────────────────────────┘ │
│              │                      │
│              ▼                      │
│  ┌───────────────────────────────┐ │
│  │   Cursor (VS Code)            │ │
│  │   - Editor                     │ │
│  │   - Files                      │ │
│  │   - Chat                       │ │
│  │   - Terminal                   │ │
│  └───────────────────────────────┘ │
└─────────────────────────────────────┘
```

---

## What the App Does

### 1. Remote Desktop Viewer
- Native VNC client (not web-based)
- Direct connection to x11vnc on port 5900
- Full-screen canvas with touch controls
- Pinch to zoom, pan to scroll

### 2. Keyboard & Mouse Passthrough
- Hardware keyboard → VNC keyboard events
- Touch → mouse click
- Drag → mouse drag
- Long press → right click
- Pinch → zoom

### 3. Cursor Pane Automation
- **Editor Tab**: Send `Ctrl+K Z` (Zen mode) + `Ctrl+1` (focus editor)
- **Files Tab**: Send `Ctrl+Shift+E` (focus explorer) + `Ctrl+K Z` (Zen mode)
- **Chat Tab**: Send `Ctrl+L` (open chat) + `Ctrl+K Z` (Zen mode)
- **Terminal Tab**: Send `Ctrl+` ` (toggle terminal) + `Ctrl+K Z` (Zen mode)

### 4. Liquid Glass UI
- Minimal overlay with 4 tabs
- Auto-hide when not in use
- Transparent glass effect
- Tap to switch panes

---

## What the App Does NOT Do

❌ **No backend server**
- No Node.js
- No Express
- No file APIs
- No AI endpoints

❌ **No file management**
- No file reading
- No file editing
- No file browser

❌ **No AI integration**
- No OpenAI API
- No chat processing
- No code analysis

❌ **No local state**
- No project files
- No workspace management
- No settings sync

---

## iOS Implementation

### VNC Client Options

#### Option 1: libvncclient (Recommended)
- C library, bridge to Swift
- Full control, lightweight
- Used by many VNC apps

#### Option 2: CocoaVNC
- Objective-C wrapper
- Higher level API
- May need updates for SwiftUI

#### Option 3: RealVNC SDK
- Commercial option
- Well maintained
- May require license

#### Option 4: Custom WebSocket VNC
- Implement RFB protocol
- More work, full control

**Recommendation: Start with libvncclient via Swift Package Manager**

### Key Components

```swift
// 1. VNC Connection Manager
class VNCConnection {
    func connect(host: String, port: Int, password: String)
    func disconnect()
    func sendKey(key: UInt32, pressed: Bool)
    func sendMouse(x: Int, y: Int, button: Int)
}

// 2. Cursor Pane Controller
class CursorPaneController {
    func switchToEditor()
    func switchToFiles()
    func switchToChat()
    func switchToTerminal()
}

// 3. Liquid Glass UI
struct LiquidGlassOverlay: View {
    @State var selectedPane: CursorPane
    // Minimal tabs, auto-hide
}
```

---

## Server Requirements

### Minimal Setup

```bash
# 1. Install x11vnc
sudo apt-get install -y x11vnc

# 2. Set password
x11vnc -storepasswd ~/.vnc/passwd

# 3. Start x11vnc (with keyboard flags)
x11vnc -display :10 \
  -auth guess \
  -forever \
  -loop \
  -noxdamage \
  -repeat \
  -modtweak \
  -xkb \
  -rfbauth ~/.vnc/passwd \
  -rfbport 5900 \
  -shared \
  -bg

# 4. Ensure Cursor is installed
# That's it!
```

**No Docker. No noVNC. No web server. Just x11vnc.**

---

## Network Architecture

```
iOS Device (192.168.4.x)
    │
    │ Direct VNC Connection
    │ Port 5900
    │
    ▼
Ubuntu Server (192.168.4.100)
    │
    └── x11vnc → Cursor
```

**No intermediaries. No web layer. Direct VNC protocol.**

---

## Benefits

✅ **Simpler**
- No backend to maintain
- No API endpoints
- No web server
- No Docker containers

✅ **Faster**
- Direct VNC connection
- No web layer overhead
- Native rendering
- Lower latency

✅ **More Reliable**
- No Safari keyboard blocking
- No noVNC scaling issues
- No web UI glitches
- Native touch handling

✅ **Better UX**
- Native iOS gestures
- Hardware keyboard support
- Smooth scrolling
- Proper zoom/pan

---

## Migration Plan

### Phase 1: Remove Backend Dependencies
- [ ] Remove Node.js backend
- [ ] Remove noVNC web view
- [ ] Remove file APIs
- [ ] Remove AI endpoints

### Phase 2: Implement Native VNC Client
- [ ] Add libvncclient via SPM
- [ ] Create VNCConnection class
- [ ] Implement keyboard passthrough
- [ ] Implement mouse/touch passthrough

### Phase 3: Simplify UI
- [ ] Remove file browser
- [ ] Remove editor view
- [ ] Keep only VNC canvas + tabs
- [ ] Implement Liquid Glass overlay

### Phase 4: Cursor Automation
- [ ] Implement pane switching
- [ ] Test keyboard shortcuts
- [ ] Add Zen mode automation
- [ ] Polish UI transitions

---

## Comparison

| Feature | Old (Web-based) | New (Native VNC) |
|---------|----------------|------------------|
| Backend | Node.js + Express | None |
| VNC Client | WKWebView + noVNC | Native libvncclient |
| Keyboard | JavaScript injection | Direct VNC protocol |
| Latency | Higher (web layer) | Lower (direct) |
| Reliability | Safari blocks shortcuts | Native passthrough |
| Complexity | High | Low |
| Maintenance | Backend + frontend | iOS only |

---

## Next Steps

1. **Research libvncclient for iOS**
   - Check Swift Package availability
   - Test basic connection
   - Verify keyboard/mouse passthrough

2. **Create minimal VNC client**
   - Connection only
   - Display remote screen
   - Basic input

3. **Add Cursor automation**
   - Keyboard shortcuts
   - Pane switching
   - Zen mode

4. **Polish UI**
   - Liquid Glass overlay
   - Tab switching
   - Auto-hide


