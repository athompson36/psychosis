# Features

This directory contains all feature modules following the MVVM architecture pattern.

## Structure

Each feature follows this structure:
```
FeatureName/
├── Models/          # Data models
├── ViewModels/      # Business logic
├── Views/           # SwiftUI views
└── Services/        # API services (if needed)
```

## Current Features

### 🏠 Home
- **Location**: `Features/Home/`
- **Purpose**: Main dashboard screen
- **Components**:
  - `HomeItem` model
  - `HomeViewModel` with async data loading
  - `HomeView` with pull-to-refresh
- **Features**:
  - Welcome screen
  - Dynamic items list
  - Local persistence
  - Navigation to detail views

### ⚙️ Settings
- **Location**: `Features/Settings/`
- **Purpose**: App settings and preferences
- **Components**:
  - `SettingsOption` and `SettingsSection` models
  - `SettingsViewModel` with preference management
  - `SettingsView` with toggle switches
- **Features**:
  - Dark mode toggle
  - Notifications toggle
  - Haptic feedback toggle
  - App information display
  - Persistent preferences

### 📄 Detail
- **Location**: `Features/Detail/`
- **Purpose**: Detail view for items
- **Components**:
  - `DetailItem` model
  - `DetailViewModel` with async loading
  - `DetailView` with rich content display
- **Features**:
  - Navigation from list items
  - Async data loading
  - Error handling
  - Rich content display

### 🧭 Navigation
- **Location**: `Features/Home/Views/MainTabView.swift`
- **Purpose**: Main app navigation
- **Features**:
  - Tab-based navigation
  - Home and Settings tabs
  - Consistent navigation structure

## Adding New Features

1. **Create feature folder**:
   ```bash
   mkdir -p Features/NewFeature/{Models,ViewModels,Views,Services}
   ```

2. **Follow MVVM pattern**:
   - Models: Data structures (structs, Codable)
   - ViewModels: Business logic (@Observable)
   - Views: SwiftUI UI components

3. **Add to navigation**:
   - Update `MainTabView` if needed
   - Add navigation links in appropriate views

4. **Add to Xcode project**:
   - Right-click project → Add Files
   - Select feature folder
   - Ensure "Add to targets: Psychosis" is checked

## Best Practices

- ✅ Keep features modular and independent
- ✅ Use dependency injection for services
- ✅ Follow MVVM architecture consistently
- ✅ Use AppTheme for styling
- ✅ Implement error handling
- ✅ Add loading states
- ✅ Support pull-to-refresh where appropriate
- ✅ Use async/await for async operations

---

*Each feature is self-contained and can be developed independently.*

