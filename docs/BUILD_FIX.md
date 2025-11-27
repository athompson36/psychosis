# Build Fix - File Paths

## Issue

Build error: Files cannot be found at paths like:
```
apps/psychosis-ios/apps/psychosis-ios/PsychosisApp/...
```

## Root Cause

The file paths in the Xcode project were using `../apps/psychosis-ios/...` which was being resolved incorrectly, causing a duplicate path.

## Fix Applied

Updated file paths from:
- `../apps/psychosis-ios/PsychosisApp/...`

To:
- `apps/psychosis-ios/PsychosisApp/...`

## Files Fixed

- ✅ VNCConnection.swift
- ✅ VNCFrameBuffer.swift
- ✅ CursorPaneController.swift
- ✅ NativeVNCView.swift
- ✅ LiquidGlassOverlay.swift
- ✅ RemoteDesktopViewV2.swift

## Verification

Paths are now correct. The project should build successfully.

If you still see path errors:

1. **Clean build folder** (⌘⇧K)
2. **Close and reopen Xcode**
3. **Verify files exist** at the paths
4. **Check file references** in Xcode (select file → File Inspector)

---

**Status: Fixed** ✅

Try building again!


