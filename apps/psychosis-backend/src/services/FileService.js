import fs from 'fs/promises';
import path from 'path';
import { fileURLToPath } from 'url';
import mime from 'mime-types';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

/**
 * Service for file system operations
 */
export class FileService {
  constructor() {
    // Get repository path from environment or use default
    this.repoPath = process.env.REPO_PATH || 
                    process.env.DEFAULT_REPO_PATH || 
                    path.join(__dirname, '../../repositories');
    
    // Ensure repo directory exists
    this.ensureRepoDirectory();
  }
  
  async ensureRepoDirectory() {
    try {
      await fs.access(this.repoPath);
    } catch {
      await fs.mkdir(this.repoPath, { recursive: true });
      console.log(`Created repository directory: ${this.repoPath}`);
    }
  }
  
  /**
   * Get full file path (sanitized)
   */
  getFullPath(filePath) {
    // Remove leading slash and resolve
    const cleanPath = filePath.startsWith('/') ? filePath.slice(1) : filePath;
    const fullPath = path.join(this.repoPath, cleanPath);
    
    // Security: Ensure path is within repo directory
    const resolvedPath = path.resolve(fullPath);
    const resolvedRepo = path.resolve(this.repoPath);
    
    if (!resolvedPath.startsWith(resolvedRepo)) {
      throw new Error('Path traversal detected');
    }
    
    return resolvedPath;
  }
  
  /**
   * Get directory tree
   */
  async getTree(dirPath = '/') {
    const fullPath = this.getFullPath(dirPath);
    
    try {
      const stats = await fs.stat(fullPath);
      
      if (!stats.isDirectory()) {
        throw new Error('Path is not a directory');
      }
      
      const items = await fs.readdir(fullPath, { withFileTypes: true });
      const tree = [];
      
      for (const item of items) {
        // Skip hidden files and node_modules
        if (item.name.startsWith('.') || item.name === 'node_modules') {
          continue;
        }
        
        const itemPath = path.join(fullPath, item.name);
        const itemStats = await fs.stat(itemPath);
        const relativePath = path.relative(this.repoPath, itemPath).replace(/\\/g, '/');
        
        tree.push({
          name: item.name,
          path: '/' + relativePath,
          type: itemStats.isDirectory() ? 'directory' : 'file',
          size: itemStats.isFile() ? itemStats.size : null,
          modified: itemStats.mtime.toISOString(),
          ...(itemStats.isFile() && {
            mimeType: mime.lookup(item.name) || 'application/octet-stream'
          })
        });
      }
      
      // Sort: directories first, then files, both alphabetically
      tree.sort((a, b) => {
        if (a.type !== b.type) {
          return a.type === 'directory' ? -1 : 1;
        }
        return a.name.localeCompare(b.name);
      });
      
      return tree;
    } catch (error) {
      if (error.code === 'ENOENT') {
        throw new Error(`Directory not found: ${dirPath}`);
      }
      throw error;
    }
  }
  
  /**
   * Get file content
   */
  async getContent(filePath) {
    const fullPath = this.getFullPath(filePath);
    
    try {
      const stats = await fs.stat(fullPath);
      
      if (stats.isDirectory()) {
        throw new Error('Path is a directory, not a file');
      }
      
      const content = await fs.readFile(fullPath, 'utf-8');
      const relativePath = path.relative(this.repoPath, fullPath).replace(/\\/g, '/');
      
      return {
        name: path.basename(fullPath),
        path: '/' + relativePath,
        content: content,
        size: stats.size,
        modified: stats.mtime.toISOString(),
        mimeType: mime.lookup(fullPath) || 'text/plain'
      };
    } catch (error) {
      if (error.code === 'ENOENT') {
        throw new Error(`File not found: ${filePath}`);
      }
      if (error.code === 'EISDIR') {
        throw new Error('Path is a directory');
      }
      throw error;
    }
  }
  
  /**
   * Save file content
   */
  async saveFile(filePath, content) {
    const fullPath = this.getFullPath(filePath);
    
    try {
      // Ensure directory exists
      const dir = path.dirname(fullPath);
      await fs.mkdir(dir, { recursive: true });
      
      // Write file
      await fs.writeFile(fullPath, content, 'utf-8');
      
      const stats = await fs.stat(fullPath);
      const relativePath = path.relative(this.repoPath, fullPath).replace(/\\/g, '/');
      
      return {
        success: true,
        path: '/' + relativePath,
        size: stats.size,
        modified: stats.mtime.toISOString()
      };
    } catch (error) {
      throw new Error(`Failed to save file: ${error.message}`);
    }
  }
  
  /**
   * Create a new file or directory
   */
  async createItem(filePath, type = 'file', content = '') {
    const fullPath = this.getFullPath(filePath);
    
    try {
      if (type === 'directory') {
        await fs.mkdir(fullPath, { recursive: true });
      } else {
        const dir = path.dirname(fullPath);
        await fs.mkdir(dir, { recursive: true });
        await fs.writeFile(fullPath, content, 'utf-8');
      }
      
      const relativePath = path.relative(this.repoPath, fullPath).replace(/\\/g, '/');
      return {
        success: true,
        path: '/' + relativePath,
        type: type
      };
    } catch (error) {
      throw new Error(`Failed to create ${type}: ${error.message}`);
    }
  }
  
  /**
   * Delete a file or directory
   */
  async deleteItem(filePath) {
    const fullPath = this.getFullPath(filePath);
    
    try {
      const stats = await fs.stat(fullPath);
      
      if (stats.isDirectory()) {
        await fs.rmdir(fullPath, { recursive: true });
      } else {
        await fs.unlink(fullPath);
      }
      
      return { success: true };
    } catch (error) {
      if (error.code === 'ENOENT') {
        throw new Error(`Item not found: ${filePath}`);
      }
      throw new Error(`Failed to delete: ${error.message}`);
    }
  }
}

export default new FileService();

