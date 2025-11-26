# Adding Core Files to Xcode Project

The Core infrastructure files have been created but need to be added to your Xcode project. Follow these steps:

## Steps to Add Core Files

1. **Open Xcode** with your `Psychosis.xcodeproj` project

2. **Add Core/Networking files**:
   - Right-click on the project in the Project Navigator
   - Select "Add Files to Psychosis..."
   - Navigate to `Psychosis/Core/Networking/`
   - Select `APIClient.swift`
   - Make sure:
     - ✅ "Copy items if needed" is **NOT** checked (files are already in place)
     - ✅ "Create groups" is selected
     - ✅ "Add to targets: Psychosis" is checked
   - Click "Add"

3. **Add Core/Storage files**:
   - Right-click on the project
   - Select "Add Files to Psychosis..."
   - Navigate to `Psychosis/Core/Storage/`
   - Select `StorageManager.swift`
   - Same settings as above
   - Click "Add"

4. **Add Core/Utilities files**:
   - Right-click on the project
   - Select "Add Files to Psychosis..."
   - Navigate to `Psychosis/Core/Utilities/`
   - Select `Constants.swift`
   - Same settings as above
   - Click "Add"

5. **Add Core/UI/Themes files**:
   - Right-click on the project
   - Select "Add Files to Psychosis..."
   - Navigate to `Psychosis/Core/UI/Themes/`
   - Select `AppTheme.swift`
   - Same settings as above
   - Click "Add"

## Alternative: Add Entire Core Folder

You can add the entire Core folder at once:

1. Right-click on the project in Project Navigator
2. Select "Add Files to Psychosis..."
3. Navigate to and select the `Psychosis/Core/` folder
4. Make sure:
   - ✅ "Create groups" is selected
   - ❌ "Copy items if needed" is **NOT** checked
   - ✅ "Add to targets: Psychosis" is checked
5. Click "Add"

## Verify

After adding the files:

1. **Build the project**: ⌘B
   - Should build without errors

2. **Check Project Navigator**:
   - You should see the Core folder with all subfolders
   - Files should appear in the correct groups

3. **Update ContentView** (optional):
   - Once files are added, you can update `ContentView.swift` to use `AppTheme` and `Constants`
   - See the updated version in the codebase

## Project Structure After Adding

Your Project Navigator should show:

```
Psychosis
├── Psychosis
│   ├── PsychosisApp.swift
│   ├── ContentView.swift
│   └── Assets.xcassets
├── Core
│   ├── Networking
│   │   └── APIClient.swift
│   ├── Storage
│   │   └── StorageManager.swift
│   ├── Utilities
│   │   └── Constants.swift
│   └── UI
│       └── Themes
│           └── AppTheme.swift
├── Features
└── Resources
```

---

*Once all files are added, the project will be ready for feature development!*

