import React, { useState } from 'react';
import './Editor.css';

const Editor = ({ file, onFileChange }) => {
  const [content, setContent] = useState(file?.content || '');
  const [isDirty, setIsDirty] = useState(false);

  const handleChange = (e) => {
    setContent(e.target.value);
    setIsDirty(true);
    if (onFileChange) {
      onFileChange({ ...file, content: e.target.value });
    }
  };

  const handleSave = async () => {
    // TODO: Implement save functionality
    setIsDirty(false);
    console.log('Saving file:', file?.path, content);
  };

  return (
    <div className="editor-container">
      {file && (
        <div className="editor-header glass">
          <div className="editor-file-info">
            <span className="editor-file-name">{file.name || 'Untitled'}</span>
            <span className="editor-file-path">{file.path || ''}</span>
          </div>
          <div className="editor-actions">
            {isDirty && (
              <span className="editor-dirty-indicator">●</span>
            )}
            <button
              className="btn btn-primary"
              onClick={handleSave}
              disabled={!isDirty}
            >
              Save
            </button>
          </div>
        </div>
      )}

      <div className="editor-content">
        {file ? (
          <textarea
            className="editor-textarea"
            value={content}
            onChange={handleChange}
            placeholder="Start editing..."
            spellCheck={false}
          />
        ) : (
          <div className="editor-empty">
            <div className="editor-empty-icon">📝</div>
            <div className="editor-empty-text">
              <h3>No file open</h3>
              <p>Select a file from the Files tab to start editing</p>
            </div>
          </div>
        )}
      </div>
    </div>
  );
};

export default Editor;


