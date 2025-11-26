# Psychosis iOS App

Native iOS/iPadOS app for Psychosis.

## Overview

This is the native iOS companion to the web app, providing the same functionality with native iOS features and better performance.

## Features

- **Same functionality as web app**:
  - Browse/edit code via Dev Remote and VS Code
  - Chat with AI about current repo
  - View desktop tools (Xcode) via remote-screen sessions
- **Native iOS features**:
  - Better performance
  - Native UI components
  - Offline support
  - Push notifications (future)
  - Better file handling

## Project Structure

```
Psychosis/
├── App/              # App entry point
├── Features/         # Feature modules
│   ├── EditorBar/   # Tool selector
│   ├── MainPane/    # Split view container
│   ├── Chat/        # AI chat
│   ├── Editor/       # Code editor
│   └── FileBrowser/ # File browser
├── Core/            # Shared infrastructure
│   ├── Networking/  # API client
│   ├── Models/      # Data models
│   └── UI/          # Shared UI components
└── Resources/       # Assets, etc.
```

## Requirements

- iOS 17.0+
- iPadOS 17.0+
- Xcode 15.0+
- Swift 5.9+

## Setup

1. Open `Psychosis.xcodeproj` in Xcode
2. Select your development team
3. Build and run

## Architecture

- **SwiftUI** for UI
- **MVVM** pattern
- **async/await** for networking
- Shared API client with web app

