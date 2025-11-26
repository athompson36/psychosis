# Home Feature

## Overview

The Home feature provides the main dashboard screen for the Psychosis app. It demonstrates the MVVM architecture pattern with a complete implementation.

## Structure

```
Home/
├── Models/
│   └── HomeItem.swift          # Data model
├── ViewModels/
│   └── HomeViewModel.swift     # Business logic
├── Views/
│   └── HomeView.swift          # UI components
└── Services/                   # (Future: API services if needed)
```

## Architecture

### Model: HomeItem
- Represents an item displayed on the home screen
- Identifiable, Codable, Equatable
- Contains: id, title, description, iconName, timestamp

### ViewModel: HomeViewModel
- Manages home screen state
- Handles data loading and persistence
- Uses StorageManager for local storage
- Observable for SwiftUI binding

### View: HomeView
- SwiftUI view displaying home content
- Shows welcome header, app info, and items list
- Handles loading, error, and empty states
- Supports pull-to-refresh

## Features

- ✅ Welcome screen with app branding
- ✅ Dynamic items list
- ✅ Local data persistence
- ✅ Pull-to-refresh
- ✅ Loading states
- ✅ Error handling
- ✅ Empty states
- ✅ Modern UI with AppTheme

## Usage

After adding files to Xcode project, update `PsychosisApp.swift`:

```swift
WindowGroup {
    HomeView()
}
```

## Future Enhancements

- [ ] Add item functionality
- [ ] Delete item functionality
- [ ] API integration for remote data
- [ ] Search functionality
- [ ] Filtering and sorting

---

*This feature serves as a template for future feature development.*

