# Running the Frontend

## Quick Start

```bash
cd apps/hub-frontend
npm install  # If you haven't already
npm run dev
```

The development server will start at: **http://localhost:5173**

## What You'll See

- **EditorBar** at the top with tool selector
- **MainPane** with three tabs:
  - 💬 **Chat** - AI coding assistant
  - 📝 **Editor** - Code editor
  - 📁 **Files** - File browser
- **Liquid Glass** theme with frosted glass effects

## Testing Responsive Layouts

1. **Portrait Mode**: Resize browser to narrow width
   - Tabs stack vertically
   - Split view is top/bottom

2. **Landscape Mode**: Resize browser to wide width
   - Tabs are horizontal
   - Split view is side-by-side

3. **On iPhone**: 
   - Open in Safari
   - Use "Add to Home Screen" for PWA
   - Test portrait/landscape rotation

## Next Steps

Once the frontend is running, you can:
1. Build the backend API server
2. Connect the API endpoints
3. Add Monaco Editor for code editing
4. Implement service worker for PWA

