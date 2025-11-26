# Getting Started - Frontend

## Quick Start

```bash
cd apps/hub-frontend
npm install
npm run dev
```

The app will be available at `http://localhost:5173`

## What's Built

### Components

1. **EditorBar** - Top navigation bar
   - Tool selector (Dev Remote, VS Code, Xcode)
   - Connection status indicator
   - Settings button

2. **MainPane** - Responsive split view container
   - Portrait mode: Top/bottom split
   - Landscape mode: Side-by-side split
   - Tab system (Chat, Editor, Files)
   - Split toggle functionality

3. **Chat** - AI coding assistant
   - Message interface
   - Context-aware (current file/repo)
   - OpenAI integration ready

4. **Editor** - Code editor
   - File editing
   - Save functionality
   - File info display

5. **FileBrowser** - File tree navigation
   - Directory tree
   - File selection
   - Path navigation

### Styling

- **Liquid Glass Theme** - Complete CSS theme with:
  - Glassmorphism effects
  - Frosted glass containers
  - Smooth animations
  - Responsive design
  - Dark theme optimized

### Services

- **API Client** - Ready for backend integration
  - Tools API
  - Files API
  - Chat API

## Next Steps

1. **Start Backend** - Set up Express server
2. **Connect API** - Wire up API endpoints
3. **Add Monaco Editor** - Replace textarea with code editor
4. **Implement PWA** - Add service worker
5. **Test on iPhone** - Test responsive layouts

## Development

```bash
# Development server
npm run dev

# Build for production
npm run build

# Preview production build
npm run preview
```

## Environment Variables

Create `.env` file:

```env
VITE_API_URL=http://localhost:3000/api
```


