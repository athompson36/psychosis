# Fix Build Errors: HubApp.swift and Duplicate Files

## Current Issues

1. ❌ **`HubApp.swift` reference exists but file is deleted** - causing "Build input file cannot be found"
2. ⚠️ **Duplicate file references** - files added multiple times causing "Skipping duplicate" warnings

## Step-by-Step Fix

### Step 1: Remove HubApp.swift from Build Phases

**This is the critical fix for the build error:**

1. **Open Xcode** with `Psychosis.xcodeproj`
2. Select **Psychosis** project (blue icon) in Project Navigator
3. Select **Psychosis** target (under TARGETS)
4. Click **Build Phases** tab
5. Expand **Compile Sources** section
6. **Find `HubApp.swift`** in the list (it will show the full path)
7. **Select `HubApp.swift`** in the list
8. Click the **"-"** (minus) button at the bottom to remove it
9. **Clean build folder**: Product → Clean Build Folder (⇧⌘K)

### Step 2: Remove Duplicate File References

The "Skipping duplicate" messages mean files are added twice. Remove duplicates:

1. In **Project Navigator**, look for files that appear multiple times:
   - `RemoteServer.swift`
   - `FileItem.swift`
   - `RemoteDesktopView.swift`
   - `Assets.xcassets`

2. For each duplicate:
   - Select the duplicate entry (usually the one in red/gray or showing wrong path)
   - Press **Delete** (or right-click → Delete)
   - Choose **"Remove Reference"** (NOT "Move to Trash")

3. **Verify in Build Phases**:
   - Go to **Build Phases** → **Compile Sources**
   - Each Swift file should appear **ONLY ONCE**
   - If you see duplicates, remove them using the "-" button

### Step 3: Verify File Structure

After removing duplicates, your Project Navigator should show:

```
Psychosis
├── App
│   ├── PsychosisApp.swift ✅ (ONLY ONE)
│   └── ContentView.swift ✅ (ONLY ONE)
├── Core
│   ├── Models
│   │   ├── FileItem.swift ✅ (ONLY ONE)
│   │   └── RemoteServer.swift ✅ (ONLY ONE)
│   └── ...
├── Features
│   ├── RemoteDesktop
│   │   └── RemoteDesktopView.swift ✅ (ONLY ONE)
│   └── ...
└── Resources
    └── Assets.xcassets ✅ (ONLY ONE)
```

**Important**: `HubApp.swift` should **NOT** appear anywhere.

### Step 4: Re-add Missing Files (if needed)

If you accidentally removed files that should be there:

1. **Right-click** on the appropriate folder in Project Navigator
2. Select **"Add Files to 'Psychosis'..."**
3. Navigate to `apps/hub-ios/HubApp/`
4. Select the file(s) you need
5. **IMPORTANT**:
   - ✅ **"Create groups"** (for Swift files)
   - ✅ **"Create folder references"** (for Assets.xcassets)
   - ❌ **"Copy items if needed"** - UNCHECKED
   - ✅ **"Add to targets: Psychosis"** - CHECKED
6. Click **"Add"**

### Step 5: Final Verification

1. **Build Phases Check**:
   - Project → Target → Build Phases → Compile Sources
   - Verify:
     - ✅ `PsychosisApp.swift` appears ONCE
     - ✅ `ContentView.swift` appears ONCE
     - ✅ `RemoteServer.swift` appears ONCE
     - ✅ `FileItem.swift` appears ONCE
     - ✅ `RemoteDesktopView.swift` appears ONCE
     - ❌ `HubApp.swift` does NOT appear

2. **Clean and Build**:
   - Product → Clean Build Folder (⇧⌘K)
   - Product → Build (⌘B)

## Expected Result

After completing these steps:
- ✅ No "Build input file cannot be found" error
- ✅ No "Skipping duplicate" warnings
- ✅ Build succeeds
- ✅ All files compile correctly

## Troubleshooting

### If HubApp.swift still appears in Build Phases:

1. Try closing and reopening Xcode
2. Check if there are multiple targets - remove from all targets
3. Manually edit `project.pbxproj` (advanced - not recommended)

### If duplicates persist:

1. Remove ALL references to the file
2. Clean build folder
3. Re-add the file once
4. Verify it appears only once in Build Phases

### If build still fails:

1. Check Project Navigator for any red/missing file references
2. Remove all missing file references
3. Verify all files exist on disk
4. Clean build folder and rebuild

