import React from 'react';
import '../EditorBar/EditorBar.css';

const EditorBar = ({ selectedTool, onToolChange, connectionStatus }) => {
  const tools = [
    { id: 'dev-remote', name: 'Dev Remote', icon: '⚡' },
    { id: 'vscode', name: 'VS Code', icon: '📝' },
    { id: 'xcode', name: 'Xcode', icon: '🔨' },
  ];

  return (
    <div className="editor-bar glass">
      <div className="editor-bar-left">
        <select
          className="tool-selector input"
          value={selectedTool}
          onChange={(e) => onToolChange(e.target.value)}
        >
          {tools.map((tool) => (
            <option key={tool.id} value={tool.id}>
              {tool.icon} {tool.name}
            </option>
          ))}
        </select>
      </div>

            <div className="editor-bar-center">
                <h1 className="editor-bar-title">Psychosis</h1>
            </div>

      <div className="editor-bar-right">
        <div className={`connection-status ${connectionStatus}`}>
          <span className="status-dot"></span>
          <span className="status-text">{connectionStatus}</span>
        </div>
        <button className="btn btn-icon" title="Settings">
          ⚙️
        </button>
      </div>
    </div>
  );
};

export default EditorBar;

