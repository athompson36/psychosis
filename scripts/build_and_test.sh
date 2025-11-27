#!/bin/bash
# Build and test script for Psychosis iOS app
# This script helps verify the build and provides testing guidance

set -e

echo "🔨 Psychosis iOS - Build and Test"
echo "=================================="
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Check if we're in the right directory
if [ ! -d "apps/psychosis-ios" ]; then
    echo -e "${RED}❌ Error: apps/psychosis-ios directory not found${NC}"
    echo "Please run this script from the project root"
    exit 1
fi

cd apps/psychosis-ios

# Check for Xcode project
if [ ! -d "PsychosisApp.xcodeproj" ]; then
    echo -e "${YELLOW}⚠️  Xcode project not found${NC}"
    echo "Looking for project files..."
    
    # Try to find .xcodeproj
    PROJECT_FILE=$(find . -name "*.xcodeproj" -type d | head -1)
    if [ -z "$PROJECT_FILE" ]; then
        echo -e "${RED}❌ No Xcode project found${NC}"
        echo ""
        echo "Please create the Xcode project first:"
        echo "1. Open Xcode"
        echo "2. File → New → Project"
        echo "3. Select iOS → App"
        echo "4. Name: Psychosis"
        echo "5. Save to: apps/psychosis-ios/"
        exit 1
    else
        echo -e "${GREEN}✅ Found project: $PROJECT_FILE${NC}"
    fi
else
    echo -e "${GREEN}✅ Xcode project found${NC}"
fi

echo ""
echo "📋 Build Checklist"
echo "=================="
echo ""

# Check for required files
echo "1️⃣  Checking required files..."

REQUIRED_FILES=(
    "PsychosisApp/Core/VNC/VNCConnection.swift"
    "PsychosisApp/Core/VNC/VNCFrameBuffer.swift"
    "PsychosisApp/Core/Services/CursorPaneController.swift"
    "PsychosisApp/Features/RemoteDesktop/NativeVNCView.swift"
    "PsychosisApp/Features/RemoteDesktop/LiquidGlassOverlay.swift"
    "PsychosisApp/Features/RemoteDesktop/RemoteDesktopViewV2.swift"
    "PsychosisApp/Features/MainPane/MainPaneView.swift"
)

MISSING_FILES=0
for file in "${REQUIRED_FILES[@]}"; do
    if [ -f "$file" ]; then
        echo -e "   ${GREEN}✅${NC} $file"
    else
        echo -e "   ${RED}❌${NC} $file (MISSING)"
        MISSING_FILES=$((MISSING_FILES + 1))
    fi
done

if [ $MISSING_FILES -gt 0 ]; then
    echo ""
    echo -e "${RED}❌ $MISSING_FILES required files are missing${NC}"
    echo "Please ensure all files are created and added to the Xcode project"
    exit 1
fi

echo ""
echo "2️⃣  Checking imports..."

# Check for CommonCrypto import
if grep -q "import CommonCrypto" PsychosisApp/Core/VNC/VNCConnection.swift; then
    echo -e "   ${GREEN}✅${NC} CommonCrypto import found"
else
    echo -e "   ${YELLOW}⚠️${NC}  CommonCrypto import not found (may need bridging header)"
fi

# Check for Network import
if grep -q "import Network" PsychosisApp/Core/VNC/VNCConnection.swift; then
    echo -e "   ${GREEN}✅${NC} Network import found"
else
    echo -e "   ${RED}❌${NC} Network import missing"
fi

echo ""
echo "3️⃣  Build Instructions"
echo "======================"
echo ""
echo "To build the app:"
echo ""
echo "1. Open Xcode:"
echo "   ${YELLOW}open PsychosisApp.xcodeproj${NC}"
echo ""
echo "2. Select target device:"
echo "   - iPhone (physical device recommended for VNC testing)"
echo "   - Or iOS Simulator"
echo ""
echo "3. Build (⌘B) or Run (⌘R)"
echo ""
echo "4. If CommonCrypto errors occur:"
echo "   - Add bridging header (if needed)"
echo "   - Or use CryptoKit instead (may need DES implementation)"
echo ""
echo "5. Check build errors in Xcode"
echo ""

echo "4️⃣  Testing Checklist"
echo "====================="
echo ""
echo "After successful build:"
echo ""
echo "✅ Server Setup:"
echo "   - x11vnc running on port 5900"
echo "   - VNC password set"
echo ""
echo "✅ App Configuration:"
echo "   - Server host: 192.168.4.100"
echo "   - Server port: 5900"
echo "   - VNC password configured"
echo ""
echo "✅ Connection Test:"
echo "   - App connects to x11vnc"
echo "   - Authentication succeeds"
echo "   - Remote screen displays"
echo ""
echo "✅ Input Test:"
echo "   - Touch sends mouse clicks"
echo "   - Pinch to zoom works"
echo "   - Drag to pan works"
echo ""
echo "✅ Automation Test:"
echo "   - Editor tab activates Zen mode"
echo "   - Chat tab opens chat"
echo "   - Files tab shows explorer"
echo "   - Terminal tab toggles terminal"
echo ""

echo "5️⃣  Troubleshooting"
echo "==================="
echo ""
echo "If build fails:"
echo ""
echo "CommonCrypto Issues:"
echo "  - iOS 13+: CommonCrypto should work directly"
echo "  - If errors: May need to add Security framework"
echo "  - Alternative: Implement DES manually or use library"
echo ""
echo "Missing Files:"
echo "  - Ensure all files are added to Xcode project"
echo "  - Check Target Membership in File Inspector"
echo ""
echo "Import Errors:"
echo "  - Verify all imports are correct"
echo "  - Check framework availability for iOS version"
echo ""

echo "📝 Next Steps"
echo "============="
echo ""
echo "1. Open project in Xcode"
echo "2. Build and fix any errors"
echo "3. Run on device/simulator"
echo "4. Test VNC connection"
echo "5. Test pane switching"
echo ""

echo -e "${GREEN}✅ Build verification complete!${NC}"
echo ""
echo "Ready to build in Xcode 🚀"


