import 'package:equatable/equatable.dart';
import 'drawing_data.dart';

/// Represents the type of content in a chain link.
/// 
/// This enum is like a label on our shipping box - it tells us what's inside
/// without having to open it. In programming, we call this "type safety" -
/// it helps us avoid errors by knowing exactly what kind of data we're
/// working with.
enum ChainLinkType { drawing, guess }

/// Represents a single link in the drawing chain.
/// 
/// A chain link can contain either a drawing or a text guess, but never both.
/// This is a fundamental rule of our game - you either draw what you see
/// (if you're looking at text) or guess what you see (if you're looking at
/// a drawing).
/// 
/// Think of this like a game of telephone where some people whisper and
/// others draw - each person in the chain does one or the other, creating
/// an alternating pattern.
abstract class ChainLink extends Equatable {
  final String id;
  final String playerId;
  final DateTime createdAt;
  final ChainLinkType type;
  
  const ChainLink({
    required this.id,
    required this.playerId,
    required this.createdAt,
    required this.type,
  });
  
  /// Factory constructor that creates the appropriate subclass based on content.
  /// 
  /// This is a powerful pattern in Dart. Instead of having the caller figure out
  /// which specific class to create, we provide a smart factory that makes the
  /// decision based on what content is provided.
  factory ChainLink.create({
    required String id,
    required String playerId,
    DrawingData? drawing,
    String? guess,
  }) {
    // Here's where we enforce our rule: you must provide either a drawing
    // OR a guess, but not both and not neither.
    if (drawing != null && guess == null) {
      return DrawingLink(
        id: id,
        playerId: playerId,
        drawing: drawing,
        createdAt: DateTime.now(),
      );
    } else if (guess != null && drawing == null) {
      return GuessLink(
        id: id,
        playerId: playerId,
        guess: guess,
        createdAt: DateTime.now(),
      );
    } else {
      // This is defensive programming - we throw an error if someone tries
      // to break our rules. It's better to fail fast and clearly than to
      // have mysterious bugs later.
      throw ArgumentError(
        'ChainLink must have either a drawing or a guess, but not both or neither',
      );
    }
  }
  
  /// Converts the link to JSON for transmission.
  /// 
  /// Notice this is abstract - each subclass must implement its own version.
  /// This ensures that DrawingLinks and GuessLinks are serialized appropriately
  /// for their specific content.
  Map<String, dynamic> toJson();  
  /// Factory constructor for creating a ChainLink from JSON.
  /// 
  /// This is where we "deserialize" - converting stored data back into
  /// living objects. It's like a recipe in reverse: given a cake, figure out
  /// what ingredients were used and recreate it.
  factory ChainLink.fromJson(Map<String, dynamic> json) {
    final type = ChainLinkType.values.firstWhere(
      (t) => t.name == json['type'],
    );
    
    switch (type) {
      case ChainLinkType.drawing:
        return DrawingLink.fromJson(json);
      case ChainLinkType.guess:
        return GuessLink.fromJson(json);
    }
  }
}

/// A chain link containing a drawing.
/// 
/// This represents a player's artistic interpretation of either the original
/// prompt or someone else's guess. The drawing is stored as structured data
/// (strokes and points) rather than as an image file, which keeps our data
/// small and allows for smooth animations during the reveal phase.
class DrawingLink extends ChainLink {
  final DrawingData drawing;
  
  const DrawingLink({
    required super.id,
    required super.playerId,
    required super.createdAt,
    required this.drawing,
  }) : super(type: ChainLinkType.drawing);
  
  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'playerId': playerId,
    'createdAt': createdAt.toIso8601String(),
    'type': type.name,
    'drawing': drawing.toJson(),
  };
  
  factory DrawingLink.fromJson(Map<String, dynamic> json) {
    return DrawingLink(
      id: json['id'] as String,
      playerId: json['playerId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      drawing: DrawingData.fromJson(json['drawing'] as Map<String, dynamic>),
    );
  }
  
  @override
  List<Object?> get props => [id, playerId, createdAt, drawing];
}

/// A chain link containing a text guess.
/// 
/// This represents a player's interpretation of what they think a drawing
/// depicts. The guess is just plain text - the simpler the better! Some of
/// the funniest moments in the game come from wildly incorrect but creative
/// guesses.
class GuessLink extends ChainLink {
  final String guess;
  
  const GuessLink({
    required super.id,
    required super.playerId,
    required super.createdAt,
    required this.guess,
  }) : super(type: ChainLinkType.guess);
  
  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'playerId': playerId,
    'createdAt': createdAt.toIso8601String(),
    'type': type.name,
    'guess': guess,
  };
  
  factory GuessLink.fromJson(Map<String, dynamic> json) {
    return GuessLink(
      id: json['id'] as String,
      playerId: json['playerId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      guess: json['guess'] as String,
    );
  }
  
  @override
  List<Object?> get props => [id, playerId, createdAt, guess];
}
