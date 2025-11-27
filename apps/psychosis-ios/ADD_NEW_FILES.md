# Adding New Files to Xcode Project

## Issue
The build is failing because:
1. `RemoteServer.swift` and `RemoteDesktopView.swift` are not included in the Xcode project target
2. `PsychosisApp.swift` reference still exists in Xcode but the file has been deleted

## Quick Fix: Remove Stale PsychosisApp.swift Reference

**IMPORTANT: Do this first before adding new files!**

**See `FIX_BUILD_ERRORS.md` for detailed step-by-step instructions.**

### Quick Steps:

1. **Open Xcode** with `Psychosis.xcodeproj`
2. Select **Psychosis** project → **Psychosis** target → **Build Phases** tab
3. Expand **Compile Sources**
4. **Find and select `PsychosisApp.swift`** in the list
5. Click the **"-"** button to remove it
6. Clean build folder (⇧⌘K) and rebuild (⌘B)

**Note**: If you see "Skipping duplicate" warnings, also remove duplicate file references from Build Phases. See `FIX_BUILD_ERRORS.md` for complete instructions.

## Solution: Add Files to Xcode Project

### Step 1: Open Xcode Project
1. Open `Psychosis.xcodeproj` in Xcode

### Step 2: Add RemoteServer.swift
1. In Xcode Project Navigator, right-click on **Core → Models** folder
2. Select **"Add Files to 'Psychosis'..."**
3. Navigate to `apps/psychosis-ios/PsychosisApp/Core/Models/`
4. Select `RemoteServer.swift`
5. **IMPORTANT**:
   - ✅ **"Create groups"** (NOT folder references)
   - ❌ **"Copy items if needed"** - UNCHECKED
   - ✅ **"Add to targets: Psychosis"** - CHECKED
6. Click **"Add"**

### Step 3: Add RemoteDesktopView.swift
1. In Xcode Project Navigator, right-click on **Features → RemoteDesktop** folder (or create it if it doesn't exist)
2. Select **"Add Files to 'Psychosis'..."**
3. Navigate to `apps/psychosis-ios/PsychosisApp/Features/RemoteDesktop/`
4. Select `RemoteDesktopView.swift`
5. **IMPORTANT**:
   - ✅ **"Create groups"** (NOT folder references)
   - ❌ **"Copy items if needed"** - UNCHECKED
   - ✅ **"Add to targets: Psychosis"** - CHECKED
6. Click **"Add"**

### Step 4: Add App Icon Assets
1. In Xcode Project Navigator, right-click on **Resources** folder (or create it if it doesn't exist)
2. Select **"Add Files to 'Psychosis'..."**
3. Navigate to `apps/psychosis-ios/PsychosisApp/Resources/`
4. Select the entire `Assets.xcassets` folder
5. **IMPORTANT**:
   - ✅ **"Create folder references"** (for asset catalogs)
   - ❌ **"Copy items if needed"** - UNCHECKED
   - ✅ **"Add to targets: Psychosis"** - CHECKED
6. Click **"Add"**

### Step 5: Verify Files Are Added
1. Select the **Psychosis** project in Navigator
2. Select the **Psychosis** target
3. Go to **Build Phases** tab
4. Expand **Compile Sources**
5. Verify you see:
   - `RemoteServer.swift`
   - `RemoteDesktopView.swift`
   - All other Swift files

### Step 6: Clean and Build
1. **Product → Clean Build Folder** (⇧⌘K)
2. **Product → Build** (⌘B)

## Alternative: Add All Missing Files at Once

If you prefer to add multiple files at once:

1. Right-click on the **Psychosis** project root in Navigator
2. Select **"Add Files to 'Psychosis'..."**
3. Navigate to `apps/psychosis-ios/PsychosisApp/`
4. Select:
   - `Core/Models/RemoteServer.swift`
   - `Features/RemoteDesktop/RemoteDesktopView.swift`
   - `Resources/Assets.xcassets/` (entire folder)
5. **IMPORTANT**:
   - ✅ **"Create groups"** for Swift files
   - ✅ **"Create folder references"** for Assets.xcassets
   - ❌ **"Copy items if needed"** - UNCHECKED
   - ✅ **"Add to targets: Psychosis"** - CHECKED
6. Click **"Add"**

## Verify App Icon is Set

After adding Assets.xcassets:

1. Select the **Psychosis** project in Navigator
2. Select the **Psychosis** target
3. Go to **General** tab
4. Under **App Icons and Launch Screen**, verify:
   - **App Icons Source** is set to `Assets.xcassets/AppIcon`

If it's not set:
1. Click the dropdown
2. Select `Assets.xcassets/AppIcon`

## Expected Result

After completing these steps:
- ✅ Build should succeed
- ✅ App icon should appear in simulator/device
- ✅ All types should be accessible

