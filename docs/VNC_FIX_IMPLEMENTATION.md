# VNC Keyboard Fix - Implementation Summary

## What Was Implemented

### 1. Shell Scripts (Run on Ubuntu Server)

#### `scripts/restart_x11vnc.sh`
- Restarts x11vnc with enhanced keyboard support flags
- Enables keyboard repeat on X server
- Verifies x11vnc is running correctly
- **Usage:** `bash scripts/restart_x11vnc.sh`

#### `scripts/test_vnc_keyboard.sh`
- Comprehensive diagnostic script
- Checks x11vnc process, flags, and configuration
- Verifies X server keyboard settings
- Checks noVNC container status
- **Usage:** `bash scripts/test_vnc_keyboard.sh`

#### `scripts/run_all_tests.sh`
- Automated test suite
- Runs all diagnostic checks
- Provides pass/fail summary
- **Usage:** `bash scripts/run_all_tests.sh`

### 2. Backend API Endpoints

New route: `/api/vnc/*`

- `GET /api/vnc/status` - Check x11vnc status and flags
- `POST /api/vnc/restart` - Restart x11vnc with enhanced flags
- `GET /api/vnc/keyboard-settings` - Check X server keyboard settings
- `POST /api/vnc/enable-keyboard-repeat` - Enable keyboard repeat
- `GET /api/vnc/logs?lines=50` - Get recent x11vnc logs

### 3. iOS Service

New service: `VNCService.swift`
- Swift wrapper for VNC API endpoints
- Can check status, restart x11vnc, enable keyboard repeat
- Ready to integrate into Settings view

### 4. Enhanced JavaScript Debugging

Updated `RemoteDesktopView.swift`:
- Added detailed logging for key sending
- Shows which keys are being sent (keysym, key name, down/up)
- Better error messages
- 20ms delays between keys for reliability

---

## How to Test

### Step 1: Deploy Scripts to Server

```bash
# On your Mac, copy scripts to server
scp scripts/*.sh andrew@192.168.4.100:~/psychosis/scripts/
ssh andrew@192.168.4.100 "chmod +x ~/psychosis/scripts/*.sh"
```

### Step 2: Run Restart Script

```bash
# SSH into server
ssh andrew@192.168.4.100

# Run restart script
cd ~/psychosis
bash scripts/restart_x11vnc.sh
```

Expected output:
```
🔄 Restarting x11vnc with enhanced keyboard support...
⏹️  Stopping existing x11vnc...
⌨️  Enabling keyboard repeat on X server...
📺 Using display :10
🚀 Starting x11vnc with enhanced keyboard support...
✅ x11vnc is running!
```

### Step 3: Run Test Script

```bash
# On server
bash scripts/test_vnc_keyboard.sh
```

This will show:
- ✅ x11vnc process status
- ✅ Critical flags present (-modtweak, -repeat, -xkb)
- ✅ X server keyboard repeat settings
- ✅ VNC port listening status
- ✅ noVNC container status
- ✅ Recent keyboard events in logs

### Step 4: Test Manually

1. **Connect via VNC from iOS app**
2. **Open a terminal in VNC session**
3. **Type 'test'** - should work normally
4. **Press Ctrl+C** - should interrupt
5. **In Cursor, manually press Ctrl+K then Z** - should activate Zen mode

### Step 5: Test via App

1. **Select Chat tab in iOS app**
2. **Check browser console** (if accessible) for:
   - `📤 Sending keys via RFB API: X keys`
   - `✅ Sent keys via RFB API`
   - `✅ Sent Zen Mode (Ctrl+K Z) then Chat (Ctrl+L)`
3. **Verify Zen mode activates in Cursor**

---

## Troubleshooting

### If x11vnc won't start:

```bash
# Check if port 5900 is in use
netstat -tlnp | grep 5900

# Check logs
tail -f /tmp/x11vnc.log

# Verify password file exists
ls -la ~/.vnc/passwd
```

### If keyboard still doesn't work:

1. **Verify flags are present:**
   ```bash
   ps aux | grep x11vnc | grep -E "(modtweak|repeat|xkb)"
   ```

2. **Check X server keyboard repeat:**
   ```bash
   xset q | grep auto-repeat
   # Should show: auto-repeat: on
   ```

3. **Test with direct VNC client (bypass noVNC):**
   ```bash
   # Install TigerVNC viewer
   sudo apt-get install -y tigervnc-viewer
   
   # Connect directly
   vncviewer 192.168.4.100:5900
   
   # If shortcuts work here, issue is with noVNC
   # If shortcuts don't work here, issue is with x11vnc/X server
   ```

4. **Check browser console:**
   - Open noVNC in browser
   - Open DevTools console
   - Look for RFB instance detection
   - Check for `setAllKeysAllowed(true)` call

### If keys work manually but not via app:

1. **Check JavaScript timing:**
   - Keys may be sent too fast
   - Try increasing delays in `RemoteDesktopView.swift`

2. **Verify RFB instance:**
   - Check browser console for `window.psychosisRFB`
   - Should not be `null` or `undefined`

3. **Check key codes:**
   - Verify keysym values are correct
   - Ctrl = 0xFFE3, K = 0x006B, Z = 0x007A

---

## Expected Results

After running the fixes:

✅ **x11vnc running with:**
- `-modtweak` flag (modifier key handling)
- `-repeat` flag (key repeat)
- `-xkb` flag (keyboard extension)

✅ **X server keyboard repeat enabled:**
- `auto-repeat: on`
- Repeat rate: 200ms delay, 30 chars/sec

✅ **Manual keyboard works:**
- Typing in terminal works
- Ctrl+C interrupts
- Ctrl+K Z activates Zen mode in Cursor

✅ **App shortcuts work:**
- Chat tab activates Zen mode
- Keys are sent via RFB API
- Cursor responds to shortcuts

---

## Next Steps

1. **Deploy scripts to server** and run `restart_x11vnc.sh`
2. **Run test script** to verify configuration
3. **Test manually** in VNC session
4. **Test via iOS app** and check browser console
5. **If still not working**, check troubleshooting section above

---

## Files Created/Modified

### New Files:
- `scripts/restart_x11vnc.sh` - Restart x11vnc with enhanced flags
- `scripts/test_vnc_keyboard.sh` - Diagnostic script
- `scripts/run_all_tests.sh` - Automated test suite
- `scripts/README.md` - Script documentation
- `apps/psychosis-backend/src/routes/vnc.js` - VNC API endpoints
- `apps/psychosis-ios/PsychosisApp/Core/Services/VNCService.swift` - iOS service
- `docs/VNC_KEYBOARD_DIAGNOSTIC.md` - Comprehensive diagnostic guide
- `docs/VNC_FIX_IMPLEMENTATION.md` - This file

### Modified Files:
- `apps/psychosis-backend/src/index.js` - Added VNC router
- `apps/psychosis-ios/PsychosisApp/Features/RemoteDesktop/RemoteDesktopView.swift` - Enhanced debugging
- `docs/VNC_FIX.md` - Updated with enhanced x11vnc flags


