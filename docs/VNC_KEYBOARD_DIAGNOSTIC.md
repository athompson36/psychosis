# VNC Keyboard Input Diagnostic & Fix Guide

## Problem: Keyboard Shortcuts Not Working (Zen Mode, Ctrl+K Z, etc.)

If Cursor keyboard shortcuts aren't working through VNC, there are several potential blockers at different levels.

---

## 1. Check x11vnc Configuration

### Current x11vnc Command (from docs)
```bash
x11vnc -display :10 -auth guess -forever -loop -noxdamage -repeat -rfbauth ~/.vnc/passwd -rfbport 5900 -shared -bg -o /tmp/x11vnc.log
```

### Enhanced x11vnc Command (Better Keyboard Support)
```bash
# Kill existing x11vnc
pkill x11vnc

# Start with enhanced keyboard flags
x11vnc -display :10 \
  -auth guess \
  -forever \
  -loop \
  -noxdamage \
  -repeat \
  -modtweak \
  -xkb \
  -noscr \
  -nowf \
  -wait 10 \
  -defer 10 \
  -rfbauth ~/.vnc/passwd \
  -rfbport 5900 \
  -shared \
  -bg \
  -o /tmp/x11vnc.log \
  -verbose
```

**Key flags for keyboard:**
- `-repeat` - Enable key repeat (critical for shortcuts)
- `-modtweak` - Better modifier key handling (Ctrl, Alt, Shift)
- `-xkb` - Use X keyboard extension (better key mapping)
- `-noscr` - Disable screen blanking
- `-nowf` - Disable wireframe cursor
- `-wait 10` - Wait 10ms between key events
- `-defer 10` - Defer updates by 10ms
- `-verbose` - Log keyboard events for debugging

### Verify x11vnc is Running with Correct Flags
```bash
# Check x11vnc process and flags
ps aux | grep x11vnc | grep -v grep

# Check x11vnc logs for keyboard events
tail -f /tmp/x11vnc.log | grep -i key
```

---

## 2. Check X Server Keyboard Settings

### Enable Keyboard Repeat on X Server
```bash
# Check current keyboard repeat settings
xset q | grep -A 2 "auto-repeat"

# Enable keyboard repeat (if disabled)
xset r on

# Set repeat rate (delay 200ms, rate 30 chars/sec)
xset r rate 200 30

# Make it persistent (add to ~/.xprofile or ~/.xsessionrc)
echo "xset r on" >> ~/.xprofile
echo "xset r rate 200 30" >> ~/.xprofile
```

### Check X Keyboard Extension
```bash
# Verify XKB is enabled
xset q | grep -i "xkb"

# If not enabled, you may need to restart X server or use x11vnc -xkb flag
```

---

## 3. Check noVNC Keyboard Settings

### Verify noVNC Container Configuration
```bash
# Check noVNC container logs
docker logs novnc | grep -i key

# Check if noVNC is blocking keyboard
docker exec novnc cat /usr/share/novnc/vnc.html | grep -i "keyboard\|setAllKeysAllowed"
```

### noVNC URL Parameters (Already Applied in App)
The app should be using:
- `resize=remote` (not `scale`)
- `quality=9` (not `6`)
- `view_only=false`
- `clip=true`
- `shared=true`

### Manual noVNC Keyboard Test
Open noVNC in browser and check browser console:
```javascript
// In browser console on noVNC page
console.log(window.rfb);
console.log(window.rfb.keyboard);
console.log(window.rfb.keyboard.setAllKeysAllowed);
// Should show: function setAllKeysAllowed() { ... }

// Try enabling manually
window.rfb.keyboard.setAllKeysAllowed(true);
```

---

## 4. Test Keyboard Input Directly

### Test 1: Simple Key Press
```bash
# On Ubuntu server, test if keyboard input works at all
# Open a terminal in the VNC session and type:
echo "test"
# If typing works, keyboard input is reaching the X server
```

### Test 2: Test Modifier Keys
```bash
# In VNC terminal, test Ctrl+C
# Press Ctrl+C - should interrupt a running command
# If it doesn't work, modifier keys aren't being passed through
```

### Test 3: Test Cursor Shortcuts Directly
1. Connect via VNC
2. Click inside Cursor window
3. Manually press `Ctrl+K` then `Z` on your physical keyboard
4. If Zen mode activates, the issue is with JavaScript key sending, not VNC
5. If Zen mode doesn't activate, the issue is with VNC keyboard passthrough

---

## 5. Check for X11 Keyboard Mapping Issues

### Verify Keyboard Layout
```bash
# Check current keyboard layout
setxkbmap -query

# Set to US layout explicitly
setxkbmap us

# Check if modifier keys are mapped correctly
xmodmap -pke | grep -E "Control|Shift|Alt"
```

### Test Key Codes
```bash
# Install xev to test key events
sudo apt-get install -y xev

# Run xev and press keys to see key codes
xev | grep -A 2 --line-buffered '^keycode' | tee /tmp/keycodes.log

# Press Ctrl+K Z and check the log
cat /tmp/keycodes.log
```

---

## 6. noVNC-Specific Keyboard Blocking

### Check noVNC UI Settings
Some noVNC versions have UI settings that block keyboard shortcuts:

1. Open noVNC in browser
2. Look for settings/gear icon
3. Check "Keyboard" or "Input" settings
4. Ensure "View Only" is OFF
5. Ensure "Keyboard Grab" is ON
6. Ensure "All Keys Allowed" is ON

### noVNC JavaScript Console Test
```javascript
// In browser console on noVNC page
// Check if RFB instance exists
var rfb = window.rfb || window.psychosisRFB || (typeof UI !== 'undefined' && UI.rfb);
console.log('RFB:', rfb);

// Check keyboard settings
if (rfb && rfb.keyboard) {
    console.log('Keyboard object:', rfb.keyboard);
    console.log('setAllKeysAllowed:', typeof rfb.keyboard.setAllKeysAllowed);
    
    // Try to enable
    try {
        rfb.keyboard.setAllKeysAllowed(true);
        console.log('✅ setAllKeysAllowed(true) called');
    } catch(e) {
        console.error('❌ Error:', e);
    }
}

// Test sending a key directly
if (rfb && typeof rfb.sendKey === 'function') {
    console.log('Testing Ctrl key...');
    rfb.sendKey(0xFFE3, true);  // Ctrl down
    setTimeout(() => rfb.sendKey(0xFFE3, false), 100);  // Ctrl up
    console.log('✅ Ctrl key sent');
}
```

---

## 7. Alternative: Use xdotool for Testing

If JavaScript key sending isn't working, test with xdotool on the server:

```bash
# Install xdotool
sudo apt-get install -y xdotool

# Find Cursor window
xdotool search --name "Cursor" | head -1

# Send Ctrl+K Z to Cursor
WINDOW_ID=$(xdotool search --name "Cursor" | head -1)
xdotool windowactivate $WINDOW_ID
xdotool key ctrl+k
sleep 0.2
xdotool key z

# If this works, the issue is with noVNC key passthrough, not Cursor
```

---

## 8. Quick Fix: Restart x11vnc with Enhanced Flags

```bash
#!/bin/bash
# Quick restart script with enhanced keyboard support

# Kill existing
pkill x11vnc

# Wait a moment
sleep 2

# Start with all keyboard flags
x11vnc -display :10 \
  -auth guess \
  -forever \
  -loop \
  -noxdamage \
  -repeat \
  -modtweak \
  -xkb \
  -noscr \
  -nowf \
  -wait 10 \
  -defer 10 \
  -rfbauth ~/.vnc/passwd \
  -rfbport 5900 \
  -shared \
  -bg \
  -o /tmp/x11vnc.log \
  -verbose

# Verify
sleep 2
ps aux | grep x11vnc | grep -v grep
echo "✅ x11vnc restarted with enhanced keyboard support"
```

---

## 9. Debugging Steps

1. **Check x11vnc logs:**
   ```bash
   tail -f /tmp/x11vnc.log
   # Try sending keys and watch for log entries
   ```

2. **Check noVNC container logs:**
   ```bash
   docker logs -f novnc
   # Look for keyboard-related errors
   ```

3. **Test in browser console:**
   - Open noVNC in browser
   - Open DevTools console
   - Run the JavaScript tests above
   - Check for errors

4. **Test with different VNC client:**
   ```bash
   # Install TigerVNC viewer
   sudo apt-get install -y tigervnc-viewer
   
   # Connect directly (bypassing noVNC)
   vncviewer 192.168.4.100:5900
   
   # If shortcuts work here, the issue is with noVNC
   # If shortcuts don't work here, the issue is with x11vnc or X server
   ```

---

## 10. Most Likely Issues

Based on common problems:

1. **x11vnc missing `-modtweak` flag** - Modifier keys not handled correctly
2. **X server keyboard repeat disabled** - `xset r on` not set
3. **noVNC not calling `setAllKeysAllowed(true)`** - Check JavaScript injection
4. **Browser blocking keyboard shortcuts** - iOS Safari intercepts ⌘+K, ⌘+Z
5. **Timing issues** - Keys sent too fast, Cursor doesn't recognize chord

---

## Next Steps

1. Restart x11vnc with enhanced flags (section 8)
2. Enable keyboard repeat on X server (section 2)
3. Test keyboard input directly (section 4)
4. Check noVNC JavaScript console (section 6)
5. If still not working, try direct VNC client (section 9, step 4)


