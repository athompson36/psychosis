import React, { useState, useEffect } from 'react';
import api from '../../services/api';
import './FileBrowser.css';

const FileBrowser = ({ onFileSelect }) => {
  const [tree, setTree] = useState([]);
  const [currentPath, setCurrentPath] = useState('/');
  const [loading, setLoading] = useState(false);
  const [expanded, setExpanded] = useState({});

  useEffect(() => {
    loadTree(currentPath);
  }, [currentPath]);

  const loadTree = async (path) => {
    setLoading(true);
    try {
      const data = await api.getFileTree(path);
      setTree(data.files || data || []);
    } catch (error) {
      console.error('Failed to load file tree:', error);
      // Mock data for development
      setTree([
        { name: 'src', type: 'directory', path: '/src' },
        { name: 'package.json', type: 'file', path: '/package.json' },
        { name: 'README.md', type: 'file', path: '/README.md' },
      ]);
    } finally {
      setLoading(false);
    }
  };

  const toggleExpand = (path) => {
    setExpanded((prev) => ({
      ...prev,
      [path]: !prev[path],
    }));
  };

  const handleFileClick = async (file) => {
    if (file.type === 'directory') {
      toggleExpand(file.path);
      setCurrentPath(file.path);
    } else {
      try {
        const data = await api.getFileContent(file.path);
        onFileSelect({
          name: file.name,
          path: file.path,
          content: data.content || data || '',
        });
      } catch (error) {
        console.error('Failed to load file:', error);
      }
    }
  };

  const renderFile = (file, level = 0) => {
    const isExpanded = expanded[file.path];
    const isDirectory = file.type === 'directory';

    return (
      <div key={file.path} className="file-item">
        <div
          className={`file-row ${isDirectory ? 'directory' : 'file'}`}
          style={{ paddingLeft: `${level * var(--spacing-lg)}` }}
          onClick={() => handleFileClick(file)}
        >
          <span className="file-icon">
            {isDirectory ? (isExpanded ? '📂' : '📁') : '📄'}
          </span>
          <span className="file-name">{file.name}</span>
        </div>
      </div>
    );
  };

  return (
    <div className="file-browser-container">
      <div className="file-browser-header glass">
        <div className="file-browser-path">
          <span className="path-label">Path:</span>
          <span className="path-value">{currentPath}</span>
        </div>
        <button
          className="btn btn-icon"
          onClick={() => setCurrentPath('/')}
          title="Go to root"
        >
          🏠
        </button>
      </div>

      <div className="file-browser-content">
        {loading ? (
          <div className="file-browser-loading">
            <div className="loading-spinner"></div>
            <span>Loading files...</span>
          </div>
        ) : (
          <div className="file-tree">
            {tree.length === 0 ? (
              <div className="file-browser-empty">
                <span>No files found</span>
              </div>
            ) : (
              tree.map((file) => renderFile(file))
            )}
          </div>
        )}
      </div>
    </div>
  );
};

export default FileBrowser;

