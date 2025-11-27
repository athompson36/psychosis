#!/bin/bash
# Comprehensive test script for VNC keyboard fixes
# Run this on the Ubuntu server: bash scripts/run_all_tests.sh

set -e

echo "🧪 VNC Keyboard Fix - Comprehensive Test"
echo "========================================"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counter
TESTS_PASSED=0
TESTS_FAILED=0

# Function to print test result
test_result() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✅ PASS${NC}: $2"
        ((TESTS_PASSED++))
    else
        echo -e "${RED}❌ FAIL${NC}: $2"
        ((TESTS_FAILED++))
    fi
}

# Test 1: Check if x11vnc is running
echo "1️⃣  Testing x11vnc process..."
if ps aux | grep -v grep | grep x11vnc > /dev/null; then
    test_result 0 "x11vnc is running"
else
    test_result 1 "x11vnc is NOT running"
    echo "   Run: bash scripts/restart_x11vnc.sh"
fi

# Test 2: Check for critical flags
echo ""
echo "2️⃣  Testing x11vnc flags..."
X11VNC_CMD=$(ps aux | grep -v grep | grep x11vnc | head -1)

if echo "$X11VNC_CMD" | grep -q "\-modtweak"; then
    test_result 0 "-modtweak flag present"
else
    test_result 1 "-modtweak flag MISSING"
fi

if echo "$X11VNC_CMD" | grep -q "\-repeat"; then
    test_result 0 "-repeat flag present"
else
    test_result 1 "-repeat flag MISSING"
fi

if echo "$X11VNC_CMD" | grep -q "\-xkb"; then
    test_result 0 "-xkb flag present"
else
    test_result 1 "-xkb flag MISSING"
fi

# Test 3: Check X server keyboard repeat
echo ""
echo "3️⃣  Testing X server keyboard settings..."
if [ -n "$DISPLAY" ]; then
    XSET_OUTPUT=$(xset q 2>/dev/null)
    if echo "$XSET_OUTPUT" | grep -q "auto-repeat: on"; then
        test_result 0 "Keyboard repeat is ON"
    else
        test_result 1 "Keyboard repeat is OFF"
        echo "   Fix: xset r on"
    fi
else
    echo -e "${YELLOW}⚠️  SKIP${NC}: No DISPLAY set (not in X session)"
fi

# Test 4: Check VNC port
echo ""
echo "4️⃣  Testing VNC port..."
if netstat -tlnp 2>/dev/null | grep -q ":5900" || ss -tlnp 2>/dev/null | grep -q ":5900"; then
    test_result 0 "Port 5900 is listening"
else
    test_result 1 "Port 5900 is NOT listening"
fi

# Test 5: Check noVNC container
echo ""
echo "5️⃣  Testing noVNC container..."
if docker ps | grep -q novnc; then
    test_result 0 "noVNC container is running"
else
    test_result 1 "noVNC container is NOT running"
fi

# Test 6: Check x11vnc logs
echo ""
echo "6️⃣  Testing x11vnc logs..."
if [ -f /tmp/x11vnc.log ]; then
    LOG_SIZE=$(wc -l < /tmp/x11vnc.log)
    if [ $LOG_SIZE -gt 0 ]; then
        test_result 0 "Log file exists and has content ($LOG_SIZE lines)"
    else
        test_result 1 "Log file exists but is empty"
    fi
else
    test_result 1 "Log file not found: /tmp/x11vnc.log"
fi

# Summary
echo ""
echo "========================================"
echo "📊 Test Summary"
echo "========================================"
echo -e "${GREEN}✅ Passed: $TESTS_PASSED${NC}"
echo -e "${RED}❌ Failed: $TESTS_FAILED${NC}"
echo ""

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${GREEN}🎉 All tests passed!${NC}"
    echo ""
    echo "Next steps:"
    echo "1. Connect via VNC from iOS app"
    echo "2. Test keyboard input manually"
    echo "3. Try Zen mode shortcut (Ctrl+K Z)"
    exit 0
else
    echo -e "${YELLOW}⚠️  Some tests failed${NC}"
    echo ""
    echo "Recommended fixes:"
    if ! ps aux | grep -v grep | grep x11vnc > /dev/null; then
        echo "  • Run: bash scripts/restart_x11vnc.sh"
    fi
    if [ -n "$DISPLAY" ] && ! xset q 2>/dev/null | grep -q "auto-repeat: on"; then
        echo "  • Run: xset r on && xset r rate 200 30"
    fi
    exit 1
fi


