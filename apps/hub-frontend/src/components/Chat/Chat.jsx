import React, { useState, useRef, useEffect } from 'react';
import api from '../../services/api';
import './Chat.css';

const Chat = ({ context = {} }) => {
  const [messages, setMessages] = useState([
    {
      id: 1,
      role: 'assistant',
      content: 'Connect to Cursor to start chatting about your code.',
      timestamp: new Date(),
    },
  ]);
  const [input, setInput] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const messagesEndRef = useRef(null);

  const scrollToBottom = () => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  };

  useEffect(() => {
    scrollToBottom();
  }, [messages]);

  const handleSend = async (e) => {
    e.preventDefault();
    if (!input.trim() || isLoading) return;

    const userMessage = {
      id: Date.now(),
      role: 'user',
      content: input,
      timestamp: new Date(),
    };

    setMessages((prev) => [...prev, userMessage]);
    setInput('');
    setIsLoading(true);

    try {
      // TODO: Connect to Cursor chat API instead of generic AI
      const response = await api.sendChatMessage(input, context);
      
      const assistantMessage = {
        id: Date.now() + 1,
        role: 'assistant',
        content: response.response || response.message || 'Cursor chat response would appear here.',
        timestamp: new Date(),
      };

      setMessages((prev) => [...prev, assistantMessage]);
    } catch (error) {
      const errorMessage = {
        id: Date.now() + 1,
        role: 'assistant',
        content: `Error: ${error.message}. Please check your connection and try again.`,
        timestamp: new Date(),
      };

      setMessages((prev) => [...prev, errorMessage]);
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="chat-container">
      <div className="chat-messages">
        {messages.map((message) => (
          <div key={message.id} className={`chat-message ${message.role}`}>
            <div className="message-content glass">
              <div className="message-header">
                <span className="message-role">{message.role === 'user' ? 'You' : 'AI'}</span>
                <span className="message-time">
                  {message.timestamp.toLocaleTimeString()}
                </span>
              </div>
              <div className="message-text">{message.content}</div>
            </div>
          </div>
        ))}
        {isLoading && (
          <div className="chat-message assistant">
            <div className="message-content glass">
              <div className="typing-indicator">
                <span></span>
                <span></span>
                <span></span>
              </div>
            </div>
          </div>
        )}
        <div ref={messagesEndRef} />
      </div>

      <form className="chat-input-form" onSubmit={handleSend}>
          <input
          type="text"
          className="chat-input input"
          placeholder="Ask Cursor about your code..."
          value={input}
          onChange={(e) => setInput(e.target.value)}
          disabled={isLoading}
        />
        <button
          type="submit"
          className="btn btn-primary chat-send"
          disabled={!input.trim() || isLoading}
        >
          Send
        </button>
      </form>
    </div>
  );
};

export default Chat;

