# iOS Project Setup

## Creating the Xcode Project

1. **Open Xcode**
2. **File → New → Project...**
3. Select **iOS → App**
4. Configure:
   - **Product Name**: `HubApp`
   - **Team**: Your development team
   - **Organization Identifier**: `com.fstech` (or your choice)
   - **Interface**: SwiftUI
   - **Language**: Swift
   - **Storage**: None (we'll use UserDefaults/API)
5. **Save location**: `apps/hub-ios/`
6. Click **Create**

## Adding Files to Xcode

After creating the project, add the files we've created:

1. **Right-click** on the project in Navigator
2. **Add Files to "HubApp"...**
3. Navigate to `apps/hub-ios/HubApp/`
4. Select all folders:
   - `App/`
   - `Features/`
   - `Core/`
   - `Resources/`
5. **IMPORTANT**:
   - ✅ **"Create groups"** (not folder references)
   - ❌ **"Copy items if needed"** - UNCHECKED
   - ✅ **"Add to targets: HubApp"** - CHECKED
6. Click **Add**

## Project Structure in Xcode

After adding files, your project should look like:

```
HubApp
├── App
│   ├── HubApp.swift
│   └── ContentView.swift
├── Features
│   ├── EditorBar
│   │   └── EditorBarView.swift
│   ├── MainPane
│   │   └── MainPaneView.swift
│   ├── Chat
│   │   └── ChatView.swift
│   ├── Editor
│   │   └── EditorView.swift
│   └── FileBrowser
│       └── FileBrowserView.swift
├── Core
│   ├── Models
│   │   └── FileItem.swift
│   ├── Networking
│   │   └── APIClient.swift
│   └── Extensions
│       └── Color+Hex.swift
└── Resources
```

## Configuration

### Info.plist Settings

Add to `Info.plist`:
- **App Transport Security Settings**:
  - **Allow Arbitrary Loads**: YES (for localhost development)
  - Or add specific domain exceptions

### Build Settings

- **iOS Deployment Target**: 17.0
- **Swift Language Version**: Swift 5.9

## Running the App

1. Select a simulator or device
2. Press **⌘R** to build and run
3. The app should launch with the Liquid Glass UI

## Testing

- Test on **iPhone** (portrait/landscape)
- Test on **iPad** (better split view experience)
- Test API connectivity (backend must be running)

## Next Steps

1. Connect to backend API
2. Add Monaco Editor for better code editing
3. Implement file saving
4. Add error handling
5. Polish UI animations

