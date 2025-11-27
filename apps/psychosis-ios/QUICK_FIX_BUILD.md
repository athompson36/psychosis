# Quick Fix: Add Missing Files to Xcode

## The Problem
Build fails because these files exist on disk but aren't in the Xcode project:
- `RemoteDesktopToolbar.swift`
- `VirtualKeyboardView.swift`
- `ConnectionHistoryManager.swift`
- `ConnectionQualityMonitor.swift`
- `ScreenshotManager.swift`
- `RecentConnectionsView.swift`
- `WebViewWrapper.swift`

## Quick Solution (2 minutes)

### Step 1: Open Xcode
1. Open `apps/psychosis-ios/Psychosis.xcodeproj` in Xcode

### Step 2: Add Files
1. In the **Project Navigator** (left sidebar), find the **Psychosis** project (blue icon at top)
2. Right-click on **Psychosis** project
3. Select **"Add Files to 'Psychosis'..."**

### Step 3: Select Files
1. Navigate to: `apps/psychosis-ios/PsychosisApp/`
2. **Hold Cmd** and click to select these files:
   - `Core/Services/ConnectionHistoryManager.swift`
   - `Core/Services/ConnectionQualityMonitor.swift`
   - `Core/UI/WebViewWrapper.swift`
   - `Core/Utilities/ScreenshotManager.swift`
   - `Features/RemoteDesktop/RemoteDesktopToolbar.swift`
   - `Features/RemoteDesktop/VirtualKeyboardView.swift`
   - `Features/Settings/RecentConnectionsView.swift`

### Step 4: Configure Options
**CRITICAL**: Set these options:
- ✅ **"Create groups"** (NOT "Create folder references")
- ❌ **"Copy items if needed"** - UNCHECK this
- ✅ **"Add to targets: Psychosis"** - CHECK this

### Step 5: Add
Click **"Add"** button

### Step 6: Verify
1. Click on **Psychosis** project in Navigator
2. Select **Psychosis** target
3. Go to **Build Phases** tab
4. Expand **"Compile Sources"**
5. You should see all 7 files listed

### Step 7: Build
1. **Product → Clean Build Folder** (⇧⌘K)
2. **Product → Build** (⌘B)

## Expected Result
✅ Build succeeds
✅ All errors resolved

## If Build Still Fails

### Check File Locations
Run this in terminal to verify files exist:
```bash
cd apps/psychosis-ios/PsychosisApp
ls -la Core/Services/ConnectionHistoryManager.swift
ls -la Features/RemoteDesktop/RemoteDesktopToolbar.swift
```

### Check Target Membership
1. Select a file in Project Navigator (e.g., `RemoteDesktopToolbar.swift`)
2. Open **File Inspector** (right sidebar, first tab)
3. Under **"Target Membership"**, ensure **Psychosis** is checked

### Remove and Re-add
If files show up but still error:
1. Select file in Navigator
2. Press **Delete**
3. Choose **"Remove Reference"** (NOT "Move to Trash")
4. Re-add using steps above

## Alternative: Add Files Individually

If bulk add doesn't work, add files one by one:

1. Right-click on the **folder** where file should go (e.g., `Features/RemoteDesktop`)
2. "Add Files to 'Psychosis'..."
3. Select the file
4. Same options: Create groups, don't copy, add to target
5. Click "Add"
6. Repeat for each file

