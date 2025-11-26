# Psychosis Backend

Node.js + Express server for Psychosis - mobile-first development cockpit.

## Features

- ✅ RESTful API for tools, files, and chat
- ✅ File system operations with security
- ✅ OpenAI integration for AI coding assistant
- ✅ CORS support for frontend integration
- ✅ Request logging and error handling
- ✅ Path traversal protection

## Quick Start

```bash
# Install dependencies
npm install

# Copy environment template
cp .env.example .env

# Edit .env and add your OpenAI API key
# OPENAI_API_KEY=your_key_here

# Start server
npm start

# Or run in development mode with auto-reload
npm run dev
```

## API Endpoints

### Tools API

- `GET /api/tools` - List all registered tools
- `GET /api/tools/:id` - Get specific tool
- `POST /api/tools` - Register new tool
- `PUT /api/tools/:id` - Update tool
- `DELETE /api/tools/:id` - Remove tool

**Example Response:**
```json
{
  "tools": [
    {
      "id": "dev-remote",
      "name": "Dev Remote",
      "type": "editor",
      "url": "http://localhost:3001",
      "icon": "📝"
    }
  ]
}
```

### Files API

- `GET /api/files/tree?path=/repo` - Get directory tree
- `GET /api/files/content?path=/repo/file.js` - Get file content
- `POST /api/files/save` - Save file changes
- `POST /api/files/create` - Create new file/directory
- `DELETE /api/files?path=/repo/file.js` - Delete file/directory

**Example Request:**
```json
POST /api/files/save
{
  "path": "/repo/src/index.js",
  "content": "console.log('Hello');"
}
```

### Chat API

- `POST /api/chat` - Send chat message
- `POST /api/chat/explain` - Explain code
- `POST /api/chat/suggestions` - Get code suggestions

**Example Request:**
```json
POST /api/chat
{
  "message": "Explain this function",
  "context": {
    "file": "/repo/src/utils.js",
    "code": "function example() {...}"
  }
}
```

## Environment Variables

Create a `.env` file (see `.env.example`):

```env
# Server Configuration
PORT=3000
NODE_ENV=development

# OpenAI Configuration (required for chat)
OPENAI_API_KEY=your_openai_api_key_here
OPENAI_MODEL=gpt-4

# Repository Configuration
REPO_PATH=/path/to/repositories
DEFAULT_REPO_PATH=./repositories

# CORS Configuration
CORS_ORIGIN=http://localhost:5173
```

## Security Features

- ✅ Path traversal protection
- ✅ Input validation
- ✅ Error handling
- ✅ CORS configuration
- ✅ Environment variable validation

## Project Structure

```
hub-backend/
├── src/
│   ├── index.js              # Main server file
│   ├── routes/
│   │   ├── tools.js          # Tools API routes
│   │   ├── files.js          # Files API routes
│   │   └── chat.js           # Chat API routes
│   ├── services/
│   │   ├── ToolService.js    # Tool management
│   │   ├── FileService.js    # File operations
│   │   └── ChatService.js    # OpenAI integration
│   └── middleware/
│       ├── logger.js         # Request logging
│       └── errorHandler.js   # Error handling
├── package.json
├── .env.example
└── README.md
```

## Development

```bash
# Run with auto-reload
npm run dev

# Check health
curl http://localhost:3000/health
```

## Testing Endpoints

```bash
# Get tools
curl http://localhost:3000/api/tools

# Get file tree
curl http://localhost:3000/api/files/tree?path=/

# Get file content
curl http://localhost:3000/api/files/content?path=/example.js

# Send chat message
curl -X POST http://localhost:3000/api/chat \
  -H "Content-Type: application/json" \
  -d '{"message": "Hello, AI!"}'
```

