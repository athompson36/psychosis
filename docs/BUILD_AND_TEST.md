# Build and Test Guide

## Quick Start

### 1. Open Xcode Project

```bash
# From project root
open Psychosis/Psychosis.xcodeproj
```

Or if using the new structure:
```bash
cd apps/psychosis-ios
# Create Xcode project if needed (see below)
open PsychosisApp.xcodeproj
```

### 2. Add New Files to Xcode

The following new files need to be added to the Xcode project:

**Core VNC:**
- `PsychosisApp/Core/VNC/VNCConnection.swift`
- `PsychosisApp/Core/VNC/VNCFrameBuffer.swift`

**Services:**
- `PsychosisApp/Core/Services/CursorPaneController.swift`

**Views:**
- `PsychosisApp/Features/RemoteDesktop/NativeVNCView.swift`
- `PsychosisApp/Features/RemoteDesktop/LiquidGlassOverlay.swift`
- `PsychosisApp/Features/RemoteDesktop/RemoteDesktopViewV2.swift`

**To add files:**
1. Right-click on appropriate group in Xcode
2. "Add Files to Psychosis..."
3. Select the files
4. ✅ "Copy items if needed" - UNCHECKED
5. ✅ "Add to targets: Psychosis" - CHECKED
6. Click "Add"

### 3. Configure Bridging Header (if needed)

If you get CommonCrypto errors:

1. **Create bridging header** (already created at):
   - `PsychosisApp/PsychosisApp-Bridging-Header.h`

2. **Configure in Xcode:**
   - Select project → Target → Build Settings
   - Search for "Bridging Header"
   - Set: `PsychosisApp/PsychosisApp-Bridging-Header.h`

3. **Or use Security framework:**
   - CommonCrypto should work directly on iOS 13+
   - If not, add Security framework to "Link Frameworks and Libraries"

### 4. Build

1. **Select target:**
   - iPhone (physical device recommended)
   - Or iOS Simulator

2. **Build (⌘B)**
   - Fix any compilation errors
   - Check for missing imports

3. **Run (⌘R)**
   - App should launch
   - Test connection to x11vnc

---

## Build Verification

### Check Required Files

All these files should exist and be added to Xcode:

```
✅ PsychosisApp/Core/VNC/VNCConnection.swift
✅ PsychosisApp/Core/VNC/VNCFrameBuffer.swift
✅ PsychosisApp/Core/Services/CursorPaneController.swift
✅ PsychosisApp/Features/RemoteDesktop/NativeVNCView.swift
✅ PsychosisApp/Features/RemoteDesktop/LiquidGlassOverlay.swift
✅ PsychosisApp/Features/RemoteDesktop/RemoteDesktopViewV2.swift
✅ PsychosisApp/Features/MainPane/MainPaneView.swift (updated)
```

### Check Imports

Verify these imports are present:

**VNCConnection.swift:**
```swift
import Foundation
import Network
import CommonCrypto  // May need Security framework
```

**NativeVNCView.swift:**
```swift
import SwiftUI
```

**LiquidGlassOverlay.swift:**
```swift
import SwiftUI
```

---

## Common Build Errors

### Error: "No such module 'CommonCrypto'"

**Solution 1:** Add Security framework
1. Select project → Target → General
2. "Frameworks, Libraries, and Embedded Content"
3. Click "+"
4. Add "Security.framework"

**Solution 2:** Use bridging header
1. Ensure `PsychosisApp-Bridging-Header.h` exists
2. Configure in Build Settings → "Objective-C Bridging Header"
3. Set path: `PsychosisApp/PsychosisApp-Bridging-Header.h`

**Solution 3:** Use CryptoKit (alternative)
- Replace DES with AES (requires server-side changes)
- Or implement DES manually

### Error: "Cannot find 'VNCConnection' in scope"

**Solution:**
- Ensure `VNCConnection.swift` is added to Xcode project
- Check "Target Membership" in File Inspector
- Verify file is in correct group

### Error: "Cannot find 'RemoteDesktopViewV2' in scope"

**Solution:**
- Ensure `RemoteDesktopViewV2.swift` is added to Xcode project
- Check it's in the "RemoteDesktop" group
- Verify target membership

### Error: "Value of type 'VNCFrameBuffer' has no member 'toImage'"

**Solution:**
- Ensure `VNCFrameBuffer.swift` is added to project
- Check actor implementation is correct
- Verify async/await usage

---

## Testing Steps

### 1. Server Setup

```bash
# SSH into server
ssh andrew@192.168.4.100

# Start x11vnc
x11vnc -display :10 \
  -auth guess -forever -loop -noxdamage \
  -repeat -modtweak -xkb \
  -rfbauth ~/.vnc/passwd -rfbport 5900 \
  -shared -bg -o /tmp/x11vnc.log -verbose

# Verify
ps aux | grep x11vnc | grep -v grep
netstat -tlnp | grep 5900
```

### 2. App Configuration

1. **Open app**
2. **Go to Settings**
3. **Edit server** (or add new):
   - Host: `192.168.4.100`
   - Port: `5900` (NOT 6080)
   - Password: Your VNC password
   - Type: Ubuntu

### 3. Connection Test

1. **Select server** from "Editors" tab
2. **Watch connection status**
3. **Verify:**
   - ✅ "Connecting..." appears
   - ✅ Connection succeeds
   - ✅ Remote screen displays
   - ✅ Frame buffer updates

### 4. Input Test

1. **Tap screen** → Should send mouse click
2. **Pinch** → Should zoom
3. **Drag** → Should pan
4. **Type** (if keyboard) → Should send keys

### 5. Automation Test

1. **Tap "Editor" tab** → Should activate Zen mode + focus editor
2. **Tap "Chat" tab** → Should activate Zen mode + open chat
3. **Tap "Files" tab** → Should show explorer + Zen mode
4. **Tap "Terminal" tab** → Should toggle terminal + Zen mode

---

## Debug Logging

### Xcode Console

Watch for these messages:

```
✅ VNC TCP connection ready
📡 RFB Version: RFB 003.008
🔑 Received VNC challenge
✅ VNC authentication successful
🖥️ Server: 1920x1080 - Cursor
🎯 Switching to Editor pane
✅ Sent keys via RFB API
```

### Server Logs

```bash
# On server
tail -f /tmp/x11vnc.log | grep -E "(key|mouse|client)"
```

---

## Success Criteria

✅ **Build succeeds** - No compilation errors  
✅ **App launches** - No runtime crashes  
✅ **Connection works** - Connects to x11vnc  
✅ **Screen displays** - Remote screen visible  
✅ **Input works** - Touch/keyboard functional  
✅ **Automation works** - Pane switching activates Cursor  

---

## Next Steps After Successful Build

1. **Test all features**
2. **Fix any issues found**
3. **Optimize performance**
4. **Polish UI**
5. **Remove old code** (WebViewWrapper, etc.)

---

## Troubleshooting

### Build Fails Immediately

- Check Xcode version (iOS 15+ recommended)
- Verify Swift version (5.5+ for async/await)
- Check deployment target (iOS 15+)

### App Crashes on Launch

- Check console for error messages
- Verify all files are added to target
- Check for missing dependencies

### Connection Fails

- Verify x11vnc is running
- Check port 5900 is accessible
- Verify password is correct
- Check network connectivity

### Screen Not Displaying

- Check frame buffer is receiving updates
- Verify pixel format compatibility
- Check image conversion code

---

## Quick Build Command

```bash
# From project root
cd Psychosis
xcodebuild -project Psychosis.xcodeproj \
  -scheme Psychosis \
  -destination 'platform=iOS Simulator,name=iPhone 15' \
  clean build
```

Or open in Xcode and build there (recommended).

---

**Ready to build!** 🚀


