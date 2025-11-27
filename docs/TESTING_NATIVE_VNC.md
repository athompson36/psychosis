# Testing Native VNC Client

## Prerequisites

### 1. Server Setup

Ensure x11vnc is running on your Ubuntu server with proper flags:

```bash
# SSH into server
ssh andrew@192.168.4.100

# Kill existing x11vnc
pkill x11vnc

# Start with enhanced keyboard support
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
  -bg \
  -o /tmp/x11vnc.log \
  -verbose

# Verify it's running
ps aux | grep x11vnc | grep -v grep
netstat -tlnp | grep 5900
```

### 2. App Configuration

In the iOS app, configure server:
- **Host**: `192.168.4.100` (or your server IP)
- **Port**: `5900` (direct VNC, NOT 6080)
- **Password**: Your VNC password
- **Type**: Ubuntu

---

## Testing Steps

### Phase 1: Basic Connection

1. **Build and Run App**
   ```bash
   # Open in Xcode
   open apps/psychosis-ios/PsychosisApp.xcodeproj
   
   # Build and run on device/simulator
   ```

2. **Connect to Server**
   - Open app
   - Select server from "Editors" tab
   - App should connect to x11vnc on port 5900
   - Watch for connection status

3. **Verify Display**
   - Remote screen should appear
   - Should see Cursor or desktop
   - Frame buffer should update (~30 FPS)

### Phase 2: Input Testing

1. **Touch Input**
   - Tap on screen → should send mouse click
   - Tap in Cursor window → should focus/click
   - Verify cursor moves on remote screen

2. **Gestures**
   - Pinch to zoom → should zoom in/out
   - Drag to pan → should pan around screen
   - Long press → should send right click (if implemented)

3. **Keyboard** (if external keyboard connected)
   - Type text → should appear in Cursor
   - Test modifier keys (Ctrl, Shift, Alt)

### Phase 3: Cursor Automation

1. **Editor Tab**
   - Tap "Editor" tab in overlay
   - Should send: Ctrl+K, Z (Zen mode), Ctrl+1 (focus editor)
   - Verify Cursor enters Zen mode
   - Verify editor is focused

2. **Chat Tab**
   - Tap "Chat" tab
   - Should send: Ctrl+K, Z (Zen mode), Ctrl+L (open chat)
   - Verify chat panel opens
   - Verify Zen mode is active

3. **Files Tab**
   - Tap "Files" tab
   - Should send: Ctrl+Shift+E (explorer), Ctrl+K, Z (Zen mode)
   - Verify file explorer opens
   - Verify Zen mode is active

4. **Terminal Tab**
   - Tap "Terminal" tab
   - Should send: Ctrl+` (toggle terminal), Ctrl+K, Z (Zen mode)
   - Verify terminal opens
   - Verify Zen mode is active

### Phase 4: UI Testing

1. **Liquid Glass Overlay**
   - Overlay should appear at top
   - Should show 4 tabs (Editor, Files, Chat, Terminal)
   - Selected tab should be highlighted

2. **Auto-Hide**
   - Overlay should hide after 5 seconds
   - Swipe down should show overlay
   - Tap should reset auto-hide timer

3. **Visual Polish**
   - Check glass blur effect
   - Check color coding
   - Check transitions

---

## Troubleshooting

### Connection Fails

**Error**: "Could not connect to server"
- ✅ Check x11vnc is running: `ps aux | grep x11vnc`
- ✅ Check port 5900 is listening: `netstat -tlnp | grep 5900`
- ✅ Check firewall allows port 5900
- ✅ Verify host IP is correct
- ✅ Check network connectivity

**Error**: "Authentication failed"
- ✅ Verify VNC password is correct
- ✅ Check DES encryption is working (check logs)
- ✅ Try setting password again: `x11vnc -storepasswd ~/.vnc/passwd`

### Screen Not Displaying

**Issue**: Black screen or no image
- ✅ Check frame buffer is receiving updates
- ✅ Check x11vnc logs: `tail -f /tmp/x11vnc.log`
- ✅ Verify Cursor/desktop is running on display :10
- ✅ Check pixel format compatibility

**Issue**: Screen updates slowly
- ✅ Check network latency
- ✅ Verify Raw encoding is being used
- ✅ May need to implement other encodings (CopyRect, Hextile)

### Keyboard Shortcuts Not Working

**Issue**: Cursor doesn't respond to shortcuts
- ✅ Verify x11vnc has `-modtweak` flag
- ✅ Check X server keyboard repeat: `xset q | grep auto-repeat`
- ✅ Test manually: Connect via VNC, press Ctrl+K Z manually
- ✅ If manual works but app doesn't, check key codes
- ✅ Check timing delays in `CursorPaneController`

**Issue**: Wrong keys being sent
- ✅ Verify keysym values are correct
- ✅ Check Ctrl = 0xFFE3, K = 0x006B, Z = 0x007A
- ✅ May need to adjust for different keyboard layouts

### Touch Not Working

**Issue**: Taps don't register
- ✅ Check coordinate mapping
- ✅ Verify touch location calculation
- ✅ Check button mask (1 = left, 2 = right, 4 = middle)

**Issue**: Wrong location clicked
- ✅ Check scale/offset calculations
- ✅ Verify aspect ratio handling
- ✅ May need to adjust coordinate transformation

---

## Debug Logging

### Enable Debug Logs

The app includes debug logging. Check Xcode console for:

- `✅ VNC TCP connection ready` - Connection established
- `📡 RFB Version: RFB 003.008` - Protocol version
- `🔑 Received VNC challenge` - Authentication started
- `✅ VNC authentication successful` - Auth passed
- `🖥️ Server: 1920x1080 - Cursor` - Server init received
- `🎯 Switching to Editor pane` - Pane switching
- `✅ Sent keys via RFB API` - Keys sent successfully

### Server Logs

Check x11vnc logs on server:

```bash
tail -f /tmp/x11vnc.log | grep -E "(key|mouse|client)"
```

Look for:
- Keyboard events
- Mouse events
- Client connections

---

## Expected Behavior

### Successful Connection
1. App connects to x11vnc
2. Authentication succeeds
3. Remote screen displays
4. Frame buffer updates smoothly
5. Touch input works
6. Pane switching works
7. Cursor responds to shortcuts

### Performance
- Frame rate: ~30 FPS
- Latency: < 100ms (on local network)
- Input response: Immediate
- Memory usage: Reasonable

---

## Next Steps After Testing

1. **Fix Issues Found**
   - Document any bugs
   - Fix DES encryption if auth fails
   - Adjust timing if shortcuts don't work
   - Fix coordinate mapping if touch is off

2. **Optimize**
   - Implement other encodings for better performance
   - Optimize frame buffer updates
   - Reduce memory usage

3. **Polish**
   - Improve error messages
   - Add connection retry logic
   - Enhance UI transitions
   - Add settings for connection options

4. **Remove Old Code**
   - Remove `WebViewWrapper`
   - Remove old `RemoteDesktopView`
   - Remove backend dependencies
   - Clean up unused files

---

## Success Criteria

✅ **Connection**: App connects to x11vnc successfully  
✅ **Display**: Remote screen displays correctly  
✅ **Input**: Touch and keyboard work  
✅ **Automation**: Pane switching activates Cursor shortcuts  
✅ **UI**: Liquid Glass overlay works and looks good  
✅ **Performance**: Smooth frame rate, low latency  

If all criteria are met, the native VNC client is **production ready**! 🎉


