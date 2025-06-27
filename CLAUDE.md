# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Doodle Disaster is a multiplayer drawing and guessing game built with Flutter. Players connect via Bluetooth, take turns drawing doodles based on prompts, and guess what others have drawn in a hilarious chain of misinterpretation.

## Key Commands

### Development
```bash
flutter pub get              # Install dependencies
flutter run                  # Run app in debug mode
flutter run -d <device_id>   # Run on specific device
```

### Building
```bash
flutter build apk           # Build Android APK
flutter build ios           # Build iOS app (Mac only)
flutter build macos         # Build macOS desktop app
```

### Code Quality
```bash
flutter analyze             # Run static analysis
flutter format .            # Format all Dart files
flutter test                # Run all tests
flutter test --coverage     # Run tests with coverage report
```

## Architecture

This project follows **Domain-Driven Design (DDD)** with clean architecture:

- **lib/domain/** - Core business logic, models, and game rules
  - Models are immutable using Equatable
  - Key entities: Player, GameSession, DrawingData, DrawingChain
  - PlayerAction enum defines all possible game instructions
  
- **lib/presentation/** - UI layer with screens, widgets, and state management
  - Uses Riverpod for state management
  - Material Design 3 with custom theming
  
- **lib/core/** - Shared utilities and constants

## State Management

Uses Riverpod with providers located in `lib/presentation/providers/`. Key patterns:
- ConsumerWidget for reactive UI components
- StateNotifierProvider for complex state
- Provider for dependency injection

## Bluetooth Development

**IMPORTANT**: Bluetooth features require physical devices for testing. Emulators will not work.

The app uses `flutter_blue_plus` for Bluetooth Low Energy connectivity. When implementing Bluetooth features:
- Test on real devices only
- Handle connection failures gracefully
- Implement proper cleanup on disconnect
- Follow the patterns in domain models for player management

## Drawing Implementation

Uses `perfect_freehand` package for smooth drawing strokes. Key considerations:
- DrawingData model stores strokes as List<DrawingStroke>
- Each stroke contains points with position and pressure
- Implement efficient rendering to avoid performance issues

## Testing Requirements

When adding new features:
1. Write unit tests for domain models
2. Test state management logic
3. Widget tests for critical UI components
4. Integration tests for game flow

## Platform-Specific Notes

### iOS Setup
Must add Bluetooth permissions to `ios/Runner/Info.plist`:
```xml
<key>NSBluetoothAlwaysUsageDescription</key>
<string>Doodle Disaster needs Bluetooth to connect with other players</string>
<key>NSBluetoothPeripheralUsageDescription</key>
<string>Doodle Disaster uses Bluetooth to host and join games</string>
```

### Android
Bluetooth permissions are requested at runtime. No additional setup needed.

## Current Implementation Status

**Completed**: Domain models, project structure, basic navigation, theming
**In Progress**: Bluetooth service, drawing canvas, game screens, state providers

## Code Conventions

- Use factory constructors for creating domain objects
- Implement copyWith pattern for immutability
- Document complex game logic inline
- Follow conventional commit format for Git commits
- Use type-safe PlayerAction enum for game instructions