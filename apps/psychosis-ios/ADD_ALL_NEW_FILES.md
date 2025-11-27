# Add All New Files to Xcode Project

## Issue
Build errors for missing files that need to be added to Xcode project.

**Note**: The `.horizontal` and `.vertical` padding errors are caused by missing type definitions. Once you add the files below, these errors will resolve automatically.

## Files to Add

### Core Services
1. `Core/Services/ConnectionHistoryManager.swift`
2. `Core/Services/ConnectionQualityMonitor.swift`

### Core UI
3. `Core/UI/WebViewWrapper.swift` (already created, needs to be added)

### Core Utilities
4. `Core/Utilities/ScreenshotManager.swift`

### Features - RemoteDesktop
5. `Features/RemoteDesktop/RemoteDesktopToolbar.swift`
6. `Features/RemoteDesktop/VirtualKeyboardView.swift`

### Features - Settings
7. `Features/Settings/RecentConnectionsView.swift`

## Step-by-Step Instructions

### Option 1: Add All Files at Once (Recommended)

1. **Open Xcode** with `Psychosis.xcodeproj`

2. In **Project Navigator**, right-click on the **Psychosis** project root

3. Select **"Add Files to 'Psychosis'..."**

4. Navigate to `apps/psychosis-ios/PsychosisApp/`

5. Select the following files/folders:
   - `Core/Services/ConnectionHistoryManager.swift`
   - `Core/Services/ConnectionQualityMonitor.swift`
   - `Core/UI/WebViewWrapper.swift`
   - `Core/Utilities/ScreenshotManager.swift`
   - `Features/RemoteDesktop/RemoteDesktopToolbar.swift`
   - `Features/RemoteDesktop/VirtualKeyboardView.swift`
   - `Features/Settings/RecentConnectionsView.swift`

6. **IMPORTANT**:
   - ✅ **"Create groups"** (NOT folder references)
   - ❌ **"Copy items if needed"** - UNCHECKED
   - ✅ **"Add to targets: Psychosis"** - CHECKED

7. Click **"Add"**

### Option 2: Add Files Individually

#### Add ConnectionHistoryManager.swift
1. Right-click on **Core → Services** folder
2. "Add Files to 'Psychosis'..."
3. Select `Core/Services/ConnectionHistoryManager.swift`
4. Create groups, don't copy, add to target
5. Click "Add"

#### Add ConnectionQualityMonitor.swift
1. Right-click on **Core → Services** folder
2. "Add Files to 'Psychosis'..."
3. Select `Core/Services/ConnectionQualityMonitor.swift`
4. Create groups, don't copy, add to target
5. Click "Add"

#### Add ScreenshotManager.swift
1. Right-click on **Core → Utilities** folder (create if needed)
2. "Add Files to 'Psychosis'..."
3. Select `Core/Utilities/ScreenshotManager.swift`
4. Create groups, don't copy, add to target
5. Click "Add"

#### Add RemoteDesktopToolbar.swift
1. Right-click on **Features → RemoteDesktop** folder
2. "Add Files to 'Psychosis'..."
3. Select `Features/RemoteDesktop/RemoteDesktopToolbar.swift`
4. Create groups, don't copy, add to target
5. Click "Add"

#### Add VirtualKeyboardView.swift
1. Right-click on **Features → RemoteDesktop** folder
2. "Add Files to 'Psychosis'..."
3. Select `Features/RemoteDesktop/VirtualKeyboardView.swift`
4. Create groups, don't copy, add to target
5. Click "Add"

#### Add RecentConnectionsView.swift
1. Right-click on **Features → Settings** folder
2. "Add Files to 'Psychosis'..."
3. Select `Features/Settings/RecentConnectionsView.swift`
4. Create groups, don't copy, add to target
5. Click "Add"

#### Add WebViewWrapper.swift (if not already added)
1. Right-click on **Core → UI** folder (create if needed)
2. "Add Files to 'Psychosis'..."
3. Select `Core/UI/WebViewWrapper.swift`
4. Create groups, don't copy, add to target
5. Click "Add"

## Verify Files Are Added

1. Select **Psychosis** project in Navigator
2. Select **Psychosis** target
3. Go to **Build Phases** tab
4. Expand **Compile Sources**
5. Verify you see all files:
   - ✅ `ConnectionHistoryManager.swift`
   - ✅ `ConnectionQualityMonitor.swift`
   - ✅ `ScreenshotManager.swift`
   - ✅ `WebViewWrapper.swift`
   - ✅ `RemoteDesktopToolbar.swift`
   - ✅ `VirtualKeyboardView.swift`
   - ✅ `RecentConnectionsView.swift`

## Clean and Build

1. **Product → Clean Build Folder** (⇧⌘K)
2. **Product → Build** (⌘B)

## Expected Result

After adding all files:
- ✅ Build should succeed
- ✅ All types will be accessible
- ✅ Remote desktop features will work
- ✅ Connection history will be tracked
- ✅ Quality monitoring will work
- ✅ Screenshot functionality will be available

## File Locations Summary

```
apps/psychosis-ios/PsychosisApp/
├── Core/
│   ├── Services/
│   │   ├── ConnectionHistoryManager.swift
│   │   └── ConnectionQualityMonitor.swift
│   ├── UI/
│   │   └── WebViewWrapper.swift
│   └── Utilities/
│       └── ScreenshotManager.swift
└── Features/
    ├── RemoteDesktop/
    │   ├── RemoteDesktopToolbar.swift
    │   └── VirtualKeyboardView.swift
    └── Settings/
        └── RecentConnectionsView.swift
```

