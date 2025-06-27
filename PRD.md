# Product Requirements Document: Doodle Disaster

## Game Concept
"Draw it. Pass it. Watch it fall apart!"

Doodle Disaster transforms the classic "Telephone" game into a digital drawing experience. Players draw prompts, guess drawings, and watch as simple concepts hilariously transform through chains of interpretation.

## Domain Model Architecture

### Core Entities

1. **GameSession**
   - Manages the overall game state
   - Contains all players and rounds
   - Handles game flow coordination

2. **Player**
   - Represents each participant
   - Stores device connection info
   - Tracks scoring and statistics

3. **Round**
   - Contains multiple drawing chains
   - One chain per player in the round

4. **DrawingChain**
   - Original prompt
   - Series of alternating drawings and guesses
   - Final reveal sequence

5. **ChainLink**
   - Either a Drawing or a Guess
   - Linked to creating player
   - Timestamp for tracking

## Game Flow

1. **Lobby Phase**
   - Host creates game session
   - Players join via room code
   - Minimum 3 players, maximum 8

2. **Drawing Phase** (60 seconds)
   - Each player receives unique prompt
   - Simple drawing tools: black pen, eraser, clear
   - Auto-submit when time expires

3. **Guessing Phase** (30 seconds)
   - Players receive previous player's drawing
   - Type what they think it represents
   - Quick submission encouraged

4. **Repeat Cycle**
   - Drawings and guesses alternate
   - Continue until chain returns to originator

5. **Reveal Phase**
   - Show complete transformation chains
   - Players vote for funniest transformation
   - Points awarded for votes received

## Technical Stack

### Flutter Packages
- `flutter_blue_plus`: Bluetooth connectivity
- `perfect_freehand`: Smooth drawing strokes
- `riverpod`: State management
- `uuid`: Unique identifiers
- `shared_preferences`: Local settings storage

### Architecture
- Domain-driven design with clear separation
- Repository pattern for data persistence
- Service layer for Bluetooth communication
- Provider pattern for UI state management

## MVP Features (2-Day Sprint)

### Day 1
- Basic project structure and domain models
- Drawing canvas with stroke capture
- Simple Bluetooth discovery and connection
- Basic game session creation/joining

### Day 2
- Game flow implementation
- Drawing/guess passing via Bluetooth
- Reveal sequence UI
- Error handling and connection recovery

## Deferred Features
- Multiple rounds
- Custom prompt creation
- Player avatars
- Sound effects
- Achievement system
- Drawing tools (colors, brush sizes)

## UI/UX Principles
- Minimal interface during gameplay
- Full-screen drawing canvas
- Large, thumb-friendly buttons
- Clear visual feedback for all actions
- Graceful handling of connection issues

## Data Exchange Protocol
- Compact drawing format (stroke points)
- Message queue for reliability
- Automatic reconnection handling
- Typical drawing size: 5-10KB

## Success Metrics
- Game session completion rate >80%
- Average session length: 15-30 minutes
- Player retention for multiple rounds
- Positive app store reviews focusing on "fun" and "laughter"
