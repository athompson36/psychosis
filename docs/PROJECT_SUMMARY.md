# Project Summary: Psychosis (FS-Tech Liquid Glass)

## Current Project State

**Status**: 🟢 Phase 0 - Initialization (In Progress)  
**Last Updated**: [Current Date]  
**Repository**: ✅ Initialized and pushed to GitHub  
**Project Type**: Dual-Platform (Web App + iOS App)

---

## Project Overview

**Psychosis** is a mobile-first, Liquid Glass–themed control cockpit for remote development. It provides a phone-optimized UI to browse/edit code, chat with AI about repositories, and view desktop-only tools (Xcode) via remote-screen sessions.

### Key Goals

- **Remote Code Access**: Browse and edit code via Dev Remote and VS Code/code-server
- **AI Coding Assistant**: Chat with AI about the current repository
- **Remote Desktop Tools**: View Xcode and other desktop tools via remote-screen sessions
- **Mobile-Optimized**: Portrait (top/bottom split) and landscape (side-by-side split) layouts
- **Secure Access**: WireGuard VPN integration with optional Cloudflare exposure

---

## Project Structure

```
psychosis/
├── apps/
│   ├── psychosis-backend/          # Node.js + Express server
│   │   ├── /api/tools        # List registered tools
│   │   ├── /api/files/*      # File tree & content
│   │   └── /api/chat         # AI coding assistant
│   │
│   └── psychosis-frontend/         # React + Vite PWA
│       ├── EditorBar         # Tool selector
│       ├── MainPane          # Split view container
│       └── Tabs              # Chat / Editor / Files
│
├── docs/                     # Documentation
│   ├── ARCHITECTURE.md       # System architecture
│   ├── PROJECT_REQUIREMENTS.md
│   └── ...
└── README.md                 # Main README
```

---

## Technology Stack

### Backend
- **Node.js** 18+
- **Express.js** - RESTful API
- **OpenAI API** - AI coding assistant

### Frontend
- **React** 18+
- **Vite** - Build tool
- **PWA** - Progressive Web App
- **Liquid Glass Theme** - Modern glassmorphism design

### Infrastructure
- **WireGuard VPN** - Primary access method
- **Cloudflare** (optional) - External access with auth
- **nginx** (optional) - Reverse proxy

---

## Development Phases

### Phase 0: Project Initialization ⏳ (Current)
- [x] Define project requirements
- [x] Initialize Git repository
- [x] Create documentation structure
- [ ] Set up backend project structure
- [ ] Set up frontend project structure

### Phase 1: Backend Foundation 📋 (Weeks 1-2)
- [ ] Express server setup
- [ ] `/api/tools` endpoint
- [ ] `/api/files/*` endpoints
- [ ] File system integration
- [ ] Basic authentication

### Phase 2: Frontend Foundation 🎨 (Weeks 2-3)
- [ ] React + Vite setup
- [ ] Liquid Glass theme implementation
- [ ] EditorBar component
- [ ] MainPane with split views
- [ ] Tab system

### Phase 3: Core Features 🔧 (Weeks 3-6)
- [ ] File browser component
- [ ] Code editor integration
- [ ] AI chat interface
- [ ] Tool selector
- [ ] Responsive layouts (portrait/landscape)

### Phase 4: AI Integration 🤖 (Weeks 6-7)
- [ ] OpenAI API integration
- [ ] Context-aware chat
- [ ] Repository context collection
- [ ] Code suggestions

### Phase 5: PWA & Polish ✨ (Weeks 7-8)
- [ ] Service worker
- [ ] PWA manifest
- [ ] Offline support
- [ ] Performance optimization
- [ ] UI/UX polish

### Phase 6: Integration & Testing 🧪 (Weeks 8-9)
- [ ] WireGuard integration
- [ ] Tool integrations (Dev Remote, VS Code, Xcode)
- [ ] End-to-end testing
- [ ] Security audit

### Phase 7: Deployment 🚀 (Week 10)
- [ ] Production setup
- [ ] Cloudflare configuration (if needed)
- [ ] Documentation
- [ ] Launch

---

## Key Documents

### For Planning
- **`PROJECT_REQUIREMENTS.md`**: Complete feature requirements
- **`ARCHITECTURE.md`**: System architecture and design decisions
- **`PRODUCTION_ROADMAP.md`**: Detailed development roadmap

### For Development
- **`WORKFLOW.md`**: Day-to-day development workflow
- **`CURSOR_CONTEXT.md`**: AI-assisted development guidelines

---

## Immediate Next Steps

### 🔴 Critical (Do First)
1. **Set up backend project**
   ```bash
   mkdir -p apps/psychosis-backend
   cd apps/psychosis-backend
   npm init -y
   npm install express
   ```

2. **Set up frontend project**
   ```bash
   mkdir -p apps/psychosis-frontend
   cd apps/psychosis-frontend
   npm create vite@latest . -- --template react
   ```

3. **Create basic server structure**
   - Express server with routes
   - API endpoints skeleton
   - File service setup

4. **Create basic frontend structure**
   - React app setup
   - Liquid Glass theme CSS
   - Component structure

### 🟠 High Priority (Week 1)
- Implement `/api/tools` endpoint
- Create EditorBar component
- Set up MainPane with split views
- Basic file browser

---

## Project Health

### ✅ Completed
- Project requirements defined
- Architecture documented
- Git repository initialized
- Documentation structure created

### 🟡 In Progress
- Project structure setup
- Backend initialization
- Frontend initialization

### ❌ Not Started
- Backend API implementation
- Frontend components
- AI integration
- PWA setup
- Tool integrations

---

## Technical Decisions

### Backend
- [x] Node.js + Express ✅
- [x] RESTful API ✅
- [ ] Authentication method (TBD)
- [ ] Database (if needed)

### Frontend
- [x] React + Vite ✅
- [x] PWA ✅
- [x] Liquid Glass theme ✅
- [ ] State management (Context/Redux)
- [ ] Code editor library (Monaco/CodeMirror)

### Infrastructure
- [x] WireGuard VPN ✅
- [ ] Cloudflare (optional)
- [ ] nginx (optional)

---

## Resources

### Documentation
- See `docs/` folder for all documentation
- `ARCHITECTURE.md` for system design
- `PROJECT_REQUIREMENTS.md` for features

### External Resources
- [Express.js Documentation](https://expressjs.com/)
- [React Documentation](https://react.dev/)
- [Vite Documentation](https://vitejs.dev/)
- [PWA Guide](https://web.dev/progressive-web-apps/)

---

## Notes

- This is a **mobile-first** web application, not a native iOS app
- Primary access via **WireGuard VPN** for security
- **PWA** provides native-like experience without App Store
- **Liquid Glass** theme for modern, elegant UI

---

## Quick Links

- [Architecture](./ARCHITECTURE.md)
- [Project Requirements](./PROJECT_REQUIREMENTS.md)
- [Workflow Guide](./WORKFLOW.md)
- [Cursor Context](./CURSOR_CONTEXT.md)

---

*Last Updated: [Current Date]*  
*Version: 1.0*
