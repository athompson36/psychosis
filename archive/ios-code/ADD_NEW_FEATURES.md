# Adding New Features to Xcode Project

The build is failing because the new feature files need to be added to your Xcode project.

## Quick Fix

### Option 1: Add Individual Feature Folders (Recommended)

1. **Open Xcode** with your `Psychosis.xcodeproj` project

2. **Add Favorites feature**:
   - Right-click on "Features" in Project Navigator
   - Select "Add Files to Psychosis..."
   - Navigate to `Psychosis/Features/Favorites/`
   - Select the entire `Favorites` folder
   - Make sure:
     - ✅ "Create groups" is selected
     - ❌ "Copy items if needed" is **NOT** checked
     - ✅ "Add to targets: Psychosis" is checked
   - Click "Add"

3. **Add Notifications feature**:
   - Right-click on "Features" in Project Navigator
   - Select "Add Files to Psychosis..."
   - Navigate to `Psychosis/Features/Notifications/`
   - Select the entire `Notifications` folder
   - Same settings as above
   - Click "Add"

4. **Add History feature**:
   - Right-click on "Features" in Project Navigator
   - Select "Add Files to Psychosis..."
   - Navigate to `Psychosis/Features/History/`
   - Select the entire `History` folder
   - Same settings as above
   - Click "Add"

### Option 2: Add All at Once

1. Right-click on "Features" in Project Navigator
2. Select "Add Files to Psychosis..."
3. Navigate to `Psychosis/Features/`
4. Select all three folders: `Favorites`, `Notifications`, `History`
5. Make sure:
   - ✅ "Create groups" is selected
   - ❌ "Copy items if needed" is **NOT** checked
   - ✅ "Add to targets: Psychosis" is checked
6. Click "Add"

## Verify Files Are Added

After adding, you should see in Project Navigator:
```
Features
├── Home
├── Settings
├── Detail
├── Profile
├── Search
├── Favorites      ← Should appear
├── Notifications  ← Should appear
└── History        ← Should appear
```

## Build and Run

1. Press **⌘B** to build
2. Should build successfully
3. Press **⌘R** to run
4. You should see **7 tabs** at the bottom

## Troubleshooting

### If files still don't appear:

1. Check File Inspector (right sidebar):
   - Select a file
   - Under "Target Membership", ensure "Psychosis" is checked

2. Clean build folder:
   - Product → Clean Build Folder (⇧⌘K)
   - Then rebuild (⌘B)

3. Verify file paths:
   - Files should be in: `Psychosis/Features/[FeatureName]/Views/[FeatureName]View.swift`

---

**After adding these files, the build should succeed and you'll have 7 tabs!**

