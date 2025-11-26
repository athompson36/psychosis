# Architecture: Psychosis

## Architecture Decision Record (ADR)

**Date**: [Current Date]  
**Status**: Active  
**Version**: 1.0

---

## Overview

This document describes the architecture decisions, patterns, and structure for the Psychosis iOS application.

---

## Architecture Pattern

**Pattern**: MVVM (Model-View-ViewModel)

### Rationale
- Clean separation of concerns
- Testable business logic
- SwiftUI-friendly pattern
- Industry standard for iOS development
- Maintainable and scalable

### Structure
```
View (SwiftUI)
  ↓ observes
ViewModel
  ↓ uses
Model / Service Layer
```

---

## Platform & Technology Stack

### Platform
- **Primary**: iOS
- **Minimum Version**: iOS 17.0+
- **Language**: Swift 5.9+

### UI Framework
- **Primary**: SwiftUI
- **Rationale**: 
  - Modern, declarative UI framework
  - Native performance
  - Built-in state management
  - Cross-platform potential (iOS, macOS, watchOS)

### Dependency Management
- **Tool**: Swift Package Manager (SPM)
- **Rationale**:
  - Native to Xcode
  - No external tools required
  - Fast and reliable
  - Easy to manage

---

## Project Structure

```
Psychosis/
├── App/
│   ├── PsychosisApp.swift          # App entry point
│   └── AppDelegate.swift           # App delegate (if needed)
│
├── Features/
│   ├── Feature1/
│   │   ├── Views/
│   │   ├── ViewModels/
│   │   ├── Models/
│   │   └── Services/
│   └── Feature2/
│       └── ...
│
├── Core/
│   ├── Networking/
│   │   ├── APIClient.swift
│   │   ├── Endpoints.swift
│   │   └── Models/
│   │
│   ├── Storage/
│   │   ├── StorageManager.swift
│   │   └── KeychainManager.swift
│   │
│   ├── Utilities/
│   │   ├── Extensions/
│   │   ├── Helpers/
│   │   └── Constants.swift
│   │
│   └── UI/
│       ├── Components/
│       ├── Themes/
│       └── Styles/
│
├── Resources/
│   ├── Assets.xcassets/
│   ├── Localizable.strings
│   └── Fonts/
│
└── Tests/
    ├── UnitTests/
    ├── IntegrationTests/
    └── UITests/
```

---

## Layer Responsibilities

### View Layer (SwiftUI)
- **Responsibility**: UI presentation and user interaction
- **Dependencies**: ViewModels only
- **Characteristics**:
  - Declarative UI
  - State-driven updates
  - No business logic
  - Minimal conditional logic

### ViewModel Layer
- **Responsibility**: Business logic, state management, data transformation
- **Dependencies**: Models, Services
- **Characteristics**:
  - Observable objects (@Observable or @Published)
  - Input validation
  - Data formatting
  - Error handling
  - Testable (no UI dependencies)

### Model Layer
- **Responsibility**: Data structures, domain models
- **Dependencies**: None (pure Swift)
- **Characteristics**:
  - Value types (structs) preferred
  - Codable for JSON
  - Equatable, Hashable where needed

### Service Layer
- **Responsibility**: External interactions (API, storage, etc.)
- **Dependencies**: Models, Networking, Storage
- **Characteristics**:
  - Protocol-based
  - Async/await for async operations
  - Error handling
  - Testable with mocks

---

## Data Flow

### Typical Flow
1. User interacts with View
2. View calls ViewModel method
3. ViewModel processes business logic
4. ViewModel calls Service
5. Service fetches/stores data
6. Service returns result to ViewModel
7. ViewModel updates state
8. View automatically updates (SwiftUI)

### Example
```swift
// View
Button("Load Data") {
    viewModel.loadData()
}

// ViewModel
func loadData() {
    Task {
        do {
            let data = try await service.fetchData()
            self.data = data
        } catch {
            self.error = error
        }
    }
}
```

---

## State Management

### Approach
- **SwiftUI State**: @State, @StateObject, @ObservedObject
- **Modern Swift**: @Observable (iOS 17+)
- **Shared State**: Environment objects or dependency injection

### Principles
- Single source of truth
- Unidirectional data flow
- Immutable state updates
- Clear ownership

---

## Networking

### Approach
- **URLSession** with async/await
- **Protocol-based** API client
- **Codable** for JSON parsing
- **Error handling** with custom error types

### Structure
```swift
protocol APIClient {
    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T
}

enum Endpoint {
    case feature1
    case feature2(id: String)
}
```

---

## Data Persistence

### Approach
- **UserDefaults**: Simple preferences
- **Keychain**: Sensitive data (tokens, passwords)
- **File System**: Documents, cache
- **Core Data / SwiftData**: Complex data (if needed)

### Strategy
- Start simple (UserDefaults)
- Add complexity as needed
- Protocol-based storage layer

---

## Error Handling

### Strategy
- **Custom Error Types**: Domain-specific errors
- **Result Types**: For operations that can fail
- **User-Friendly Messages**: Translate technical errors
- **Logging**: Debug information for developers

### Example
```swift
enum AppError: LocalizedError {
    case networkError(Error)
    case decodingError
    case unknown
    
    var errorDescription: String? {
        // User-friendly message
    }
}
```

---

## Testing Strategy

### Unit Tests
- ViewModels (business logic)
- Services (data operations)
- Utilities and helpers
- Models (validation, transformations)

### Integration Tests
- API integration
- Storage operations
- Feature workflows

### UI Tests
- Critical user flows
- Navigation
- Form validation

### Test Coverage Target
- **Minimum**: 80% code coverage
- **Focus**: Business logic and critical paths

---

## Code Style & Standards

### Swift Style
- Follow [Swift.org API Design Guidelines](https://swift.org/documentation/api-design-guidelines/)
- Use SwiftLint (optional but recommended)
- Clear, descriptive naming
- Documentation comments for public APIs

### File Organization
- One type per file (with exceptions)
- Group related files in folders
- Clear naming conventions
- Logical folder structure

### Naming Conventions
- **Views**: `FeatureNameView.swift`
- **ViewModels**: `FeatureNameViewModel.swift`
- **Models**: `FeatureNameModel.swift` or `FeatureName.swift`
- **Services**: `FeatureNameService.swift`
- **Protocols**: `FeatureNameProtocol.swift` or `FeatureNameable`

---

## Dependencies

### Current Dependencies
- None (starting fresh)

### Future Considerations
- Networking library (if URLSession becomes limiting)
- Analytics (if needed)
- Crash reporting (if needed)
- Image loading (if needed)

### Dependency Policy
- Prefer native solutions
- Add dependencies only when necessary
- Keep dependencies minimal
- Regular updates and security audits

---

## Security Considerations

### Data Security
- HTTPS for all network requests
- Keychain for sensitive data
- No sensitive data in logs
- Secure storage practices

### Code Security
- No hardcoded secrets
- Environment-based configuration
- Regular dependency updates
- Security best practices

---

## Performance Considerations

### Optimization Strategies
- Lazy loading where appropriate
- Efficient image loading and caching
- Background processing for heavy operations
- Memory management best practices
- Profiling and monitoring

### Monitoring
- App launch time
- Memory usage
- Network performance
- Battery usage
- Crash reporting

---

## Future Considerations

### Scalability
- Architecture supports feature growth
- Modular design for team collaboration
- Clear boundaries between features
- Reusable components

### Platform Expansion
- Architecture supports macOS (if needed)
- SwiftUI enables cross-platform
- Shared business logic
- Platform-specific UI where needed

---

## Decision Log

### 2025-01-XX: Initial Architecture Decisions
- **Decision**: MVVM pattern
- **Rationale**: Industry standard, SwiftUI-friendly, testable
- **Status**: Active

- **Decision**: SwiftUI for UI
- **Rationale**: Modern, declarative, native
- **Status**: Active

- **Decision**: iOS 17.0+ minimum
- **Rationale**: Access to latest features, Swift 5.9+
- **Status**: Active

- **Decision**: Swift Package Manager
- **Rationale**: Native, no external tools
- **Status**: Active

---

## References

- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui/)
- [Swift.org API Design Guidelines](https://swift.org/documentation/api-design-guidelines/)
- [Apple Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)

---

*This is a living document and will be updated as the architecture evolves.*

