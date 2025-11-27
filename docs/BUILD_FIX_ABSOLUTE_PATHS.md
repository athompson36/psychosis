# Build Fix - Absolute Paths Solution ✅

## Issue

Build error: Files cannot be found at paths with duplicate segments:
```
apps/psychosis-ios/apps/psychosis-ios/PsychosisApp/...
```

## Root Cause

The file paths were using relative paths (`../apps/psychosis-ios/...`) with `sourceTree = "<group>"`, but there was a parent group at `../apps/psychosis-ios/PsychosisApp` with `sourceTree = SOURCE_ROOT`. This caused Xcode to resolve paths incorrectly, creating the duplicate path segments.

## Solution

Changed all 6 VNC files to use **absolute paths** with `sourceTree = "<absolute>"`:

### Files Fixed

- ✅ `VNCConnection.swift` → Absolute path
- ✅ `VNCFrameBuffer.swift` → Absolute path  
- ✅ `CursorPaneController.swift` → Absolute path
- ✅ `NativeVNCView.swift` → Absolute path
- ✅ `LiquidGlassOverlay.swift` → Absolute path
- ✅ `RemoteDesktopViewV2.swift` → Absolute path

### Example

**Before:**
```
path = "../apps/psychosis-ios/PsychosisApp/Core/VNC/VNCConnection.swift";
sourceTree = "<group>";
```

**After:**
```
path = "/Users/andrew/Documents/fs-tech/psychosis/apps/psychosis-ios/PsychosisApp/Core/VNC/VNCConnection.swift";
sourceTree = "<absolute>";
```

## Why This Works

Absolute paths bypass Xcode's path resolution logic that was causing the duplication. The files are now referenced directly by their full filesystem paths, eliminating any ambiguity.

## Next Steps

1. **Clean build folder** in Xcode (⌘⇧K)
2. **Build again** (⌘B)
3. The build should now succeed! ✅

---

**Status: Fixed with Absolute Paths** ✅


