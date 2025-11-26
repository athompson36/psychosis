# Project Requirements: Psychosis (FS-Tech Liquid Glass)

## Project Overview

**Project Name**: Psychosis  
**Status**: In Development  
**Version**: 0.1.0  
**Last Updated**: [Current Date]

---

## Purpose & Vision

**Psychosis** is a mobile-first, Liquid Glass–themed control cockpit for fs-dev that enables remote development workflows from an iPhone.

### Core Goals

1. **Browse/Edit Code Remotely**
   - Access code via Dev Remote
   - Use VS Code/code-server remotely
   - Edit files from mobile device

2. **AI-Powered Coding Assistant**
   - Chat with AI about current repository
   - Get code suggestions and explanations
   - Context-aware assistance

3. **Remote Desktop Tools**
   - View Xcode via remote-screen sessions
   - Access desktop-only development tools
   - Full remote development capability

4. **Mobile-Optimized Experience**
   - Portrait mode: Top/bottom split
   - Landscape mode: Side-by-side split
   - PWA support for native-like experience

---

## Target Platform

**Primary Platform**: Web (Mobile-First)  
**Target Devices**: iPhone (all sizes), iPad  
**Access Method**: Safari browser + PWA  
**Network**: WireGuard VPN (primary), Cloudflare (optional external)

**Rationale**: 
- Mobile-first design for on-the-go development
- PWA provides native-like experience without App Store
- Web-based allows cross-platform access
- VPN ensures secure access to development environment

---

## Core Features

### Phase 1 Features (MVP)

#### Backend API (`apps/hub-backend`)

- [ ] **`/api/tools`** - List registered tools
  - Dev Remote
  - VS Code/code-server
  - Xcode remote sessions

- [ ] **`/api/files/*`** - File operations
  - File tree navigation
  - File content retrieval
  - File editing (via Dev Remote)

- [ ] **`/api/chat`** - AI coding assistant
  - OpenAI integration
  - Repository context awareness
  - Code suggestions and explanations

#### Frontend UI (`apps/hub-frontend`)

- [ ] **Top Editor Bar**
  - Tool selector (Xcode / VS Code / Dev Remote)
  - Connection status
  - Settings access

- [ ] **Main Pane with Split Views**
  - Portrait: Top/bottom split
  - Landscape: Side-by-side split
  - Toggle between layouts

- [ ] **Tab System**
  - Chat tab (AI assistant)
  - Editor tab (code editing)
  - Files tab (file browser)
  - Split toggle functionality

- [ ] **Liquid Glass Theme**
  - Glassmorphism design
  - Transparent/frosted effects
  - Modern, elegant UI

### Future Features

- [ ] File upload/download
- [ ] Terminal access
- [ ] Multiple repository support
- [ ] Collaboration features
- [ ] Custom tool integrations

---

## Technical Requirements

### Backend Requirements

- **Runtime**: Node.js 18+
- **Framework**: Express.js
- **API Style**: RESTful
- **Authentication**: WireGuard VPN (primary), optional auth for external
- **AI Integration**: OpenAI API
- **File System**: Access to configured repositories

### Frontend Requirements

- **Framework**: React 18+
- **Build Tool**: Vite
- **PWA**: Service worker, manifest.json
- **Styling**: CSS/SCSS with Liquid Glass theme
- **State Management**: React Context or Redux (TBD)
- **Responsive**: Mobile-first, portrait/landscape support

### Performance

- Initial load: < 3 seconds
- API response: < 500ms
- Smooth 60fps animations
- Efficient memory usage
- Offline support (PWA)

### Security

- HTTPS for all connections
- WireGuard VPN for primary access
- Strong authentication for external access
- Secure file operations
- No sensitive data in logs

---

## Non-Functional Requirements

### Compatibility

- Safari iOS 15+ (primary)
- Chrome/Edge (secondary)
- Responsive design for all iPhone sizes
- iPad support (landscape optimized)

### Accessibility

- Keyboard navigation
- Screen reader support
- High contrast mode
- Touch-friendly controls

### Quality

- Code coverage: > 70%
- Zero critical bugs
- Crash-free operation
- Smooth user experience

---

## Constraints

### Technical Constraints

- Must work over WireGuard VPN
- Mobile-first design (not desktop-first)
- PWA limitations (no native APIs)
- Network latency considerations

### Business Constraints

- Primary use: Andrew's development workflow
- Optional: External team access via Cloudflare
- Cost: OpenAI API usage

---

## Success Criteria

### Development Success

- [ ] All API endpoints functional
- [ ] Responsive UI working on iPhone
- [ ] PWA installable and functional
- [ ] WireGuard integration working
- [ ] AI chat functional with context

### User Experience Success

- [ ] Can browse files from iPhone
- [ ] Can edit code remotely
- [ ] Can chat with AI about code
- [ ] Can view Xcode remotely
- [ ] Smooth portrait/landscape transitions

---

## Architecture Decisions

### Backend
- **Node.js + Express**: Fast, simple, well-supported
- **RESTful API**: Standard, easy to integrate
- **File system access**: Direct access to repos

### Frontend
- **React + Vite**: Modern, fast, PWA-ready
- **Mobile-first**: Optimized for iPhone
- **Liquid Glass theme**: Modern, elegant design

### Integration
- **WireGuard**: Secure VPN access
- **Cloudflare**: Optional external access
- **OpenAI**: AI coding assistant

---

*This is a living document and will be updated as the project evolves.*
