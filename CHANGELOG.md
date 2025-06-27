# Changelog

All notable changes to Doodle Disaster will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Core game engine with domain-driven design architecture
- Drawing canvas with smooth stroke rendering using perfect_freehand
- Bluetooth multiplayer support for local games
- Basic game flow: create game → join → draw → guess → reveal
- Timer system for drawing and guessing phases
- Chain visualization showing how prompts transform
- Responsive Material 3 UI design
- State management using Riverpod
- Player management and turn-based gameplay

### Security
- Bluetooth permissions handled appropriately for both Android and iOS
- No data is transmitted to external servers - all gameplay is local

## [0.1.0] - 2024-01-15

### Added
- Initial project setup with Flutter 3.x
- Domain models for game logic (Player, DrawingData, GameSession, etc.)
- Basic app structure and navigation
- Project documentation (README, LICENSE, CONTRIBUTING)

### Developer Notes
- Established clean architecture patterns
- Set up dependency injection framework
- Created comprehensive testing structure

---

## Version Guidelines

Given a version number MAJOR.MINOR.PATCH, we increment the:

1. MAJOR version when we make incompatible API changes or major gameplay changes
2. MINOR version when we add functionality in a backwards compatible manner
3. PATCH version when we make backwards compatible bug fixes

## Future Versions Roadmap

### [0.2.0] - Planned
- Add sound effects and haptic feedback
- Implement player profiles and avatars
- Add tutorial for first-time players
- Improve Bluetooth connection stability

### [0.3.0] - Planned
- Multiple game modes (speed round, themed prompts)
- Drawing tools (colors, brush sizes, eraser)
- Save and share favorite drawing chains
- Statistics tracking

### [1.0.0] - Planned
- Online multiplayer support
- Cross-platform synchronization
- Premium prompt packs
- Tournament mode

---

## How to Read This Changelog

Each version section contains the following subsections when applicable:

- **Added** - New features or capabilities
- **Changed** - Changes to existing functionality
- **Deprecated** - Features that will be removed in future versions
- **Removed** - Features that have been removed
- **Fixed** - Bug fixes
- **Security** - Security improvements or vulnerability fixes

## Contributing to the Changelog

When submitting a PR, please add a changelog entry under the [Unreleased] section.
Follow the existing format and be clear about what changed and why it matters to users.

[Unreleased]: https://github.com/yourusername/doodle_disaster/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/yourusername/doodle_disaster/releases/tag/v0.1.0
