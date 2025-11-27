#!/bin/bash
# Test VNC keyboard input and settings
# Run this on the Ubuntu server: bash scripts/test_vnc_keyboard.sh

echo "🧪 Testing VNC Keyboard Configuration"
echo "======================================"
echo ""

# Check x11vnc process
echo "1️⃣  Checking x11vnc process..."
if ps aux | grep -v grep | grep x11vnc > /dev/null; then
    echo "   ✅ x11vnc is running"
    echo ""
    echo "   Process details:"
    ps aux | grep -v grep | grep x11vnc | head -1
    echo ""
    
    # Check for critical flags
    X11VNC_CMD=$(ps aux | grep -v grep | grep x11vnc | head -1)
    if echo "$X11VNC_CMD" | grep -q "\-modtweak"; then
        echo "   ✅ -modtweak flag present (good for modifier keys)"
    else
        echo "   ⚠️  -modtweak flag MISSING (may cause modifier key issues)"
    fi
    
    if echo "$X11VNC_CMD" | grep -q "\-repeat"; then
        echo "   ✅ -repeat flag present (good for key repeat)"
    else
        echo "   ⚠️  -repeat flag MISSING (may cause key repeat issues)"
    fi
    
    if echo "$X11VNC_CMD" | grep -q "\-xkb"; then
        echo "   ✅ -xkb flag present (good for keyboard mapping)"
    else
        echo "   ⚠️  -xkb flag MISSING (may cause keyboard mapping issues)"
    fi
else
    echo "   ❌ x11vnc is NOT running"
    echo "   Run: bash scripts/restart_x11vnc.sh"
fi

echo ""

# Check X server keyboard settings
echo "2️⃣  Checking X server keyboard settings..."
if [ -n "$DISPLAY" ]; then
    echo "   DISPLAY=$DISPLAY"
    XSET_OUTPUT=$(xset q 2>/dev/null)
    
    if echo "$XSET_OUTPUT" | grep -q "auto-repeat: on"; then
        echo "   ✅ Keyboard repeat is ON"
    else
        echo "   ⚠️  Keyboard repeat is OFF"
        echo "   Fix: xset r on"
    fi
    
    if echo "$XSET_OUTPUT" | grep -q "repeat rate"; then
        REPEAT_RATE=$(echo "$XSET_OUTPUT" | grep "repeat rate" | head -1)
        echo "   📊 $REPEAT_RATE"
    fi
else
    echo "   ⚠️  No DISPLAY set (not in X session)"
    echo "   Keyboard settings will be checked when X session starts"
fi

echo ""

# Check VNC port
echo "3️⃣  Checking VNC port 5900..."
if netstat -tlnp 2>/dev/null | grep -q ":5900" || ss -tlnp 2>/dev/null | grep -q ":5900"; then
    echo "   ✅ Port 5900 is listening"
    netstat -tlnp 2>/dev/null | grep ":5900" || ss -tlnp 2>/dev/null | grep ":5900"
else
    echo "   ❌ Port 5900 is NOT listening"
    echo "   x11vnc may not be running or configured correctly"
fi

echo ""

# Check noVNC container
echo "4️⃣  Checking noVNC container..."
if docker ps | grep -q novnc; then
    echo "   ✅ noVNC container is running"
    echo ""
    echo "   Container details:"
    docker ps | grep novnc
    echo ""
    echo "   Recent logs (last 10 lines):"
    docker logs --tail 10 novnc 2>&1 | grep -i -E "(key|error|warn)" || echo "   (no keyboard-related logs)"
else
    echo "   ⚠️  noVNC container is NOT running"
    echo "   Start with: docker run -d --name novnc -p 6080:8080 --network host theasp/novnc:latest websockify --web /usr/share/novnc 8080 localhost:5900"
fi

echo ""

# Check x11vnc logs for keyboard events
echo "5️⃣  Checking x11vnc logs for keyboard activity..."
if [ -f /tmp/x11vnc.log ]; then
    LOG_SIZE=$(wc -l < /tmp/x11vnc.log)
    echo "   Log file: /tmp/x11vnc.log ($LOG_SIZE lines)"
    
    KEYBOARD_EVENTS=$(grep -i -E "(key|keyboard|modifier)" /tmp/x11vnc.log | tail -5)
    if [ -n "$KEYBOARD_EVENTS" ]; then
        echo "   Recent keyboard events:"
        echo "$KEYBOARD_EVENTS" | sed 's/^/      /'
    else
        echo "   ℹ️  No keyboard events in recent logs"
        echo "   (This is normal if no keys have been pressed recently)"
    fi
    
    # Check for errors
    ERRORS=$(grep -i error /tmp/x11vnc.log | tail -5)
    if [ -n "$ERRORS" ]; then
        echo ""
        echo "   ⚠️  Recent errors:"
        echo "$ERRORS" | sed 's/^/      /'
    fi
else
    echo "   ⚠️  Log file not found: /tmp/x11vnc.log"
fi

echo ""
echo "======================================"
echo "✅ Test complete!"
echo ""
echo "📋 Next steps:"
echo "   1. Connect via VNC from your iOS app"
echo "   2. Open a terminal in the VNC session"
echo "   3. Type 'test' - should work normally"
echo "   4. Press Ctrl+C - should interrupt"
echo "   5. In Cursor, manually press Ctrl+K then Z"
echo "   6. If Zen mode works manually but not via app, check browser console"
echo ""


