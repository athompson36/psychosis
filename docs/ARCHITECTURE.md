# Architecture: FS-Remote Hub (FS-Tech Liquid Glass)

## Architecture Decision Record (ADR)

**Date**: [Current Date]  
**Status**: Active  
**Version**: 1.0

---

## Overview

This document describes the architecture decisions, patterns, and structure for the FS-Remote Hub - a mobile-first, Liquid Glass–themed control cockpit for remote development.

---

## System Architecture

### High-Level Structure

```
┌─────────────────────────────────────────┐
│         iPhone (Safari + PWA)          │
│  ┌───────────────────────────────────┐  │
│  │   React + Vite Frontend (PWA)    │  │
│  │   - Liquid Glass Theme            │  │
│  │   - Portrait/Landscape Layouts   │  │
│  │   - Chat / Editor / Files Tabs    │  │
│  └───────────────────────────────────┘  │
└─────────────────────────────────────────┘
              │ HTTPS
              ▼
┌─────────────────────────────────────────┐
│      WireGuard VPN / Cloudflare         │
└─────────────────────────────────────────┘
              │
              ▼
┌─────────────────────────────────────────┐
│    Node.js + Express Backend            │
│  ┌───────────────────────────────────┐  │
│  │   /api/tools   - Tool registry    │  │
│  │   /api/files/* - File operations  │  │
│  │   /api/chat    - OpenAI integration│  │
│  └───────────────────────────────────┘  │
└─────────────────────────────────────────┘
              │
              ▼
┌─────────────────────────────────────────┐
│   Development Tools & Repositories      │
│   - Dev Remote                          │
│   - VS Code / code-server               │
│   - Xcode (remote screen)               │
│   - Git repositories                    │
└─────────────────────────────────────────┘
```

---

## Project Structure

```
psychosis/
├── apps/
│   ├── hub-backend/              # Node.js + Express backend
│   │   ├── src/
│   │   │   ├── routes/
│   │   │   │   ├── tools.js       # /api/tools
│   │   │   │   ├── files.js       # /api/files/*
│   │   │   │   └── chat.js        # /api/chat
│   │   │   ├── services/
│   │   │   │   ├── fileService.js
│   │   │   │   ├── chatService.js # OpenAI integration
│   │   │   │   └── toolService.js
│   │   │   ├── middleware/
│   │   │   │   └── auth.js
│   │   │   └── server.js
│   │   ├── package.json
│   │   └── .env
│   │
│   └── hub-frontend/              # React + Vite PWA
│       ├── src/
│       │   ├── components/
│       │   │   ├── EditorBar/     # Top editor bar
│       │   │   ├── MainPane/      # Split view container
│       │   │   ├── Chat/          # AI chat interface
│       │   │   ├── Editor/        # Code editor
│       │   │   ├── FileBrowser/   # File tree
│       │   │   └── ToolSelector/  # Tool picker
│       │   ├── hooks/
│       │   ├── services/
│       │   │   └── api.js          # API client
│       │   ├── styles/
│       │   │   └── liquid-glass.css
│       │   ├── App.jsx
│       │   └── main.jsx
│       ├── public/
│       │   ├── manifest.json       # PWA manifest
│       │   └── service-worker.js
│       ├── vite.config.js
│       └── package.json
│
├── docs/                           # Documentation
└── README.md
```

---

## Backend Architecture

### Technology Stack

- **Runtime**: Node.js 18+
- **Framework**: Express.js
- **API Style**: RESTful
- **File System**: Node.js fs module
- **AI**: OpenAI API

### API Endpoints

#### `GET /api/tools`
List registered development tools.

**Response**:
```json
{
  "tools": [
    {
      "id": "dev-remote",
      "name": "Dev Remote",
      "type": "editor",
      "url": "http://localhost:3001"
    },
    {
      "id": "vscode",
      "name": "VS Code",
      "type": "editor",
      "url": "http://localhost:8080"
    },
    {
      "id": "xcode",
      "name": "Xcode",
      "type": "remote-screen",
      "url": "vnc://..."
    }
  ]
}
```

#### `GET /api/files/*`
Get file tree or file content.

**Endpoints**:
- `GET /api/files/tree?path=/repo` - Get directory tree
- `GET /api/files/content?path=/repo/file.js` - Get file content
- `POST /api/files/save` - Save file changes

#### `POST /api/chat`
AI coding assistant endpoint.

**Request**:
```json
{
  "message": "Explain this function",
  "context": {
    "file": "/repo/src/utils.js",
    "code": "function example() {...}"
  }
}
```

**Response**:
```json
{
  "response": "This function does...",
  "suggestions": [...]
}
```

### Service Layer

- **FileService**: File system operations
- **ChatService**: OpenAI integration with context
- **ToolService**: Tool registry and management

---

## Frontend Architecture

### Technology Stack

- **Framework**: React 18+
- **Build Tool**: Vite
- **PWA**: Service Worker + Manifest
- **Styling**: CSS with Liquid Glass theme
- **State**: React Context or Redux (TBD)

### Component Structure

#### EditorBar
Top navigation bar with:
- Tool selector dropdown
- Connection status indicator
- Settings button

#### MainPane
Container that handles:
- Portrait mode: Vertical split (top/bottom)
- Landscape mode: Horizontal split (side-by-side)
- Tab management (Chat / Editor / Files)
- Split toggle functionality

#### Chat Component
- Message list
- Input field
- Context awareness (current file/repo)
- OpenAI integration

#### Editor Component
- Code editor (Monaco or CodeMirror)
- Syntax highlighting
- File tabs
- Save functionality

#### FileBrowser Component
- Directory tree
- File navigation
- File operations (open, delete, etc.)

### Liquid Glass Theme

**Design Principles**:
- Frosted glass effects (backdrop-filter)
- Transparency with blur
- Subtle borders and shadows
- Modern, elegant aesthetic
- Smooth animations

**CSS Variables**:
```css
:root {
  --glass-bg: rgba(255, 255, 255, 0.1);
  --glass-border: rgba(255, 255, 255, 0.2);
  --glass-blur: blur(10px);
  --glass-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
}
```

### Responsive Design

**Portrait Mode**:
```
┌─────────────────┐
│   Editor Bar    │
├─────────────────┤
│   Tab 1         │
│   (Top Pane)    │
├─────────────────┤
│   Tab 2         │
│   (Bottom Pane) │
└─────────────────┘
```

**Landscape Mode**:
```
┌─────────────────────────────────┐
│         Editor Bar              │
├──────────────┬──────────────────┤
│              │                  │
│   Tab 1      │   Tab 2          │
│   (Left)     │   (Right)        │
│              │                  │
└──────────────┴──────────────────┘
```

---

## Data Flow

### File Operations
1. User selects file in FileBrowser
2. Frontend calls `GET /api/files/content?path=...`
3. Backend reads file from filesystem
4. Backend returns file content
5. Frontend displays in Editor
6. User edits and saves
7. Frontend calls `POST /api/files/save`
8. Backend writes to filesystem

### AI Chat
1. User types message in Chat
2. Frontend collects context (current file, repo)
3. Frontend calls `POST /api/chat` with message + context
4. Backend calls OpenAI API with context
5. Backend returns AI response
6. Frontend displays response

### Tool Selection
1. User selects tool in EditorBar
2. Frontend calls `GET /api/tools`
3. Backend returns available tools
4. Frontend displays tool in iframe or redirects

---

## Security Considerations

### Network Security
- **WireGuard VPN**: Primary access method
- **HTTPS**: All connections encrypted
- **Cloudflare**: Optional external access with auth

### Authentication
- VPN-based (WireGuard) for primary access
- Token-based for external access (if enabled)
- No sensitive data in logs

### File System Security
- Restricted to configured repositories
- No access to system files
- Validation of file paths

---

## Performance Considerations

### Backend
- Efficient file reading (streaming for large files)
- Caching of file trees
- Rate limiting for API endpoints

### Frontend
- Code splitting for PWA
- Lazy loading of components
- Efficient re-renders (React.memo)
- Service worker caching

### Network
- Optimize for mobile networks
- Compress API responses
- Minimize round trips

---

## PWA Implementation

### Manifest
- App name, icons, theme
- Display mode: standalone
- Start URL

### Service Worker
- Cache API responses
- Offline support
- Background sync for file saves

---

## Future Considerations

### Scalability
- Multiple user support
- Repository management
- Tool plugin system

### Features
- Terminal access
- Git operations
- Collaboration features
- Custom themes

---

## Decision Log

### 2025-01-XX: Initial Architecture Decisions
- **Decision**: Node.js + Express backend
- **Rationale**: Fast, simple, well-supported
- **Status**: Active

- **Decision**: React + Vite frontend
- **Rationale**: Modern, fast, PWA-ready
- **Status**: Active

- **Decision**: Mobile-first design
- **Rationale**: Primary use case is iPhone
- **Status**: Active

- **Decision**: Liquid Glass theme
- **Rationale**: Modern, elegant aesthetic
- **Status**: Active

---

*This is a living document and will be updated as the architecture evolves.*
