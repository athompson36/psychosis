import React, { useState, useEffect } from 'react';
import './MainPane.css';

const MainPane = ({ children }) => {
  const [isPortrait, setIsPortrait] = useState(window.innerHeight > window.innerWidth);
  const [activeTab, setActiveTab] = useState('chat');
  const [isSplit, setIsSplit] = useState(false);

  useEffect(() => {
    const handleResize = () => {
      setIsPortrait(window.innerHeight > window.innerWidth);
    };

    window.addEventListener('resize', handleResize);
    return () => window.removeEventListener('resize', handleResize);
  }, []);

  const tabs = [
    { id: 'chat', label: 'Chat', icon: '💬' }, // Cursor chat
    { id: 'editor', label: 'Editor', icon: '📝' },
    { id: 'files', label: 'Files', icon: '📁' },
  ];

  const renderContent = () => {
    if (isPortrait) {
      // Portrait: Top/Bottom split
      if (isSplit) {
        return (
          <div className="main-pane-portrait-split">
            <div className="pane-top">
              {children[activeTab]}
            </div>
            <div className="pane-divider"></div>
            <div className="pane-bottom">
              {children[tabs.find(t => t.id !== activeTab)?.id]}
            </div>
          </div>
        );
      } else {
        return (
          <div className="main-pane-portrait-single">
            {children[activeTab]}
          </div>
        );
      }
    } else {
      // Landscape: Side-by-side split
      if (isSplit) {
        return (
          <div className="main-pane-landscape-split">
            <div className="pane-left">
              {children[activeTab]}
            </div>
            <div className="pane-divider-vertical"></div>
            <div className="pane-right">
              {children[tabs.find(t => t.id !== activeTab)?.id]}
            </div>
          </div>
        );
      } else {
        return (
          <div className="main-pane-landscape-single">
            {children[activeTab]}
          </div>
        );
      }
    }
  };

  return (
    <div className="main-pane">
      <div className="main-pane-tabs glass">
        {tabs.map((tab) => (
          <button
            key={tab.id}
            className={`tab-button ${activeTab === tab.id ? 'active' : ''}`}
            onClick={() => setActiveTab(tab.id)}
          >
            <span className="tab-icon">{tab.icon}</span>
            <span className="tab-label">{tab.label}</span>
          </button>
        ))}
        <button
          className={`split-toggle ${isSplit ? 'active' : ''}`}
          onClick={() => setIsSplit(!isSplit)}
          title="Toggle Split View"
        >
          {isPortrait ? '⇅' : '⇄'}
        </button>
      </div>

      <div className="main-pane-content">
        {renderContent()}
      </div>
    </div>
  );
};

export default MainPane;

