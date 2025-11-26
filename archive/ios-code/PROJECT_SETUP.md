# Xcode Project Setup Instructions

## Current Status

The project structure has been created with the following organization:

```
XcodeProject/
└── Psychosis/
    ├── App/
    │   ├── PsychosisApp.swift
    │   └── ContentView.swift
    ├── Core/
    │   ├── Networking/
    │   │   └── APIClient.swift
    │   ├── Storage/
    │   │   └── StorageManager.swift
    │   ├── Utilities/
    │   │   └── Constants.swift
    │   └── UI/
    │       └── Themes/
    │           └── AppTheme.swift
    ├── Features/
    │   └── (Feature folders will be added here)
    ├── Resources/
    │   └── (Assets, strings, fonts will go here)
    └── Tests/
        └── UnitTests/
            └── PsychosisTests.swift
```

## Next Steps: Create Xcode Project

### Option 1: Create New Xcode Project (Recommended)

1. **Open Xcode**
2. **File → New → Project**
3. **Choose Template**:
   - Select "iOS" tab
   - Choose "App"
   - Click "Next"
4. **Configure Project**:
   - **Product Name**: `Psychosis`
   - **Team**: Select your development team
   - **Organization Identifier**: `com.yourcompany` (or your domain)
   - **Bundle Identifier**: Will auto-populate
   - **Interface**: **SwiftUI**
   - **Language**: **Swift**
   - **Storage**: None (or Core Data if needed later)
   - **Include Tests**: ✅ Check this
5. **Save Location**:
   - Navigate to: `/Users/andrew/Documents/fs-tech/psychosis/XcodeProject/`
   - **IMPORTANT**: Save the project file here, but the project folder should be `Psychosis.xcodeproj`
6. **After Creation**:
   - Delete the default `ContentView.swift` that Xcode creates (we have our own)
   - Delete the default `PsychosisApp.swift` that Xcode creates (we have our own)
   - Add existing files to the project:
     - Right-click on project in navigator
     - "Add Files to Psychosis..."
     - Select the `Psychosis/` folder
     - Make sure "Create groups" is selected
     - Make sure "Copy items if needed" is **NOT** selected (files are already in place)
     - Click "Add"

### Option 2: Use Command Line (Advanced)

If you prefer command line, you can use `xcodegen` or create the project manually, but Option 1 is recommended.

## Project Configuration

After creating the project, configure:

1. **Build Settings**:
   - **iOS Deployment Target**: 17.0
   - **Swift Language Version**: Swift 5.9

2. **Signing & Capabilities**:
   - Configure your development team
   - Add capabilities as needed (Push Notifications, etc.)

3. **Project Structure**:
   - Organize files into groups matching the folder structure
   - Create groups for: App, Core, Features, Resources, Tests

## Verify Setup

1. **Build the project**: ⌘B
   - Should build without errors
2. **Run in simulator**: ⌘R
   - Should launch and show "Welcome to Psychosis"
3. **Run tests**: ⌘U
   - Should run the example test

## Adding New Files

When adding new files:
- Place them in the appropriate folder in `Psychosis/`
- Add them to the Xcode project
- Maintain the folder structure

## Notes

- The project structure follows MVVM architecture
- All files are organized by feature and layer
- Tests are separated into Unit, Integration, and UI tests
- Resources (assets, strings) go in the Resources folder

---

*Once the Xcode project is created, update this document with any project-specific notes.*

