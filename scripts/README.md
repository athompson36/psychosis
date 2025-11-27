# VNC Keyboard Fix Scripts

These scripts help diagnose and fix VNC keyboard input issues.

## Quick Start

### 1. Restart x11vnc with Enhanced Keyboard Support

```bash
# On the Ubuntu server (192.168.4.100)
bash scripts/restart_x11vnc.sh
```

This script will:
- Stop any existing x11vnc process
- Enable keyboard repeat on X server
- Start x11vnc with enhanced keyboard flags:
  - `-modtweak` - Better modifier key handling
  - `-repeat` - Enable key repeat
  - `-xkb` - Use X keyboard extension
  - `-wait 10` - Delay between key events
  - `-defer 10` - Defer updates for smoother input

### 2. Test VNC Keyboard Configuration

```bash
# On the Ubuntu server
bash scripts/test_vnc_keyboard.sh
```

This script will check:
- ✅ x11vnc process status and flags
- ✅ X server keyboard repeat settings
- ✅ VNC port 5900 listening status
- ✅ noVNC container status
- ✅ x11vnc logs for keyboard events

## Manual Testing

After running the scripts, test keyboard input:

1. **Connect via VNC from iOS app**
2. **Open a terminal in the VNC session**
3. **Type 'test'** - should work normally
4. **Press Ctrl+C** - should interrupt
5. **In Cursor, manually press Ctrl+K then Z** - should activate Zen mode

If manual keyboard works but app shortcuts don't:
- Check browser console for JavaScript errors
- Verify RFB instance is found
- Check that `setAllKeysAllowed(true)` is called

## Backend API Endpoints

The backend also provides API endpoints to manage x11vnc:

- `GET /api/vnc/status` - Check x11vnc status and flags
- `POST /api/vnc/restart` - Restart x11vnc with enhanced flags
- `GET /api/vnc/keyboard-settings` - Check X server keyboard settings
- `POST /api/vnc/enable-keyboard-repeat` - Enable keyboard repeat
- `GET /api/vnc/logs?lines=50` - Get recent x11vnc logs

## Troubleshooting

### x11vnc won't start
- Check if port 5900 is already in use: `netstat -tlnp | grep 5900`
- Check logs: `tail -f /tmp/x11vnc.log`
- Verify VNC password is set: `ls -la ~/.vnc/passwd`

### Keyboard still not working
- Verify x11vnc has `-modtweak` flag: `ps aux | grep x11vnc | grep modtweak`
- Check X server keyboard repeat: `xset q | grep auto-repeat`
- Test with direct VNC client (bypass noVNC): `vncviewer 192.168.4.100:5900`
- Check browser console for JavaScript errors

### Keys work manually but not via app
- Check browser console for RFB instance detection
- Verify `setAllKeysAllowed(true)` is called
- Check timing - keys may be sent too fast
- Try increasing delays in JavaScript key sending


