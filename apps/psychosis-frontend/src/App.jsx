import React, { useState } from 'react';
import MainPane from './components/MainPane/MainPane';
import Chat from './components/Chat/Chat';
import Editor from './components/Editor/Editor';
import FileBrowser from './components/FileBrowser/FileBrowser';
import './App.css';

function App() {
  const [currentFile, setCurrentFile] = useState(null);

  const handleFileSelect = (file) => {
    setCurrentFile(file);
  };

  const handleFileChange = (file) => {
    setCurrentFile(file);
  };

  return (
    <div className="app">
      <MainPane>
        {{
          chat: <Chat context={{ file: currentFile }} />,
          editor: <Editor file={currentFile} onFileChange={handleFileChange} />,
          files: <FileBrowser onFileSelect={handleFileSelect} />,
        }}
      </MainPane>
    </div>
  );
}

export default App;

