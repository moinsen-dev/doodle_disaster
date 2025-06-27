import 'package:equatable/equatable.dart';

/// Defines all configurable settings for a game session.
/// 
/// Think of this as the game's rulebook - it contains all the parameters
/// that players can adjust before starting a game. Just like how Monopoly
/// has house rules (like money on Free Parking), our game allows hosts to
/// customize the experience for their group.
/// 
/// We use sensible defaults so players can quickly start a game without
/// getting bogged down in configuration, but everything can be customized
/// for groups that want a different experience.
class GameSettings extends Equatable {
  /// Minimum number of players required to start a game.
  /// 
  /// We need at least 3 players because with only 2, there's no
  /// transformation - the drawing would go directly back to the person
  /// who made the original prompt. Three creates the minimum viable
  /// chain of interpretation.
  final int minPlayers;
  
  /// Maximum number of players allowed in a session.
  /// 
  /// We cap this at 8 for several reasons:
  /// 1. Bluetooth connection management becomes complex with many devices
  /// 2. Longer chains mean longer wait times between turns
  /// 3. The reveal phase becomes unwieldy with too many transformations
  final int maxPlayers;
  
  /// Time limit for drawing in seconds.
  /// 
  /// 60 seconds creates urgency without being stressful. It's long enough
  /// to draw something recognizable but short enough to keep the game moving.
  /// Think of it as the sweet spot between "rushed scribble" and "masterpiece".
  final int drawingTimeSeconds;
  
  /// Time limit for guessing in seconds.
  /// 
  /// Guessing is quicker than drawing, so 30 seconds is plenty. This prevents
  /// players from overthinking and keeps the game's momentum going. Sometimes
  /// the first instinct is the funniest!
  final int guessingTimeSeconds;
  
  /// Total number of rounds to play.
  /// 
  /// Each round gives every player one original prompt to start a chain.
  /// Three rounds is usually perfect for a 15-20 minute game session.
  final int totalRounds;
  
  /// Whether to show player names during the game.
  /// 
  /// Some groups prefer anonymous play during the game to avoid bias
  /// ("Oh, that terrible drawing must be from Bob!"). Names are revealed
  /// during the final reveal for accountability and laughs.
  final bool showPlayerNamesDuringGame;
  
  /// Whether to enable the voting phase after each round.
  /// 
  /// Voting adds a competitive element where players can award points
  /// for the funniest transformation, best drawing, or most creative guess.
  final bool enableVoting;
  
  /// Points awarded for receiving a vote.
  /// 
  /// Simple scoring system - each vote is worth a fixed number of points.
  /// This keeps scoring transparent and easy to understand.
  final int pointsPerVote;
  
  const GameSettings({
    this.minPlayers = 3,
    this.maxPlayers = 8,
    this.drawingTimeSeconds = 60,
    this.guessingTimeSeconds = 30,
    this.totalRounds = 3,
    this.showPlayerNamesDuringGame = false,
    this.enableVoting = true,
    this.pointsPerVote = 10,
  });
  
  /// Creates settings optimized for a quick game.
  /// 
  /// Perfect for groups that want to try the game without a big time
  /// commitment. It's like an appetizer before the main course.
  factory GameSettings.quickGame() {
    return const GameSettings(
      totalRounds: 1,
      drawingTimeSeconds: 45,
      guessingTimeSeconds: 20,
    );
  }
  
  /// Creates settings for a longer, more competitive game.
  /// 
  /// For groups that really want to dive deep and create elaborate
  /// drawing chains. More time means more detailed drawings and more
  /// thoughtful guesses.
  factory GameSettings.extendedGame() {
    return const GameSettings(
      totalRounds: 5,
      drawingTimeSeconds: 90,
      guessingTimeSeconds: 45,
      pointsPerVote: 25,
    );
  }
  
  /// Creates a copy with modified values.
  /// 
  /// This follows the same immutability pattern we've used throughout.
  /// Want to change just the time limit? Create a new settings object
  /// with that one change.
  GameSettings copyWith({
    int? minPlayers,
    int? maxPlayers,
    int? drawingTimeSeconds,
    int? guessingTimeSeconds,
    int? totalRounds,
    bool? showPlayerNamesDuringGame,
    bool? enableVoting,
    int? pointsPerVote,
  }) {
    return GameSettings(
      minPlayers: minPlayers ?? this.minPlayers,
      maxPlayers: maxPlayers ?? this.maxPlayers,
      drawingTimeSeconds: drawingTimeSeconds ?? this.drawingTimeSeconds,
      guessingTimeSeconds: guessingTimeSeconds ?? this.guessingTimeSeconds,
      totalRounds: totalRounds ?? this.totalRounds,
      showPlayerNamesDuringGame: showPlayerNamesDuringGame ?? this.showPlayerNamesDuringGame,
      enableVoting: enableVoting ?? this.enableVoting,
      pointsPerVote: pointsPerVote ?? this.pointsPerVote,
    );
  }
  
  /// Validates that the settings make sense.
  /// 
  /// This is defensive programming - we check that the settings are
  /// logically consistent. It's better to catch configuration errors
  /// early than to have weird bugs during gameplay.
  bool get isValid {
    return minPlayers >= 3 &&
           maxPlayers >= minPlayers &&
           maxPlayers <= 12 &&  // Reasonable upper limit
           drawingTimeSeconds >= 15 &&
           drawingTimeSeconds <= 300 &&  // 5 minutes max
           guessingTimeSeconds >= 10 &&
           guessingTimeSeconds <= 120 &&  // 2 minutes max
           totalRounds >= 1 &&
           totalRounds <= 10 &&
           pointsPerVote >= 0;
  }
  
  /// Provides a human-readable summary of the settings.
  /// 
  /// Useful for displaying to players before they confirm starting a game.
  /// "Are these the settings you want?" becomes much clearer with a summary.
  String get summary {
    return '$minPlayers-$maxPlayers players, '
           '$totalRounds round${totalRounds == 1 ? "" : "s"}, '
           '${drawingTimeSeconds}s to draw, '
           '${guessingTimeSeconds}s to guess';
  }
  
  Map<String, dynamic> toJson() => {
    'minPlayers': minPlayers,
    'maxPlayers': maxPlayers,
    'drawingTimeSeconds': drawingTimeSeconds,
    'guessingTimeSeconds': guessingTimeSeconds,
    'totalRounds': totalRounds,
    'showPlayerNamesDuringGame': showPlayerNamesDuringGame,
    'enableVoting': enableVoting,
    'pointsPerVote': pointsPerVote,
  };
  
  factory GameSettings.fromJson(Map<String, dynamic> json) {
    return GameSettings(
      minPlayers: json['minPlayers'] as int? ?? 3,
      maxPlayers: json['maxPlayers'] as int? ?? 8,
      drawingTimeSeconds: json['drawingTimeSeconds'] as int? ?? 60,
      guessingTimeSeconds: json['guessingTimeSeconds'] as int? ?? 30,
      totalRounds: json['totalRounds'] as int? ?? 3,
      showPlayerNamesDuringGame: json['showPlayerNamesDuringGame'] as bool? ?? false,
      enableVoting: json['enableVoting'] as bool? ?? true,
      pointsPerVote: json['pointsPerVote'] as int? ?? 10,
    );
  }
  
  @override
  List<Object?> get props => [
    minPlayers,
    maxPlayers,
    drawingTimeSeconds,
    guessingTimeSeconds,
    totalRounds,
    showPlayerNamesDuringGame,
    enableVoting,
    pointsPerVote,
  ];
}
