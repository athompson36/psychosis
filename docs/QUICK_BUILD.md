# Quick Build Instructions

## Step 1: Add Files to Xcode

The new VNC files need to be added to the Xcode project:

```bash
# From project root
ruby apps/psychosis-ios/add_vnc_files_to_xcode.rb
```

Or manually in Xcode:
1. Right-click on "Core" group → "Add Files to Psychosis..."
2. Select `PsychosisApp/Core/VNC/` folder
3. ✅ "Create groups"
4. ✅ "Add to targets: Psychosis"
5. Repeat for other new files

## Step 2: Open Xcode

```bash
open Psychosis/Psychosis.xcodeproj
```

## Step 3: Build

1. **Select target device** (iPhone recommended)
2. **Build (⌘B)** or **Run (⌘R)**
3. **Fix any errors:**
   - Missing files → Add to project
   - CommonCrypto errors → Add Security framework
   - Import errors → Check file paths

## Step 4: Test

1. **Configure server:**
   - Host: `192.168.4.100`
   - Port: `5900`
   - Password: Your VNC password

2. **Connect and test:**
   - Select server
   - Verify connection
   - Test pane switching

---

## Common Issues

### "No such module 'CommonCrypto'"
- Add Security framework to project
- Or configure bridging header

### "Cannot find 'VNCConnection'"
- Ensure file is added to Xcode project
- Check target membership

### Build succeeds but app crashes
- Check console for errors
- Verify all dependencies

---

**Ready to build!** 🚀


