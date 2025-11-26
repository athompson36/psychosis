# Quick Fix: Add Features to Xcode Project

If you're only seeing the welcome screen, the feature files need to be added to your Xcode project.

## Quick Steps

### 1. Add Feature Files to Xcode

**In Xcode:**

1. Right-click on **"Psychosis"** in the Project Navigator (left sidebar)
2. Select **"Add Files to Psychosis..."**
3. Navigate to: `Psychosis/Features/`
4. Select the **entire `Features` folder**
5. **IMPORTANT - Check these settings:**
   - ✅ **"Create groups"** (NOT "Create folder references")
   - ❌ **"Copy items if needed"** - UNCHECKED (files are already in place)
   - ✅ **"Add to targets: Psychosis"** - CHECKED
6. Click **"Add"**

### 2. Verify Files Are Added

After adding, you should see in Project Navigator:
```
Psychosis
├── Features
│   ├── Home
│   ├── Settings
│   ├── Detail
│   ├── Profile
│   └── Search
```

### 3. Build and Run

1. Press **⌘B** to build
2. If there are errors about missing files, make sure all feature folders were added
3. Press **⌘R** to run
4. You should now see **4 tabs**: Home, Search, Profile, Settings

## Troubleshooting

### If you see "Cannot find 'MainTabView' in scope":

1. Make sure `Features/Home/Views/MainTabView.swift` is added to the project
2. Check that it's added to the "Psychosis" target
3. Clean build folder: **Product → Clean Build Folder** (⇧⌘K)
4. Rebuild: **⌘B**

### If some features are missing:

1. Check Project Navigator - are all feature folders visible?
2. If a folder is missing, add it individually:
   - Right-click → Add Files
   - Select the missing feature folder
   - Same settings as above

### If build succeeds but still shows welcome screen:

1. Check `PsychosisApp.swift` - it should have:
   ```swift
   WindowGroup {
       MainTabView()
   }
   ```
2. If it still says `ContentView()`, update it to `MainTabView()`

---

**After adding files, you should see the full app with 4 tabs!**

