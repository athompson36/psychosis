# Platform Support: Psychosis

## Overview

Psychosis is available on **two platforms**:

1. **Web App** (PWA) - Browser-based, works everywhere
2. **Native iOS/iPadOS App** - Native performance, better mobile experience

Both platforms share the same backend API and provide identical functionality.

---

## Web App (`apps/hub-frontend`)

### Technology
- **React** 18+ with **Vite**
- **PWA** (Progressive Web App)
- **Liquid Glass** theme

### Advantages
- ✅ Works on any device with a browser
- ✅ No App Store approval needed
- ✅ Easy to deploy and update
- ✅ Cross-platform (iOS, Android, Desktop)
- ✅ "Add to Home Screen" for app-like experience

### Usage
- Primary: iPhone/iPad via Safari
- Secondary: Desktop browsers
- Access: WireGuard VPN or Cloudflare

### Setup
```bash
cd apps/hub-frontend
npm install
npm run dev
```

---

## iOS/iPadOS App (`apps/hub-ios`)

### Technology
- **SwiftUI** for UI
- **Swift** 5.9+
- **MVVM** architecture
- **async/await** for networking

### Advantages
- ✅ Native performance
- ✅ Better file handling
- ✅ Native iOS features
- ✅ Offline support
- ✅ Better integration with iOS
- ✅ App Store distribution

### Requirements
- iOS 17.0+
- iPadOS 17.0+
- Xcode 15.0+

### Setup
1. Create Xcode project in `apps/hub-ios/`
2. Add files from `HubApp/` folder
3. See `PROJECT_SETUP.md` for details
4. Build and run

---

## Shared Backend

Both platforms use the same **Node.js + Express** backend:

- `/api/tools` - List development tools
- `/api/files/*` - File operations
- `/api/chat` - AI coding assistant

---

## Feature Parity

Both platforms provide:

- ✅ Tool selector (Dev Remote, VS Code, Xcode)
- ✅ Responsive split views (portrait/landscape)
- ✅ Chat tab (AI coding assistant)
- ✅ Editor tab (code editing)
- ✅ Files tab (file browser)
- ✅ Liquid Glass theme
- ✅ Connection status

---

## Development Workflow

### Web App Development
```bash
cd apps/hub-frontend
npm run dev
# Test at http://localhost:5173
```

### iOS App Development
1. Open Xcode project
2. Make changes in Swift files
3. Build and run (⌘R)
4. Test on simulator or device

### Backend Development
```bash
cd apps/hub-backend
npm start
# API at http://localhost:3000/api
```

---

## Code Sharing

### Shared Models
- File structures
- API request/response models
- Data types

### Shared Logic
- API endpoints
- Business logic (in backend)
- UI patterns (similar implementations)

### Platform-Specific
- **Web**: React components, CSS
- **iOS**: SwiftUI views, Swift code

---

## Deployment

### Web App
- Deploy to any web server
- Serve via nginx/Cloudflare
- Access via WireGuard VPN or public URL

### iOS App
- Build in Xcode
- TestFlight for beta testing
- App Store for distribution

---

## Choosing a Platform

### Use Web App if:
- You want quick access without installation
- You need cross-platform support
- You want easy updates
- You're testing/developing

### Use iOS App if:
- You want native performance
- You need better file handling
- You want App Store distribution
- You prefer native iOS experience

### Use Both:
- Web for quick access
- iOS for daily use
- Both share the same backend

---

*Both platforms are actively developed and maintained.*

