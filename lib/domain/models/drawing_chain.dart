import 'package:equatable/equatable.dart';
import 'chain_link.dart';

/// Represents a complete chain of drawings and guesses.
/// 
/// This is where the game's core mechanic lives. A DrawingChain starts with
/// a text prompt and grows as each player adds their contribution. The chain
/// alternates between drawings and guesses, creating a visual game of telephone.
/// 
/// Imagine passing a message through a line of people where every other person
/// can only draw and the others can only write. By the end, "cat sleeping on
/// a pillow" might become "UFO landing on a pizza"!
class DrawingChain extends Equatable {
  /// The original prompt that started this chain.
  /// This is the "seed" from which all the chaos grows.
  final String originalPrompt;
  
  /// The ID of the player who received this prompt.
  /// We track this so we know when the chain has completed a full circle.
  final String startingPlayerId;
  
  /// The ordered list of contributions to this chain.
  /// The beauty of using a list here is that it preserves the order -
  /// we can replay the entire transformation sequence during the reveal.
  final List<ChainLink> links;
  
  /// Indicates whether this chain has returned to its starting player.
  /// A chain is complete when it has gone through all players and returned home.
  final bool isComplete;
  
  const DrawingChain({
    required this.originalPrompt,
    required this.startingPlayerId,
    this.links = const [],
    this.isComplete = false,
  });
  
  /// Adds a new link to the chain.
  /// 
  /// This method enforces the alternating pattern of our game. If the last
  /// link was a drawing, the next must be a guess, and vice versa. This is
  /// like enforcing the rules of a board game - without rules, it's just chaos!
  DrawingChain addLink(ChainLink newLink) {
    // First, let's validate that we're maintaining the alternating pattern
    if (links.isNotEmpty) {
      final lastLink = links.last;
      
      // Check if we're trying to add the same type twice in a row
      if (lastLink.type == newLink.type) {
        throw StateError(
          'Cannot add ${newLink.type} after ${lastLink.type}. '
          'Chain links must alternate between drawings and guesses.',
        );
      }
    } else {
      // The first link must be a drawing (of the original prompt)
      if (newLink.type != ChainLinkType.drawing) {
        throw StateError(
          'The first link in a chain must be a drawing of the original prompt.',
        );
      }
    }
    
    return DrawingChain(
      originalPrompt: originalPrompt,
      startingPlayerId: startingPlayerId,
      links: [...links, newLink],
      isComplete: isComplete,
    );
  }  
  /// Marks the chain as complete.
  /// 
  /// We call this when the chain has made it all the way around the table
  /// and returned to the starting player. It's like completing a lap in a
  /// relay race - everyone has had their turn.
  DrawingChain markComplete() {
    return DrawingChain(
      originalPrompt: originalPrompt,
      startingPlayerId: startingPlayerId,
      links: links,
      isComplete: true,
    );
  }
  
  /// Gets the most recent contribution to the chain.
  /// 
  /// This is useful when we need to know what the next player should see.
  /// If the last link is a drawing, the next player needs to guess.
  /// If it's a guess, the next player needs to draw.
  ChainLink? get lastLink => links.isEmpty ? null : links.last;
  
  /// Determines what type of contribution is needed next.
  /// 
  /// This method encapsulates the game's alternating logic. By checking
  /// the type of the last link, we know what should come next. It's like
  /// knowing whose turn it is in a game just by looking at the board.
  ChainLinkType? get nextLinkType {
    if (links.isEmpty) {
      return ChainLinkType.drawing; // First link is always a drawing
    }
    
    // If the last link was a drawing, we need a guess next, and vice versa
    return lastLink!.type == ChainLinkType.drawing 
        ? ChainLinkType.guess 
        : ChainLinkType.drawing;
  }
  
  /// Calculates how many players have contributed to this chain.
  /// 
  /// This helps us track progress and determine when a chain is complete.
  /// In a 4-player game, a complete chain would have 4 links.
  int get contributionCount => links.length;
  
  /// Gets the player ID who should contribute next.
  /// 
  /// This requires external knowledge of the player order, which is why
  /// it returns the ID of who contributed last. The game session will
  /// use this to determine who's next in the circle.
  String? get lastContributorId => lastLink?.playerId;
  
  /// Validates whether a player can contribute to this chain.
  /// 
  /// We need to ensure players don't contribute twice to the same chain
  /// (except for the starting player seeing the final result).
  bool canPlayerContribute(String playerId) {
    // The starting player can only contribute as the first link
    if (playerId == startingPlayerId && links.isNotEmpty) {
      return false;
    }
    
    // Check if this player has already contributed
    return !links.any((link) => link.playerId == playerId);
  }
  
  /// Converts the chain to JSON for storage or transmission.
  Map<String, dynamic> toJson() => {
    'originalPrompt': originalPrompt,
    'startingPlayerId': startingPlayerId,
    'links': links.map((link) => link.toJson()).toList(),
    'isComplete': isComplete,
  };
  
  /// Creates a DrawingChain from JSON data.
  factory DrawingChain.fromJson(Map<String, dynamic> json) {
    return DrawingChain(
      originalPrompt: json['originalPrompt'] as String,
      startingPlayerId: json['startingPlayerId'] as String,
      links: (json['links'] as List)
          .map((link) => ChainLink.fromJson(link as Map<String, dynamic>))
          .toList(),
      isComplete: json['isComplete'] as bool,
    );
  }
  
  @override
  List<Object?> get props => [originalPrompt, startingPlayerId, links, isComplete];
  
  /// Provides a human-readable summary of the chain's transformation.
  /// 
  /// This is particularly useful for debugging and for the end-game summary.
  /// Players love seeing how "a cat on a skateboard" became "alien pizza party"!
  String get transformationSummary {
    if (links.isEmpty) return 'No transformations yet';
    
    final lastGuess = links.whereType<GuessLink>().lastOrNull?.guess;
    if (lastGuess == null) return 'In progress...';
    
    return '"$originalPrompt" became "$lastGuess"';
  }
}
