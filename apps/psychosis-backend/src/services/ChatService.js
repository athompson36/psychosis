import OpenAI from 'openai';
import fs from 'fs/promises';
import path from 'path';

/**
 * Service for AI chat functionality using OpenAI
 */
export class ChatService {
  constructor() {
    const apiKey = process.env.OPENAI_API_KEY;
    
    if (!apiKey) {
      console.warn('⚠️  OPENAI_API_KEY not set. Chat functionality will be disabled.');
      this.client = null;
    } else {
      this.client = new OpenAI({
        apiKey: apiKey
      });
    }
    
    this.model = process.env.OPENAI_MODEL || 'gpt-4';
    this.repoPath = process.env.REPO_PATH || 
                    process.env.DEFAULT_REPO_PATH || 
                    path.join(process.cwd(), 'repositories');
  }
  
  /**
   * Check if chat service is available
   */
  isAvailable() {
    return this.client !== null;
  }
  
  /**
   * Get repository context for better responses
   */
  async getRepositoryContext(filePath = null, codeSnippet = null) {
    let context = '';
    
    // Add file content if provided
    if (filePath) {
      try {
        const fullPath = path.join(this.repoPath, filePath.replace(/^\//, ''));
        const content = await fs.readFile(fullPath, 'utf-8');
        context += `\n\nFile: ${filePath}\n${content}`;
      } catch (error) {
        // File not found or can't read, continue without it
        console.warn(`Could not read file for context: ${filePath}`);
      }
    }
    
    // Add code snippet if provided
    if (codeSnippet) {
      context += `\n\nCode snippet:\n${codeSnippet}`;
    }
    
    return context;
  }
  
  /**
   * Send a chat message with context
   */
  async sendMessage(message, context = {}) {
    if (!this.isAvailable()) {
      throw new Error('OpenAI API key not configured. Please set OPENAI_API_KEY environment variable.');
    }
    
    try {
      // Build system prompt
      let systemPrompt = `You are a helpful coding assistant for the Psychosis development environment. 
You help developers understand code, debug issues, and write better code.
Be concise, clear, and focus on practical solutions.`;
      
      // Add repository context if available
      let repositoryContext = '';
      if (context.file) {
        repositoryContext = await this.getRepositoryContext(context.file, context.code);
      } else if (context.code) {
        repositoryContext = await this.getRepositoryContext(null, context.code);
      }
      
      if (repositoryContext) {
        systemPrompt += `\n\nCurrent context:${repositoryContext}`;
      }
      
      // Make API call
      const completion = await this.client.chat.completions.create({
        model: this.model,
        messages: [
          {
            role: 'system',
            content: systemPrompt
          },
          {
            role: 'user',
            content: message
          }
        ],
        temperature: 0.7,
        max_tokens: 1000
      });
      
      const response = completion.choices[0]?.message?.content || 'No response generated';
      
      return {
        response: response,
        model: this.model,
        usage: completion.usage
      };
    } catch (error) {
      console.error('OpenAI API error:', error);
      
      if (error.status === 401) {
        throw new Error('Invalid OpenAI API key');
      } else if (error.status === 429) {
        throw new Error('OpenAI API rate limit exceeded. Please try again later.');
      } else if (error.status === 500) {
        throw new Error('OpenAI API server error. Please try again later.');
      }
      
      throw new Error(`Chat service error: ${error.message}`);
    }
  }
  
  /**
   * Get code suggestions based on context
   */
  async getSuggestions(code, language = 'javascript') {
    const message = `Review this ${language} code and provide suggestions for improvement:\n\n${code}`;
    return this.sendMessage(message, { code });
  }
  
  /**
   * Explain code
   */
  async explainCode(code, language = 'javascript') {
    const message = `Explain what this ${language} code does:\n\n${code}`;
    return this.sendMessage(message, { code });
  }
}

export default new ChatService();

