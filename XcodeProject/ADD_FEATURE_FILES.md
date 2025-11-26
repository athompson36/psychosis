# Adding Feature Files to Xcode Project

The Home feature has been created with full MVVM structure. Follow these steps to add it to your Xcode project:

## Steps to Add Home Feature

1. **Open Xcode** with your `Psychosis.xcodeproj` project

2. **Add the Home feature folder**:
   - Right-click on the project in the Project Navigator
   - Select "Add Files to Psychosis..."
   - Navigate to `Psychosis/Features/Home/`
   - Select the entire `Home` folder (or individual subfolders)
   - Make sure:
     - ✅ "Create groups" is selected
     - ❌ "Copy items if needed" is **NOT** checked (files are already in place)
     - ✅ "Add to targets: Psychosis" is checked
   - Click "Add"

3. **Verify file structure in Xcode**:
   Your Project Navigator should show:
   ```
   Psychosis
   ├── Features
   │   └── Home
   │       ├── Models
   │       │   └── HomeItem.swift
   │       ├── ViewModels
   │       │   └── HomeViewModel.swift
   │       └── Views
   │           └── HomeView.swift
   ```

4. **Build the project**: ⌘B
   - Should build successfully
   - HomeView should now be available

5. **Run the app**: ⌘R
   - Should show the new Home screen with welcome message and items

## Alternative: Add Individual Files

If adding the folder doesn't work, add files individually:

1. **Add Models**:
   - Add `Features/Home/Models/HomeItem.swift`
   - Target: Psychosis

2. **Add ViewModels**:
   - Add `Features/Home/ViewModels/HomeViewModel.swift`
   - Target: Psychosis

3. **Add Views**:
   - Add `Features/Home/Views/HomeView.swift`
   - Target: Psychosis

## What You'll See

After adding the files and running the app:

- **Home Screen** with:
  - Welcome header
  - App name and version
  - List of quick action items
  - Pull-to-refresh support
  - Loading states
  - Error handling

## Features Included

✅ **MVVM Architecture**:
- Model: `HomeItem` (data structure)
- ViewModel: `HomeViewModel` (business logic)
- View: `HomeView` (UI)

✅ **Functionality**:
- Data loading with async/await
- Local storage integration
- Pull-to-refresh
- Error handling
- Loading states
- Empty states

✅ **UI/UX**:
- Uses AppTheme for consistent styling
- Responsive layout
- Modern SwiftUI design
- Accessibility ready

---

*Once files are added, the app will use HomeView as the main screen!*

