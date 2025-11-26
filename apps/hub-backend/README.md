# Hub Backend

Node.js + Express server for FS-Remote Hub.

## API Endpoints

### `/api/tools`
List registered development tools (Dev Remote, VS Code, Xcode).

### `/api/files/*`
File operations:
- `GET /api/files/tree?path=/repo` - Get directory tree
- `GET /api/files/content?path=/repo/file.js` - Get file content
- `POST /api/files/save` - Save file changes

### `/api/chat`
AI coding assistant endpoint (OpenAI integration).

## Setup

```bash
npm install
npm start
```

## Environment Variables

```env
PORT=3000
OPENAI_API_KEY=your_key_here
REPO_PATH=/path/to/repositories
```

