# 🎨 Doodle Disaster

<div align="center">
  
  **Draw it. Pass it. Watch it fall apart!**
  
  [![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)](https://flutter.dev)
  [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](https://opensource.org/licenses/MIT)
  [![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=for-the-badge)](http://makeapullrequest.com)
  
  <img src="https://via.placeholder.com/600x300/6B46C1/FFFFFF?text=Doodle+Disaster+Demo" alt="Doodle Disaster Demo" width="600">
  
  *A hilarious multiplayer drawing game where simple prompts transform into delightful disasters through chains of interpretation.*
  
</div>

## 🎮 About The Game

Doodle Disaster brings the classic "Telephone" game into the digital age. Players take turns drawing prompts and guessing what others have drawn, creating hilarious chains of artistic interpretation. What starts as "cat on a skateboard" might end up as "alien pizza delivery" through the beautiful chaos of human creativity and questionable drawing skills.

### ✨ Key Features

- **Local Multiplayer via Bluetooth** - No internet required! Perfect for game nights, parties, or casual gatherings
- **Simple, Intuitive Gameplay** - Easy to learn, impossible to master (because mastery isn't the point - laughter is!)
- **Minimal Design** - Clean interface that gets out of the way and lets the terrible drawings shine
- **Customizable Settings** - Adjust timer lengths, number of rounds, and more to fit your group's style
- **No Artistic Skill Required** - In fact, being bad at drawing often makes the game more fun!

## 🚀 Getting Started

### Prerequisites

Before you begin, ensure you have the following installed on your development machine:

- **Flutter SDK** (3.0.0 or higher) - [Installation Guide](https://flutter.dev/docs/get-started/install)
- **Dart SDK** (2.17.0 or higher) - Comes with Flutter
- **Android Studio** or **VS Code** with Flutter extensions
- **A physical device** for testing (Bluetooth doesn't work on emulators)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/doodle_disaster.git
   cd doodle_disaster
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### Platform-Specific Setup

#### Android
No additional setup required! The app will request Bluetooth permissions at runtime.

#### iOS
Add the following to your `ios/Runner/Info.plist`:
```xml
<key>NSBluetoothAlwaysUsageDescription</key>
<string>Doodle Disaster uses Bluetooth to connect with nearby players</string>
<key>NSBluetoothPeripheralUsageDescription</key>
<string>Doodle Disaster uses Bluetooth to create local multiplayer games</string>
```

## 🎯 How to Play

1. **Create or Join a Game**
   - One player creates a game and shares the room code
   - Other players join using the code

2. **Drawing Phase**
   - Each player receives a unique prompt
   - Draw your interpretation within the time limit
   - Don't worry about artistic quality - quick and recognizable is the goal!

3. **Guessing Phase**
   - View another player's drawing
   - Type what you think it represents
   - Be creative but try to be accurate!

4. **The Reveal**
   - Watch as each chain of drawings and guesses is revealed
   - Laugh at the hilarious transformations
   - Vote for your favorite disaster (optional)

## 🏗️ Architecture

Doodle Disaster follows Domain-Driven Design principles with a clean architecture approach:

```
lib/
├── domain/           # Business logic and models
│   ├── models/      # Game entities (Player, DrawingData, GameSession, etc.)
│   ├── repositories/# Data interfaces
│   └── services/    # Business logic services
├── presentation/    # UI layer
│   ├── screens/     # Full-screen widgets
│   ├── widgets/     # Reusable UI components
│   └── providers/   # State management (Riverpod)
└── core/           # Shared utilities and constants
```

### Key Technologies

- **Flutter** - Cross-platform UI framework
- **Riverpod** - State management solution
- **flutter_blue_plus** - Bluetooth connectivity
- **perfect_freehand** - Smooth drawing stroke algorithm
- **uuid** - Unique identifier generation

## 🤝 Contributing

We love contributions! Doodle Disaster is a community project, and we welcome developers, designers, and idea-contributors alike.

### Ways to Contribute

1. **Report Bugs** - Found something broken? [Open an issue](https://github.com/yourusername/doodle_disaster/issues)
2. **Suggest Features** - Have an idea? We'd love to hear it!
3. **Submit Pull Requests** - Check out our [Contributing Guidelines](CONTRIBUTING.md)
4. **Improve Documentation** - Help others by improving our docs
5. **Create Prompt Packs** - Design themed prompt collections
6. **Translate** - Help make the game accessible in more languages

### Development Setup

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

See [CONTRIBUTING.md](CONTRIBUTING.md) for detailed guidelines.

## 📱 Screenshots

<div align="center">
  <img src="https://via.placeholder.com/250x500/6B46C1/FFFFFF?text=Home+Screen" alt="Home Screen" width="250">
  <img src="https://via.placeholder.com/250x500/6B46C1/FFFFFF?text=Drawing+Phase" alt="Drawing Phase" width="250">
  <img src="https://via.placeholder.com/250x500/6B46C1/FFFFFF?text=Reveal+Phase" alt="Reveal Phase" width="250">
</div>

## 🗺️ Roadmap

### Current Version (MVP)
- ✅ Core drawing and guessing gameplay
- ✅ Bluetooth multiplayer support
- ✅ Basic prompt system
- ✅ Single round gameplay

### Upcoming Features
- 📱 Online multiplayer support
- 🎨 Drawing tools (colors, brush sizes)
- 🏆 Achievement system
- 🌍 Internationalization
- 🎵 Sound effects and music
- 💾 Game history and statistics
- 🎭 Custom prompt packs
- 🤖 AI-generated prompts

See the [open issues](https://github.com/yourusername/doodle_disaster/issues) for a full list of proposed features.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details. This means you can:
- Use the code for commercial purposes
- Modify and distribute the code
- Use it for private purposes

All we ask is that you include the original copyright and license notice in any copies.

## 🙏 Acknowledgments

- Inspired by the classic party games Telestrations and Telephone Pictionary
- Built with [Flutter](https://flutter.dev) and love
- Drawing smoothing powered by [perfect-freehand](https://github.com/steveruizok/perfect-freehand)
- Icons from [Material Design Icons](https://material.io/resources/icons/)

## 📞 Contact

Got questions? Reach out!

- Project Link: [https://github.com/yourusername/doodle_disaster](https://github.com/yourusername/doodle_disaster)
- Issue Tracker: [GitHub Issues](https://github.com/yourusername/doodle_disaster/issues)
- Discussions: [GitHub Discussions](https://github.com/yourusername/doodle_disaster/discussions)

---

<div align="center">
  Made with ❤️ by the open-source community
  
  If you enjoyed Doodle Disaster, please consider giving it a ⭐!
</div>
