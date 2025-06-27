import 'drawing_data.dart';

/// Represents the possible actions a player can take during the game.
/// 
/// This is a sealed class pattern - a powerful way to represent a fixed set
/// of possibilities. Think of it like a menu at a restaurant: you can order
/// specific dishes, but you can't order something that's not on the menu.
/// 
/// Using this pattern helps us avoid errors. Instead of passing strings around
/// and hoping we spell them correctly, we have concrete types that the
/// compiler can check for us.
abstract class PlayerAction {
  const PlayerAction();
  
  // These factory constructors create specific types of actions.
  // Notice how each one carries the exact data needed for that action?
  
  /// Player should draw the original text prompt.
  factory PlayerAction.drawPrompt(String prompt) = DrawPromptAction;
  
  /// Player should draw their interpretation of someone's guess.
  factory PlayerAction.drawGuess(String guess) = DrawGuessAction;
  
  /// Player should guess what a drawing represents.
  factory PlayerAction.guessDrawing(DrawingData drawing) = GuessDrawingAction;
  
  /// Player should wait for others to finish their turns.
  static const PlayerAction wait = WaitAction();
  
  /// Pattern matching method to handle different action types.
  /// 
  /// This is like a switch statement on steroids! It ensures we handle
  /// every possible type of action. If we add a new action type and forget
  /// to handle it somewhere, the compiler will remind us.
  T when<T>({
    required T Function(String prompt) drawPrompt,
    required T Function(String guess) drawGuess,
    required T Function(DrawingData drawing) guessDrawing,
    required T Function() wait,
  });
  
  /// Converts the action to JSON for serialization
  Map<String, dynamic> toJson();
  
  /// Creates a PlayerAction from JSON data
  factory PlayerAction.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    switch (type) {
      case 'drawPrompt':
        return DrawPromptAction(json['prompt'] as String);
      case 'drawGuess':
        return DrawGuessAction(json['guess'] as String);
      case 'guessDrawing':
        return GuessDrawingAction(
          DrawingData.fromJson(json['drawing'] as Map<String, dynamic>),
        );
      case 'wait':
        return const WaitAction();
      default:
        throw ArgumentError('Unknown PlayerAction type: $type');
    }
  }
}

/// Action to draw an original prompt.
class DrawPromptAction extends PlayerAction {
  final String prompt;
  
  const DrawPromptAction(this.prompt);
  
  @override
  T when<T>({
    required T Function(String prompt) drawPrompt,
    required T Function(String guess) drawGuess,
    required T Function(DrawingData drawing) guessDrawing,
    required T Function() wait,
  }) {
    return drawPrompt(prompt);
  }
  
  @override
  Map<String, dynamic> toJson() => {
    'type': 'drawPrompt',
    'prompt': prompt,
  };
}

/// Action to draw based on someone's guess.
class DrawGuessAction extends PlayerAction {
  final String guess;
  
  const DrawGuessAction(this.guess);
  
  @override
  T when<T>({
    required T Function(String prompt) drawPrompt,
    required T Function(String guess) drawGuess,
    required T Function(DrawingData drawing) guessDrawing,
    required T Function() wait,
  }) {
    return drawGuess(guess);
  }
  
  @override
  Map<String, dynamic> toJson() => {
    'type': 'drawGuess',
    'guess': guess,
  };
}

/// Action to guess what a drawing represents.
class GuessDrawingAction extends PlayerAction {
  final DrawingData drawing;
  
  const GuessDrawingAction(this.drawing);
  
  @override
  T when<T>({
    required T Function(String prompt) drawPrompt,
    required T Function(String guess) drawGuess,
    required T Function(DrawingData drawing) guessDrawing,
    required T Function() wait,
  }) {
    return guessDrawing(drawing);
  }
  
  @override
  Map<String, dynamic> toJson() => {
    'type': 'guessDrawing',
    'drawing': drawing.toJson(),
  };
}

/// Action to wait for other players.
class WaitAction extends PlayerAction {
  const WaitAction();
  
  @override
  T when<T>({
    required T Function(String prompt) drawPrompt,
    required T Function(String guess) drawGuess,
    required T Function(DrawingData drawing) guessDrawing,
    required T Function() wait,
  }) {
    return wait();
  }
  
  @override
  Map<String, dynamic> toJson() => {
    'type': 'wait',
  };
}
