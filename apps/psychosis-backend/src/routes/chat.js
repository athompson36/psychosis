import express from 'express';
import chatService from '../services/ChatService.js';

const router = express.Router();

/**
 * POST /api/chat
 * Send a chat message to the AI assistant
 * Body: { message: string, context?: { file?: string, code?: string } }
 */
router.post('/', async (req, res, next) => {
  try {
    const { message, context = {} } = req.body;
    
    if (!message || typeof message !== 'string' || message.trim().length === 0) {
      return res.status(400).json({
        error: 'Bad Request',
        message: 'Message is required and must be a non-empty string'
      });
    }
    
    if (!chatService.isAvailable()) {
      return res.status(503).json({
        error: 'Service Unavailable',
        message: 'Chat service is not configured. Please set OPENAI_API_KEY environment variable.'
      });
    }
    
    const result = await chatService.sendMessage(message, context);
    res.json(result);
  } catch (error) {
    if (error.message.includes('API key')) {
      return res.status(503).json({
        error: 'Service Unavailable',
        message: error.message
      });
    }
    if (error.message.includes('rate limit')) {
      return res.status(429).json({
        error: 'Too Many Requests',
        message: error.message
      });
    }
    next(error);
  }
});

/**
 * POST /api/chat/explain
 * Explain code
 * Body: { code: string, language?: string }
 */
router.post('/explain', async (req, res, next) => {
  try {
    const { code, language = 'javascript' } = req.body;
    
    if (!code || typeof code !== 'string' || code.trim().length === 0) {
      return res.status(400).json({
        error: 'Bad Request',
        message: 'Code is required and must be a non-empty string'
      });
    }
    
    if (!chatService.isAvailable()) {
      return res.status(503).json({
        error: 'Service Unavailable',
        message: 'Chat service is not configured. Please set OPENAI_API_KEY environment variable.'
      });
    }
    
    const result = await chatService.explainCode(code, language);
    res.json(result);
  } catch (error) {
    next(error);
  }
});

/**
 * POST /api/chat/suggestions
 * Get code suggestions
 * Body: { code: string, language?: string }
 */
router.post('/suggestions', async (req, res, next) => {
  try {
    const { code, language = 'javascript' } = req.body;
    
    if (!code || typeof code !== 'string' || code.trim().length === 0) {
      return res.status(400).json({
        error: 'Bad Request',
        message: 'Code is required and must be a non-empty string'
      });
    }
    
    if (!chatService.isAvailable()) {
      return res.status(503).json({
        error: 'Service Unavailable',
        message: 'Chat service is not configured. Please set OPENAI_API_KEY environment variable.'
      });
    }
    
    const result = await chatService.getSuggestions(code, language);
    res.json(result);
  } catch (error) {
    next(error);
  }
});

export default router;

