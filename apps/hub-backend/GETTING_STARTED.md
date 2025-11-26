# Getting Started with Psychosis Backend

## Prerequisites

- Node.js 18+ installed
- npm or yarn package manager
- OpenAI API key (for chat functionality)

## Installation

1. **Navigate to backend directory:**
   ```bash
   cd apps/hub-backend
   ```

2. **Install dependencies:**
   ```bash
   npm install
   ```

3. **Set up environment variables:**
   ```bash
   cp .env.example .env
   ```

4. **Edit `.env` file:**
   ```env
   PORT=3000
   OPENAI_API_KEY=sk-your-key-here
   REPO_PATH=/path/to/your/repositories
   CORS_ORIGIN=http://localhost:5173
   ```

## Running the Server

### Development Mode (with auto-reload)
```bash
npm run dev
```

### Production Mode
```bash
npm start
```

The server will start on `http://localhost:3000` (or your configured PORT).

## Verify Installation

1. **Check health endpoint:**
   ```bash
   curl http://localhost:3000/health
   ```

   Expected response:
   ```json
   {
     "status": "ok",
     "timestamp": "2024-11-26T00:00:00.000Z",
     "version": "0.1.0"
   }
   ```

2. **Test tools endpoint:**
   ```bash
   curl http://localhost:3000/api/tools
   ```

3. **Test file tree endpoint:**
   ```bash
   curl http://localhost:3000/api/files/tree?path=/
   ```

## API Testing Examples

### Get All Tools
```bash
curl http://localhost:3000/api/tools
```

### Get File Tree
```bash
curl "http://localhost:3000/api/files/tree?path=/"
```

### Get File Content
```bash
curl "http://localhost:3000/api/files/content?path=/example.js"
```

### Save File
```bash
curl -X POST http://localhost:3000/api/files/save \
  -H "Content-Type: application/json" \
  -d '{
    "path": "/test.js",
    "content": "console.log(\"Hello World\");"
  }'
```

### Send Chat Message
```bash
curl -X POST http://localhost:3000/api/chat \
  -H "Content-Type: application/json" \
  -d '{
    "message": "Explain what this code does",
    "context": {
      "code": "function example() { return true; }"
    }
  }'
```

## Troubleshooting

### Port Already in Use
If port 3000 is already in use, change the PORT in `.env`:
```env
PORT=3001
```

### OpenAI API Errors
- Verify your API key is correct
- Check you have credits/quota available
- Ensure the key has access to the model you're using (default: gpt-4)

### File Access Errors
- Ensure `REPO_PATH` points to a valid directory
- Check file permissions
- The backend will create a `repositories/` directory if using default path

### CORS Issues
If frontend can't connect, check `CORS_ORIGIN` in `.env` matches your frontend URL.

## Next Steps

1. Start the backend server
2. Start the frontend (see `apps/hub-frontend/GETTING_STARTED.md`)
3. Connect iOS app to backend API
4. Test all endpoints

## Development Tips

- Use `npm run dev` for auto-reload during development
- Check console logs for request/response details
- Use `/health` endpoint to verify server is running
- All API endpoints are prefixed with `/api`

