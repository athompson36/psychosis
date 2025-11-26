import express from 'express';
import toolService from '../services/ToolService.js';

const router = express.Router();

/**
 * GET /api/tools
 * Get all registered tools
 */
router.get('/', (req, res, next) => {
  try {
    const tools = toolService.getAllTools();
    res.json({ tools });
  } catch (error) {
    next(error);
  }
});

/**
 * GET /api/tools/:id
 * Get a specific tool by ID
 */
router.get('/:id', (req, res, next) => {
  try {
    const tool = toolService.getToolById(req.params.id);
    
    if (!tool) {
      return res.status(404).json({ 
        error: 'Not Found',
        message: `Tool with id ${req.params.id} not found`
      });
    }
    
    res.json({ tool });
  } catch (error) {
    next(error);
  }
});

/**
 * POST /api/tools
 * Register a new tool
 */
router.post('/', (req, res, next) => {
  try {
    const { name, type, description, url, icon } = req.body;
    
    if (!name || !url) {
      return res.status(400).json({
        error: 'Bad Request',
        message: 'Name and URL are required'
      });
    }
    
    const tool = toolService.registerTool({
      name,
      type,
      description,
      url,
      icon
    });
    
    res.status(201).json({ tool });
  } catch (error) {
    next(error);
  }
});

/**
 * PUT /api/tools/:id
 * Update an existing tool
 */
router.put('/:id', (req, res, next) => {
  try {
    const tool = toolService.updateTool(req.params.id, req.body);
    res.json({ tool });
  } catch (error) {
    if (error.message.includes('not found')) {
      return res.status(404).json({
        error: 'Not Found',
        message: error.message
      });
    }
    next(error);
  }
});

/**
 * DELETE /api/tools/:id
 * Remove a tool
 */
router.delete('/:id', (req, res, next) => {
  try {
    toolService.removeTool(req.params.id);
    res.json({ success: true });
  } catch (error) {
    if (error.message.includes('not found')) {
      return res.status(404).json({
        error: 'Not Found',
        message: error.message
      });
    }
    next(error);
  }
});

export default router;

