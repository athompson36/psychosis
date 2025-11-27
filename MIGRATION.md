# Migration Note: From iOS App to Web App

## What Happened

The project was initially set up as an iOS SwiftUI application, but the actual project is a **web application** (React + Node.js) for remote development.

## Current State

- ✅ **Documentation updated** - All docs now reflect correct project
- ⚠️ **iOS code exists** - `XcodeProject/` contains incorrect SwiftUI code
- ⚠️ **Project structure** - Needs to be restructured for web app

## Next Steps

### 1. Archive iOS Code (Optional)
The iOS SwiftUI code in `XcodeProject/` can be:
- **Deleted** (if not needed)
- **Archived** to `archive/ios-code/` (if you want to keep it)
- **Ignored** (it won't affect the web app)

### 2. Create Correct Project Structure
```bash
# Create backend
mkdir -p apps/psychosis-backend/src/{routes,services,middleware}
cd apps/psychosis-backend && npm init -y

# Create frontend
mkdir -p apps/psychosis-frontend/src/{components,hooks,services,styles}
cd apps/psychosis-frontend && npm create vite@latest . -- --template react
```

### 3. Remove/Archive iOS Code
```bash
# Option 1: Archive it
mkdir -p archive
mv XcodeProject archive/ios-code

# Option 2: Delete it
rm -rf XcodeProject
```

## Correct Project Structure

```
psychosis/
├── apps/
│   ├── psychosis-backend/      # Node.js + Express
│   └── psychosis-frontend/     # React + Vite PWA
├── docs/                 # Documentation
└── README.md
```

## Important Notes

- This is a **web application**, not a native iOS app
- It runs in **Safari** as a PWA
- Backend is **Node.js + Express**
- Frontend is **React + Vite**
- Access via **WireGuard VPN** (primary) or **Cloudflare** (optional)

---

*Migration completed: [Current Date]*



