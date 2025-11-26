// API Client for FS-Remote Hub

const API_BASE_URL = import.meta.env.VITE_API_URL || 'http://localhost:3000/api';

class ApiClient {
  constructor(baseURL = API_BASE_URL) {
    this.baseURL = baseURL;
  }

  async request(endpoint, options = {}) {
    const url = `${this.baseURL}${endpoint}`;
    const config = {
      headers: {
        'Content-Type': 'application/json',
        ...options.headers,
      },
      ...options,
    };

    if (options.body && typeof options.body === 'object') {
      config.body = JSON.stringify(options.body);
    }

    try {
      const response = await fetch(url, config);
      
      if (!response.ok) {
        throw new Error(`API Error: ${response.status} ${response.statusText}`);
      }

      return await response.json();
    } catch (error) {
      console.error('API Request failed:', error);
      throw error;
    }
  }

  // Tools API
  async getTools() {
    return this.request('/tools');
  }

  // Files API
  async getFileTree(path = '/') {
    return this.request(`/files/tree?path=${encodeURIComponent(path)}`);
  }

  async getFileContent(path) {
    return this.request(`/files/content?path=${encodeURIComponent(path)}`);
  }

  async saveFile(path, content) {
    return this.request('/files/save', {
      method: 'POST',
      body: { path, content },
    });
  }

  // Chat API
  async sendChatMessage(message, context = {}) {
    return this.request('/chat', {
      method: 'POST',
      body: { message, context },
    });
  }
}

export default new ApiClient();


