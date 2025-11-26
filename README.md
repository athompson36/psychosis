# FS-Remote Hub (FS-Tech Liquid Glass)

A mobile-first, Liquid Glass–themed control cockpit for fs-dev.

## Overview

This project provides a phone-optimized UI to:

- **Browse/edit code** via Dev Remote and VS Code/code-server
- **Chat with AI** about the current repo
- **View desktop-only tools** (Xcode) via remote-screen sessions

## Features

- **Portrait mode**: Top/bottom split layout
- **Landscape mode**: Side-by-side split layout
- **WireGuard integration**: Secure VPN access
- **Optional Cloudflare exposure**: External access with strong auth
- **PWA support**: Add to Home Screen for native-like experience

## Project Structure

```
psychosis/
├── apps/
│   ├── hub-backend/          # Node/Express server
│   │   ├── /api/tools       # List registered tools (Dev Remote, VS Code, Xcode)
│   │   ├── /api/files/*     # File tree & content for configured repo
│   │   └── /api/chat        # Coding assistant endpoint (OpenAI)
│   │
│   └── hub-frontend/        # React + Vite PWA
│       ├── Top editor bar   # Xcode / VS Code / Dev Remote
│       ├── MainPane         # Portrait top/bottom, landscape side-by-side
│       └── Tabs             # Chat / Editor / Files + Split toggle
│
├── docs/                    # Documentation
└── README.md                # This file
```

## Tech Stack

### Backend
- **Node.js** + **Express**
- **API endpoints** for tools, files, and chat

### Frontend
- **React** + **Vite**
- **PWA** (Progressive Web App)
- **Liquid Glass** theme
- **Responsive design** (portrait/landscape)

## Usage

### Primary Mode
1. Connect iPhone to WireGuard VPN
2. Open hub in Safari
3. "Add to Home Screen" for PWA experience

### Optional: External Access
- Expose behind nginx/Cloudflare
- Strong authentication required
- Secure external access

## Development

### Prerequisites
- Node.js 18+
- npm or yarn
- WireGuard VPN (for local development)

### Setup
```bash
# Install dependencies
cd apps/hub-backend && npm install
cd ../hub-frontend && npm install

# Start backend
cd apps/hub-backend && npm start

# Start frontend
cd apps/hub-frontend && npm run dev
```

## Architecture

- **Backend**: RESTful API with Express
- **Frontend**: React SPA with Vite
- **PWA**: Service worker for offline support
- **Theme**: Liquid Glass design system

## License

[To be determined]

---

*FS-Tech Liquid Glass - Remote Development Hub*
