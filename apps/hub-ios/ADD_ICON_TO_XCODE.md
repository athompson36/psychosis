# Adding App Icon to Xcode Project

## ✅ Icon Set Created

The complete iOS App Icon set has been generated from `icons/icon_starter.png` with all required sizes:

- ✅ iPhone icons (20pt, 29pt, 40pt, 60pt @2x and @3x)
- ✅ iPad icons (20pt, 29pt, 40pt, 76pt, 83.5pt @1x and @2x)
- ✅ App Store icon (1024x1024)

**Location**: `apps/hub-ios/HubApp/Resources/Assets.xcassets/AppIcon.appiconset/`

## Step 1: Add Assets.xcassets to Xcode

1. **Open Xcode** with `Psychosis.xcodeproj`

2. In **Project Navigator**, right-click on the project root or **Resources** folder

3. Select **"Add Files to 'Psychosis'..."**

4. Navigate to `apps/hub-ios/HubApp/Resources/`

5. Select the **`Assets.xcassets`** folder (entire folder)

6. **IMPORTANT**:
   - ✅ **"Create folder references"** (for asset catalogs)
   - ❌ **"Copy items if needed"** - UNCHECKED
   - ✅ **"Add to targets: Psychosis"** - CHECKED

7. Click **"Add"**

## Step 2: Configure App Icon in Target Settings

1. Select **Psychosis** project (blue icon) in Project Navigator

2. Select **Psychosis** target (under TARGETS)

3. Click **General** tab

4. Scroll down to **App Icons and Launch Screen** section

5. Under **App Icons Source**, click the dropdown

6. Select **`Assets.xcassets/AppIcon`**

   If it's not in the dropdown:
   - Make sure `Assets.xcassets` is added to the project (Step 1)
   - Clean build folder (⇧⌘K) and rebuild

## Step 3: Verify Icon Set

1. In **Project Navigator**, expand **Assets.xcassets**

2. Click on **AppIcon**

3. You should see all icon slots filled with the generated icons:
   - iPhone: 20pt, 29pt, 40pt, 60pt (all scales)
   - iPad: 20pt, 29pt, 40pt, 76pt, 83.5pt (all scales)
   - iOS Marketing (App Store): 1024x1024

4. If any slots show as empty or have warnings:
   - Verify all icon files exist in `AppIcon.appiconset/` folder
   - Check that `Contents.json` references the correct filenames

## Step 4: Test the Icon

1. **Clean build folder**: Product → Clean Build Folder (⇧⌘K)

2. **Build the project**: Product → Build (⌘B)

3. **Run on simulator or device**: Product → Run (⌘R)

4. The app icon should appear:
   - On the home screen (simulator/device)
   - In the app switcher
   - In Settings (if applicable)

## Troubleshooting

### Icon not appearing in Xcode

- Make sure `Assets.xcassets` is added as a **folder reference** (blue folder icon), not a group
- Verify the folder is added to the **Psychosis** target in Build Phases

### Icon slots showing as empty

- Check that all icon files exist in the `AppIcon.appiconset/` folder
- Verify `Contents.json` has correct filenames matching the actual files
- Try regenerating icons using: `./create_icon_set.sh icons/icon_starter.png apps/hub-ios/HubApp/Resources/Assets.xcassets/AppIcon.appiconset`

### Icon not showing on device/simulator

- Clean build folder and rebuild
- Delete app from simulator/device and reinstall
- Check that "App Icons Source" is set to `Assets.xcassets/AppIcon` in target settings

## Regenerating Icons

If you need to regenerate the icon set:

```bash
cd /Users/andrew/Documents/fs-tech/psychosis
./apps/hub-ios/create_icon_set.sh icons/icon_starter.png apps/hub-ios/HubApp/Resources/Assets.xcassets/AppIcon.appiconset
```

This will regenerate all icon sizes from the source image.

