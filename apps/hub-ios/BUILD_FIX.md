# Fix: Multiple Commands Produce stringsdata Error

## Root Cause

The error occurs because Xcode is compiling files from **two locations**:

1. **`Psychosis/Psychosis/`** folder - Files created by Xcode (auto-synchronized)
2. **`apps/hub-ios/HubApp/`** folder - Files manually added to project

Both `PsychosisApp.swift` and `ContentView.swift` exist in both locations and are being compiled twice.

## Solution Options

### Option 1: Use Only Xcode-Created Files (Recommended)

1. **Delete manually added files** from project:
   - In Xcode Project Navigator, find files under `HubApp/` folder
   - Select them and press Delete → "Remove Reference"
   
2. **Copy content** from `apps/hub-ios/HubApp/` files to `Psychosis/Psychosis/` files:
   - Copy code from `apps/hub-ios/HubApp/App/PsychosisApp.swift` to `Psychosis/Psychosis/PsychosisApp.swift`
   - Copy code from `apps/hub-ios/HubApp/App/ContentView.swift` to `Psychosis/Psychosis/ContentView.swift`
   - Copy other feature files to `Psychosis/` folder structure

3. **Clean and rebuild**:
   - Product → Clean Build Folder (⇧⌘K)
   - Product → Build (⌘B)

### Option 2: Remove Auto-Synchronized Group

1. **In Xcode**, select the project
2. **Select target** → Build Phases
3. **Remove** the `Psychosis` folder from "Compile Sources"
4. **Keep** only manually added files from `apps/hub-ios/HubApp/`

### Option 3: Use One Location Only

**Recommended**: Move all files to `Psychosis/` folder and remove `apps/hub-ios/HubApp/` references.

## Quick Fix Steps

1. **Open Xcode** with `Psychosis.xcodeproj`

2. **Check Project Navigator**:
   - Look for duplicate `PsychosisApp.swift` entries
   - Look for duplicate `ContentView.swift` entries

3. **Remove duplicates**:
   - Select duplicate file → Delete → "Remove Reference"
   - Keep only ONE copy of each file

4. **Verify Build Phases**:
   - Select project → Target → Build Phases → Compile Sources
   - `PsychosisApp.swift` should appear ONCE
   - `ContentView.swift` should appear ONCE

5. **Clean and rebuild**:
   - ⇧⌘K (Clean Build Folder)
   - ⌘B (Build)

## Current File Locations

- ✅ `Psychosis/Psychosis/PsychosisApp.swift` (Xcode-created)
- ✅ `Psychosis/Psychosis/ContentView.swift` (Xcode-created)
- ⚠️ `apps/hub-ios/HubApp/App/PsychosisApp.swift` (manually added - duplicate)
- ⚠️ `apps/hub-ios/HubApp/App/ContentView.swift` (manually added - duplicate)
- ❌ `apps/hub-ios/HubApp/App/HubApp.swift` (old name - should be deleted)

## After Fix

The project should compile with only ONE set of files being compiled.

