# Add RemoteServerManager to Xcode Project

## Issue
Build error: `Cannot find 'RemoteServerManager' in scope`

## Solution

The `RemoteServerManager.swift` file exists but needs to be added to the Xcode project.

### Steps:

1. **Open Xcode** with `Psychosis.xcodeproj`

2. In **Project Navigator**, right-click on **Core → Services** folder (or create it if it doesn't exist)

3. Select **"Add Files to 'Psychosis'..."**

4. Navigate to `apps/psychosis-ios/PsychosisApp/Core/Services/`

5. Select `RemoteServerManager.swift`

6. **IMPORTANT**:
   - ✅ **"Create groups"** (NOT folder references)
   - ❌ **"Copy items if needed"** - UNCHECKED
   - ✅ **"Add to targets: Psychosis"** - CHECKED

7. Click **"Add"**

8. Also add `AddRemoteServerView.swift`:
   - Navigate to `apps/psychosis-ios/PsychosisApp/Features/Settings/`
   - Select `AddRemoteServerView.swift`
   - Same settings as above

9. **Verify in Build Phases**:
   - Project → Target → Build Phases → Compile Sources
   - Verify `RemoteServerManager.swift` and `AddRemoteServerView.swift` are in the list

10. **Clean and Build**:
    - Product → Clean Build Folder (⇧⌘K)
    - Product → Build (⌘B)

## Expected Result

After adding these files:
- ✅ Build should succeed
- ✅ RemoteServerManager will be accessible
- ✅ Add/Edit server functionality will work

