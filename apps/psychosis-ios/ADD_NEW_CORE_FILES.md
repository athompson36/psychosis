# Add New Core Files to Xcode Project

## Issue
Build errors:
- `Cannot find 'ConnectionManager' in scope`
- `Cannot find 'WebViewWrapper' in scope`

## Solution: Add Files to Xcode

### Step 1: Add WebViewWrapper.swift

1. **Open Xcode** with `Psychosis.xcodeproj`

2. In **Project Navigator**, right-click on **Core → UI** folder (or create it if it doesn't exist)

3. Select **"Add Files to 'Psychosis'..."**

4. Navigate to `apps/psychosis-ios/PsychosisApp/Core/UI/`

5. Select `WebViewWrapper.swift`

6. **IMPORTANT**:
   - ✅ **"Create groups"** (NOT folder references)
   - ❌ **"Copy items if needed"** - UNCHECKED
   - ✅ **"Add to targets: Psychosis"** - CHECKED

7. Click **"Add"**

### Step 2: Add ConnectionManager.swift

1. In **Project Navigator**, right-click on **Core → Services** folder

2. Select **"Add Files to 'Psychosis'..."**

3. Navigate to `apps/psychosis-ios/PsychosisApp/Core/Services/`

4. Select `ConnectionManager.swift`

5. **IMPORTANT**:
   - ✅ **"Create groups"** (NOT folder references)
   - ❌ **"Copy items if needed"** - UNCHECKED
   - ✅ **"Add to targets: Psychosis"** - CHECKED

6. Click **"Add"**

### Step 3: Add SettingsView.swift

1. In **Project Navigator**, right-click on **Features → Settings** folder (or create it if it doesn't exist)

2. Select **"Add Files to 'Psychosis'..."**

3. Navigate to `apps/psychosis-ios/PsychosisApp/Features/Settings/`

4. Select `SettingsView.swift`

5. **IMPORTANT**:
   - ✅ **"Create groups"** (NOT folder references)
   - ❌ **"Copy items if needed"** - UNCHECKED
   - ✅ **"Add to targets: Psychosis"** - CHECKED

6. Click **"Add"**

### Step 4: Verify Files Are Added

1. Select **Psychosis** project in Navigator
2. Select **Psychosis** target
3. Go to **Build Phases** tab
4. Expand **Compile Sources**
5. Verify you see:
   - `WebViewWrapper.swift`
   - `ConnectionManager.swift`
   - `SettingsView.swift`

### Step 5: Clean and Build

1. **Product → Clean Build Folder** (⇧⌘K)
2. **Product → Build** (⌘B)

## Alternative: Add All Files at Once

If you prefer to add multiple files at once:

1. Right-click on the **Psychosis** project root in Navigator
2. Select **"Add Files to 'Psychosis'..."**
3. Navigate to `apps/psychosis-ios/PsychosisApp/`
4. Select:
   - `Core/UI/WebViewWrapper.swift`
   - `Core/Services/ConnectionManager.swift`
   - `Features/Settings/SettingsView.swift`
5. **IMPORTANT**:
   - ✅ **"Create groups"** for all files
   - ❌ **"Copy items if needed"** - UNCHECKED
   - ✅ **"Add to targets: Psychosis"** - CHECKED
6. Click **"Add"**

## Expected Result

After completing these steps:
- ✅ Build should succeed
- ✅ ConnectionManager will be accessible
- ✅ WebViewWrapper will be accessible
- ✅ Settings view will be accessible
- ✅ Remote desktop view will work

## File Locations

- `Core/UI/WebViewWrapper.swift` - WebView wrapper for remote desktop
- `Core/Services/ConnectionManager.swift` - Connection management service
- `Features/Settings/SettingsView.swift` - Settings UI

