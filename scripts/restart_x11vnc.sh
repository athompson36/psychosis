#!/bin/bash
# Restart x11vnc with enhanced keyboard support flags
# Run this on the Ubuntu server: bash scripts/restart_x11vnc.sh

set -e

echo "🔄 Restarting x11vnc with enhanced keyboard support..."

# Kill existing x11vnc
echo "⏹️  Stopping existing x11vnc..."
pkill x11vnc || echo "   (no existing x11vnc process found)"

# Wait a moment
sleep 2

# Check if password file exists
if [ ! -f ~/.vnc/passwd ]; then
    echo "⚠️  VNC password file not found. Creating..."
    x11vnc -storepasswd ~/.vnc/passwd
fi

# Enable keyboard repeat on X server (if X is available)
if [ -n "$DISPLAY" ]; then
    echo "⌨️  Enabling keyboard repeat on X server..."
    xset r on 2>/dev/null || echo "   (could not set keyboard repeat - may need to run in X session)"
    xset r rate 200 30 2>/dev/null || echo "   (could not set repeat rate - may need to run in X session)"
else
    echo "⚠️  No DISPLAY set. Keyboard repeat will be set when X session starts."
    echo "   Add to ~/.xprofile:"
    echo "   xset r on"
    echo "   xset r rate 200 30"
fi

# Determine display (try :10 first, fallback to :0)
DISPLAY_NUM=":10"
if ! xdpyinfo -display $DISPLAY_NUM >/dev/null 2>&1; then
    DISPLAY_NUM=":0"
    echo "📺 Using display $DISPLAY_NUM (fallback from :10)"
else
    echo "📺 Using display $DISPLAY_NUM"
fi

# Start x11vnc with enhanced keyboard flags
echo "🚀 Starting x11vnc with enhanced keyboard support..."
x11vnc -display $DISPLAY_NUM \
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

# Wait a moment for startup
sleep 2

# Verify it's running
if ps aux | grep -v grep | grep x11vnc > /dev/null; then
    echo "✅ x11vnc is running!"
    echo ""
    echo "📊 Process info:"
    ps aux | grep -v grep | grep x11vnc
    echo ""
    echo "🔌 Listening on port 5900:"
    netstat -tlnp 2>/dev/null | grep 5900 || ss -tlnp 2>/dev/null | grep 5900 || echo "   (port check failed - may need sudo)"
    echo ""
    echo "📝 Log file: /tmp/x11vnc.log"
    echo "   View with: tail -f /tmp/x11vnc.log"
    echo ""
    echo "🧪 Test keyboard input:"
    echo "   1. Connect via VNC"
    echo "   2. Open a terminal"
    echo "   3. Type 'test' - should work normally"
    echo "   4. Press Ctrl+C - should interrupt"
else
    echo "❌ x11vnc failed to start!"
    echo "📝 Check logs:"
    tail -20 /tmp/x11vnc.log 2>/dev/null || echo "   (log file not found)"
    exit 1
fi


