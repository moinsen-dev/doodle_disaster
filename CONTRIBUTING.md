# Contributing to Doodle Disaster

First off, thank you for considering contributing to Doodle Disaster! 🎉

It's people like you that make Doodle Disaster such a fun tool for bringing laughter to groups everywhere. This document provides guidelines for contributing to the project - following these helps maintain quality and makes the review process smoother for everyone.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [How Can I Contribute?](#how-can-i-contribute)
- [Development Process](#development-process)
- [Style Guidelines](#style-guidelines)
- [Commit Messages](#commit-messages)
- [Pull Request Process](#pull-request-process)
- [Community](#community)

## Code of Conduct

This project and everyone participating in it is governed by our [Code of Conduct](CODE_OF_CONDUCT.md). By participating, you are expected to uphold this code. Please report unacceptable behavior to the project maintainers.

## Getting Started

### Understanding the Project

Before contributing, it's helpful to understand the project structure. Doodle Disaster follows Domain-Driven Design principles, which means:

- Business logic lives in the `domain` layer
- UI components are in the `presentation` layer
- Shared utilities go in the `core` layer

Think of it like building a house: the domain is the foundation and structure, presentation is the paint and decorations, and core contains the tools we use throughout construction.

### Setting Up Your Development Environment

1. **Fork the Repository**
   ```bash
   # Click the 'Fork' button on GitHub, then:
   git clone https://github.com/yourusername/doodle_disaster.git
   cd doodle_disaster
   ```

2. **Create a Branch**
   ```bash
   git checkout -b feature/your-feature-name
   # or
   git checkout -b fix/your-bug-fix
   ```

3. **Install Dependencies**
   ```bash
   flutter pub get
   ```

4. **Run Tests**
   ```bash
   flutter test
   ```

## How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check existing issues to avoid duplicates. When you create a bug report, include as many details as possible:

- **Use a clear title** that describes the issue
- **Describe the exact steps** to reproduce the problem
- **Provide specific examples** with code snippets if applicable
- **Describe the behavior** you observed vs. what you expected
- **Include screenshots** if the issue is visual
- **Note your environment** (OS, Flutter version, device)

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. When creating an enhancement suggestion:

- **Use a clear title** that summarizes the idea
- **Provide a detailed description** of the suggested enhancement
- **Explain why** this enhancement would be useful
- **List any drawbacks** or considerations
- **Include mockups** for UI changes when possible

### Your First Code Contribution

Unsure where to begin? Look for these labels in our issues:

- `good first issue` - Simple issues perfect for beginners
- `help wanted` - Issues where we need community help
- `documentation` - Help improve our docs
- `enhancement` - New features you could implement

### Adding New Features

When adding new features, consider:

1. **Does it fit the game's vision?** Doodle Disaster aims to be simple, fun, and social
2. **Is it accessible?** Features should work for all players
3. **Is it maintainable?** Complex features need clear documentation
4. **Does it enhance the core experience?** Avoid feature creep

## Development Process

### Architecture Principles

We follow Domain-Driven Design (DDD) principles. When contributing:

1. **Domain First**: Model the business logic before implementing UI
2. **Immutability**: Prefer immutable objects and state
3. **Type Safety**: Use Dart's type system to prevent errors
4. **Testability**: Write code that's easy to test

Example of our patterns:

```dart
// Good: Immutable domain model with factory methods
class Player extends Equatable {
  final String id;
  final String name;
  
  const Player({required this.id, required this.name});
  
  Player copyWith({String? name}) {
    return Player(id: id, name: name ?? this.name);
  }
}

// Avoid: Mutable state in domain models
class BadPlayer {
  String id;
  String name; // Don't make domain properties mutable
  
  void changeName(String newName) { // Avoid mutation methods
    name = newName;
  }
}
```

### Testing Requirements

All new features should include tests:

- **Unit tests** for domain logic
- **Widget tests** for UI components
- **Integration tests** for critical user flows

Example test structure:

```dart
void main() {
  group('DrawingChain', () {
    test('should alternate between drawings and guesses', () {
      // Arrange
      final chain = DrawingChain(
        originalPrompt: 'cat',
        startingPlayerId: 'player1',
      );
      
      // Act & Assert
      expect(chain.nextLinkType, ChainLinkType.drawing);
      // ... more assertions
    });
  });
}
```

## Style Guidelines

### Dart/Flutter Style

We follow the official [Dart style guide](https://dart.dev/guides/language/effective-dart/style) with these additions:

1. **Meaningful Names**: Use descriptive variable and function names
   ```dart
   // Good
   final playerScore = calculateScore(player);
   
   // Avoid
   final ps = calc(p);
   ```

2. **Comments**: Explain why, not what
   ```dart
   // Good: Explains the reasoning
   // We limit strokes to prevent Bluetooth packet overflow
   if (strokeCount > maxStrokes) {
   
   // Avoid: States the obvious
   // Increment counter
   counter++;
   ```

3. **File Organization**: One class per file for domain models

### UI/UX Guidelines

- **Consistency**: Follow Material Design principles
- **Responsiveness**: Test on different screen sizes
- **Accessibility**: Include semantic labels for screen readers
- **Performance**: Keep drawing at 60fps

## Commit Messages

We follow conventional commits for clear history:

```
<type>(<scope>): <subject>

<body>

<footer>
```

Types:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, etc)
- `refactor`: Code changes that neither fix bugs nor add features
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

Examples:
```bash
feat(drawing): add undo functionality to canvas

fix(bluetooth): handle connection timeout gracefully

docs(readme): update installation instructions for iOS
```

## Pull Request Process

1. **Update Documentation**: Include any necessary documentation changes
2. **Add Tests**: Ensure your changes are tested
3. **Follow Style**: Run `flutter format` and `flutter analyze`
4. **Update CHANGELOG**: Add an entry under [Unreleased]
5. **Small PRs**: Keep pull requests focused on a single feature/fix
6. **Clear Description**: Explain what changed and why

### PR Description Template

```markdown
## Description
Brief description of what this PR does

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
- [ ] Unit tests pass
- [ ] Manual testing completed
- [ ] No regression in existing features

## Screenshots (if applicable)
Add screenshots for UI changes

## Additional Notes
Any additional context or notes for reviewers
```

### Review Process

Your PR will be reviewed by maintainers who will check:

1. **Code Quality**: Does it follow our patterns?
2. **Test Coverage**: Are changes properly tested?
3. **Documentation**: Is it documented appropriately?
4. **Performance**: Does it maintain good performance?
5. **UX Impact**: Does it enhance the user experience?

## Community

### Getting Help

- **Discord**: Join our community server (link in README)
- **Discussions**: Use GitHub Discussions for questions
- **Issues**: Report bugs or suggest features
- **Stack Overflow**: Tag questions with `doodle-disaster`

### Recognition

Contributors are recognized in several ways:

- Listed in our CONTRIBUTORS file
- Mentioned in release notes
- Special roles in our Discord community
- Eternal gratitude from players worldwide!

## Development Tips

### Debugging Bluetooth

Bluetooth can be tricky. Here are some tips:

1. Always test on physical devices
2. Handle connection failures gracefully
3. Add logging for connection state changes
4. Test with multiple devices simultaneously

### Optimizing Drawing Performance

For smooth drawing:

1. Limit points per stroke
2. Use efficient data structures
3. Throttle input events if needed
4. Profile on lower-end devices

### Working with State Management

Our Riverpod patterns:

1. Keep providers focused and single-purpose
2. Use appropriate provider types (State, Future, Stream)
3. Document provider dependencies
4. Test providers independently

## Final Words

Remember, contributing to open source should be fun! Don't be afraid to ask questions, suggest improvements, or try something new. Every contribution, no matter how small, makes Doodle Disaster better for everyone.

Thank you for being part of our community! 🎨✨
