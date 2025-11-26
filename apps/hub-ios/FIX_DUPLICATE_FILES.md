# Fix: Multiple Commands Produce stringsdata Error

This error occurs when files are added to the Xcode project multiple times, causing duplicate compilation.

## Quick Fix

### Step 1: Remove Duplicate File References

1. **Open Xcode** with your `Psychosis.xcodeproj`

2. **Check Project Navigator** for duplicate files:
   - Look for `PsychosisApp.swift` appearing multiple times
   - Look for `ContentView.swift` appearing multiple times

3. **Remove duplicates**:
   - Select the duplicate file(s) in Project Navigator
   - Press **Delete** (or right-click → Delete)
   - Choose **"Remove Reference"** (NOT "Move to Trash")
   - This removes the file from the project but keeps it on disk

### Step 2: Verify File Locations

Make sure files are only in one location:
- `apps/hub-ios/HubApp/App/PsychosisApp.swift`
- `apps/hub-ios/HubApp/App/ContentView.swift`

### Step 3: Re-add Files (if needed)

If you removed files and need to add them back:

1. **Right-click** on the `App` folder (or Psychosis project root)
2. **Add Files to "Psychosis"...**
3. Navigate to `apps/hub-ios/HubApp/App/`
4. Select `PsychosisApp.swift` and `ContentView.swift`
5. **IMPORTANT**:
   - ✅ **"Create groups"** (NOT folder references)
   - ❌ **"Copy items if needed"** - UNCHECKED
   - ✅ **"Add to targets: Psychosis"** - CHECKED
6. Click **"Add"**

### Step 4: Clean Build

1. **Product → Clean Build Folder** (⇧⌘K)
2. **Product → Build** (⌘B)

## Alternative: Check Build Phases

1. Select **Psychosis** project in Navigator
2. Select **Psychosis** target
3. Go to **Build Phases** tab
4. Expand **Compile Sources**
5. Look for duplicate entries:
   - `PsychosisApp.swift` should appear ONCE
   - `ContentView.swift` should appear ONCE
6. **Remove duplicates** by selecting and clicking **"-"**

## Verify Fix

After fixing:
1. Clean build folder (⇧⌘K)
2. Build (⌘B)
3. Should build successfully without duplicate errors

---

**Common Causes:**
- Files added multiple times during project setup
- Files in both project root and subfolders
- Files added as both groups and folder references

