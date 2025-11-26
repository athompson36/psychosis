/**
 * Service for managing development tools
 */

export class ToolService {
  constructor() {
    // Default tools configuration
    this.tools = [
      {
        id: 'dev-remote',
        name: 'Dev Remote',
        type: 'editor',
        description: 'Remote code editor via Dev Remote',
        url: process.env.DEV_REMOTE_URL || 'http://localhost:3001',
        icon: '📝',
        enabled: true
      },
      {
        id: 'vscode',
        name: 'VS Code / code-server',
        type: 'editor',
        description: 'VS Code in the browser via code-server',
        url: process.env.VSCODE_URL || 'http://localhost:8080',
        icon: '💻',
        enabled: true
      },
      {
        id: 'xcode',
        name: 'Xcode',
        type: 'remote-screen',
        description: 'Xcode via remote screen session',
        url: process.env.XCODE_VNC_URL || 'vnc://localhost:5900',
        icon: '🔨',
        enabled: true
      }
    ];
  }
  
  /**
   * Get all registered tools
   */
  getAllTools() {
    return this.tools.filter(tool => tool.enabled);
  }
  
  /**
   * Get a specific tool by ID
   */
  getToolById(id) {
    return this.tools.find(tool => tool.id === id && tool.enabled);
  }
  
  /**
   * Register a new tool
   */
  registerTool(tool) {
    const newTool = {
      id: tool.id || `tool-${Date.now()}`,
      name: tool.name,
      type: tool.type || 'editor',
      description: tool.description || '',
      url: tool.url,
      icon: tool.icon || '🔧',
      enabled: tool.enabled !== false
    };
    
    this.tools.push(newTool);
    return newTool;
  }
  
  /**
   * Update an existing tool
   */
  updateTool(id, updates) {
    const tool = this.getToolById(id);
    if (!tool) {
      throw new Error(`Tool with id ${id} not found`);
    }
    
    Object.assign(tool, updates);
    return tool;
  }
  
  /**
   * Remove a tool
   */
  removeTool(id) {
    const index = this.tools.findIndex(tool => tool.id === id);
    if (index === -1) {
      throw new Error(`Tool with id ${id} not found`);
    }
    
    this.tools.splice(index, 1);
    return { success: true };
  }
}

export default new ToolService();

