# Creating the Xcode Project

The project structure and source files are ready. You have two options to create the Xcode project file:

## Option 1: Using Xcode (Recommended - Easiest)

1. **Open Xcode**
2. **File → New → Project**
3. **Choose Template**:
   - Select "iOS" tab
   - Choose "App"
   - Click "Next"
4. **Configure Project**:
   - **Product Name**: `Psychosis`
   - **Team**: Select your development team
   - **Organization Identifier**: `com.psychosis` (or your domain)
   - **Bundle Identifier**: Will auto-populate as `com.psychosis.Psychosis`
   - **Interface**: **SwiftUI** ✅
   - **Language**: **Swift** ✅
   - **Storage**: None
   - **Include Tests**: ✅ Check this
5. **Save Location**:
   - Navigate to: `/Users/andrew/Documents/fs-tech/psychosis/XcodeProject/`
   - **IMPORTANT**: Make sure you're saving in the `XcodeProject/` folder
   - Click "Create"
6. **After Creation**:
   - Delete the default files Xcode created:
     - `PsychosisApp.swift` (we have our own)
     - `ContentView.swift` (we have our own)
   - **Add Existing Files**:
     - Right-click on "Psychosis" group in Project Navigator
     - Select "Add Files to Psychosis..."
     - Navigate to and select the `Psychosis/` folder
     - Make sure:
       - ✅ "Create groups" is selected
       - ❌ "Copy items if needed" is **NOT** selected (files are already in place)
       - ✅ "Add to targets: Psychosis" is checked
     - Click "Add"
   - **Add Test Files**:
     - Right-click on "PsychosisTests" group
     - Add Files to PsychosisTests...
     - Select `PsychosisTests/` folder
     - Same settings as above
     - Click "Add"
7. **Configure Project Settings**:
   - Select the project in navigator
   - Under "Deployment Info":
     - Set **iOS Deployment Target** to **17.0**
   - Under "Build Settings":
     - Search for "Swift Language Version"
     - Set to **Swift 5**
   - Under "Signing & Capabilities":
     - Select your development team
     - Update Bundle Identifier if needed (should be `com.psychosis.app`)

8. **Build and Run**:
   - Press ⌘B to build
   - Press ⌘R to run in simulator
   - Should see "Welcome to Psychosis" screen

## Option 2: Using xcodegen (Advanced)

If you have `xcodegen` installed:

```bash
cd XcodeProject
xcodegen generate
```

To install xcodegen:
```bash
brew install xcodegen
```

Then run:
```bash
cd XcodeProject
xcodegen generate
```

This will create `Psychosis.xcodeproj` from the `project.yml` file.

## Verification

After creating the project:

1. **Build**: ⌘B (should succeed)
2. **Run**: ⌘R (should launch simulator)
3. **Tests**: ⌘U (should run tests)

## Project Structure

Your project should have this structure in Xcode:

```
Psychosis
├── App
│   ├── PsychosisApp.swift
│   └── ContentView.swift
├── Core
│   ├── Networking
│   │   └── APIClient.swift
│   ├── Storage
│   │   └── StorageManager.swift
│   ├── Utilities
│   │   ├── Constants.swift
│   │   ├── Extensions
│   │   └── Helpers
│   └── UI
│       ├── Components
│       ├── Themes
│       │   └── AppTheme.swift
│       └── Styles
├── Features
└── Resources
    ├── Assets.xcassets
    └── Preview Content
        └── Preview Assets.xcassets

PsychosisTests
└── PsychosisTests.swift
```

## Troubleshooting

### Build Errors
- Make sure all files are added to the correct targets
- Check that Swift version is set to 5.0 or higher
- Verify iOS deployment target is 17.0

### Missing Files
- Re-add files using "Add Files to Psychosis..." if they're missing
- Make sure file references are correct in Project Navigator

### Test Target Issues
- Verify PsychosisTests target has Psychosis as a dependency
- Check that test files are added to PsychosisTests target

---

*Once the project is created and building successfully, you can proceed with feature development!*

