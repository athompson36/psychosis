import express from 'express';
import fileService from '../services/FileService.js';

const router = express.Router();

/**
 * GET /api/files/tree
 * Get directory tree
 * Query params: path (optional, defaults to /)
 */
router.get('/tree', async (req, res, next) => {
  try {
    const dirPath = req.query.path || '/';
    const tree = await fileService.getTree(dirPath);
    res.json({ tree, path: dirPath });
  } catch (error) {
    if (error.message.includes('not found')) {
      return res.status(404).json({
        error: 'Not Found',
        message: error.message
      });
    }
    if (error.message.includes('Path traversal')) {
      return res.status(403).json({
        error: 'Forbidden',
        message: error.message
      });
    }
    next(error);
  }
});

/**
 * GET /api/files/content
 * Get file content
 * Query params: path (required)
 */
router.get('/content', async (req, res, next) => {
  try {
    const filePath = req.query.path;
    
    if (!filePath) {
      return res.status(400).json({
        error: 'Bad Request',
        message: 'Path query parameter is required'
      });
    }
    
    const file = await fileService.getContent(filePath);
    res.json({ file });
  } catch (error) {
    if (error.message.includes('not found')) {
      return res.status(404).json({
        error: 'Not Found',
        message: error.message
      });
    }
    if (error.message.includes('Path traversal')) {
      return res.status(403).json({
        error: 'Forbidden',
        message: error.message
      });
    }
    next(error);
  }
});

/**
 * POST /api/files/save
 * Save file content
 * Body: { path: string, content: string }
 */
router.post('/save', async (req, res, next) => {
  try {
    const { path: filePath, content } = req.body;
    
    if (!filePath) {
      return res.status(400).json({
        error: 'Bad Request',
        message: 'Path is required'
      });
    }
    
    if (content === undefined) {
      return res.status(400).json({
        error: 'Bad Request',
        message: 'Content is required'
      });
    }
    
    const result = await fileService.saveFile(filePath, content);
    res.json(result);
  } catch (error) {
    if (error.message.includes('Path traversal')) {
      return res.status(403).json({
        error: 'Forbidden',
        message: error.message
      });
    }
    next(error);
  }
});

/**
 * POST /api/files/create
 * Create a new file or directory
 * Body: { path: string, type: 'file' | 'directory', content?: string }
 */
router.post('/create', async (req, res, next) => {
  try {
    const { path: filePath, type = 'file', content = '' } = req.body;
    
    if (!filePath) {
      return res.status(400).json({
        error: 'Bad Request',
        message: 'Path is required'
      });
    }
    
    if (!['file', 'directory'].includes(type)) {
      return res.status(400).json({
        error: 'Bad Request',
        message: 'Type must be "file" or "directory"'
      });
    }
    
    const result = await fileService.createItem(filePath, type, content);
    res.status(201).json(result);
  } catch (error) {
    if (error.message.includes('Path traversal')) {
      return res.status(403).json({
        error: 'Forbidden',
        message: error.message
      });
    }
    next(error);
  }
});

/**
 * DELETE /api/files
 * Delete a file or directory
 * Query params: path (required)
 */
router.delete('/', async (req, res, next) => {
  try {
    const filePath = req.query.path;
    
    if (!filePath) {
      return res.status(400).json({
        error: 'Bad Request',
        message: 'Path query parameter is required'
      });
    }
    
    const result = await fileService.deleteItem(filePath);
    res.json(result);
  } catch (error) {
    if (error.message.includes('not found')) {
      return res.status(404).json({
        error: 'Not Found',
        message: error.message
      });
    }
    if (error.message.includes('Path traversal')) {
      return res.status(403).json({
        error: 'Forbidden',
        message: error.message
      });
    }
    next(error);
  }
});

export default router;

