import 'package:equatable/equatable.dart';
import 'player.dart';
import 'drawing_chain.dart';
import 'game_settings.dart';
import 'player_action.dart';
import 'chain_link.dart';
import 'drawing_data.dart';

/// Represents the different states a game session can be in.
/// 
/// Think of these states like the phases of a dinner party:
/// - waitingForPlayers: Guests are arriving, not everyone is here yet
/// - ready: Everyone has arrived, but dinner hasn't started
/// - inProgress: We're eating and enjoying the meal
/// - roundRevealing: Between courses, sharing stories about the food
/// - completed: The party is over, time to say goodbye
enum SessionState {
  waitingForPlayers,
  ready,
  inProgress,
  roundRevealing,
  completed,
}

/// Represents a single round in the game.
/// 
/// A round is complete when every player has contributed to every chain.
/// In a 4-player game, each round contains 4 chains, and each chain has
/// 4 links (alternating drawings and guesses).
class GameRound extends Equatable {
  final int roundNumber;
  final List<DrawingChain> chains;
  final DateTime startedAt;
  final DateTime? completedAt;
  
  const GameRound({
    required this.roundNumber,
    required this.chains,
    required this.startedAt,
    this.completedAt,
  });
  
  /// Checks if all chains in this round are complete.
  bool get isComplete => chains.every((chain) => chain.isComplete);
  
  /// Finds the chain that a specific player should contribute to next.
  /// 
  /// This is like figuring out which conversation you should join at a party -
  /// you look for the one where you haven't spoken yet.
  DrawingChain? getChainForPlayer(String playerId) {
    try {
      return chains.firstWhere(
        (chain) => chain.canPlayerContribute(playerId) && !chain.isComplete,
      );
    } catch (_) {
      return null; // No available chain for this player
    }
  }
  
  @override
  List<Object?> get props => [roundNumber, chains, startedAt, completedAt];
  
  /// Creates a game round from JSON data
  factory GameRound.fromJson(Map<String, dynamic> json) {
    return GameRound(
      roundNumber: json['roundNumber'] as int,
      chains: (json['chains'] as List<dynamic>)
          .map((chainJson) => DrawingChain.fromJson(chainJson as Map<String, dynamic>))
          .toList(),
      startedAt: DateTime.parse(json['startedAt'] as String),
      completedAt: json['completedAt'] != null 
          ? DateTime.parse(json['completedAt'] as String)
          : null,
    );
  }
}
/// The main game session that coordinates all game activities.
/// 
/// This is the heart of our game - the central command center that knows
/// about all players, manages rounds, and coordinates the flow of drawings
/// and guesses between devices. If our game were a theater production,
/// GameSession would be the director.
class GameSession extends Equatable {
  /// Unique identifier for this game session.
  /// Players use this to join the same game, like a room code at a hotel.
  final String sessionId;
  
  /// The player who created and hosts this session.
  /// The host has special privileges like starting rounds and ending the game.
  final String hostPlayerId;
  
  /// All players currently in this session.
  /// We use a Map here for quick lookups by player ID - it's like having
  /// a guest list where you can instantly find anyone by name.
  final Map<String, Player> players;
  
  /// The current state of the game session.
  final SessionState state;
  
  /// All rounds played in this session.
  /// We keep history so players can review previous rounds and see how
  /// their drawings transformed over multiple games.
  final List<GameRound> rounds;
  
  /// The settings for this game session.
  /// This includes things like time limits, number of rounds, etc.
  final GameSettings settings;
  
  /// When this session was created.
  final DateTime createdAt;
  
  /// The order in which players sit around the virtual table.
  /// This determines the flow of drawings and guesses - like passing
  /// a note around a circle.
  final List<String> playerOrder;
  
  const GameSession({
    required this.sessionId,
    required this.hostPlayerId,
    required this.players,
    required this.state,
    required this.rounds,
    required this.settings,
    required this.createdAt,
    required this.playerOrder,
  });
  
  /// Creates a copy of this GameSession with the given fields replaced with new values.
  /// 
  /// This is useful when you need to update specific fields while keeping others unchanged.
  /// It's like making a photocopy of a document and then editing just the parts you need.
  GameSession copyWith({
    String? sessionId,
    String? hostPlayerId,
    Map<String, Player>? players,
    SessionState? state,
    List<GameRound>? rounds,
    GameSettings? settings,
    DateTime? createdAt,
    List<String>? playerOrder,
  }) {
    return GameSession(
      sessionId: sessionId ?? this.sessionId,
      hostPlayerId: hostPlayerId ?? this.hostPlayerId,
      players: players ?? this.players,
      state: state ?? this.state,
      rounds: rounds ?? this.rounds,
      settings: settings ?? this.settings,
      createdAt: createdAt ?? this.createdAt,
      playerOrder: playerOrder ?? this.playerOrder,
    );
  }
  
  /// Creates a new game session with a host player.
  /// 
  /// When someone decides to start a new game, this factory method sets
  /// everything up. It's like preparing a game table before guests arrive -
  /// everything is clean, organized, and ready to go.
  factory GameSession.create({
    required String sessionId,
    required Player hostPlayer,
    required GameSettings settings,
  }) {
    return GameSession(
      sessionId: sessionId,
      hostPlayerId: hostPlayer.id,
      players: {hostPlayer.id: hostPlayer},
      state: SessionState.waitingForPlayers,
      rounds: const [],
      settings: settings,
      createdAt: DateTime.now(),
      playerOrder: [hostPlayer.id],
    );
  }  
  /// Adds a new player to the session.
  /// 
  /// This is like welcoming a new guest to your party. We need to make sure
  /// there's room (not too many players), the party hasn't started yet (game
  /// not in progress), and we add them to the seating arrangement.
  GameSession addPlayer(Player newPlayer) {
    // First, let's check if we can add more players
    if (players.length >= settings.maxPlayers) {
      throw StateError('Game session is full. Maximum ${settings.maxPlayers} players allowed.');
    }
    
    // Can't add players once the game has started - that would be like
    // trying to deal someone into a poker game mid-hand!
    if (state != SessionState.waitingForPlayers) {
      throw StateError('Cannot add players after game has started.');
    }
    
    // Create new player map with the additional player
    final updatedPlayers = Map<String, Player>.from(players)
      ..[newPlayer.id] = newPlayer;
    
    // Add to player order - they'll sit at the end of the table
    final updatedOrder = [...playerOrder, newPlayer.id];
    
    // Check if we now have enough players to start
    final newState = updatedPlayers.length >= settings.minPlayers
        ? SessionState.ready
        : SessionState.waitingForPlayers;
    
    return GameSession(
      sessionId: sessionId,
      hostPlayerId: hostPlayerId,
      players: updatedPlayers,
      state: newState,
      rounds: rounds,
      settings: settings,
      createdAt: createdAt,
      playerOrder: updatedOrder,
    );
  }
  
  /// Removes a player from the session.
  /// 
  /// Sometimes people need to leave early. We handle this gracefully,
  /// but if too many leave, we might need to end the game.
  GameSession removePlayer(String playerId) {
    // The host leaving is like the party host going to bed - party's over!
    if (playerId == hostPlayerId) {
      return GameSession(
        sessionId: sessionId,
        hostPlayerId: hostPlayerId,
        players: players,
        state: SessionState.completed,
        rounds: rounds,
        settings: settings,
        createdAt: createdAt,
        playerOrder: playerOrder,
      );
    }
    
    final updatedPlayers = Map<String, Player>.from(players)
      ..remove(playerId);
    
    final updatedOrder = playerOrder.where((id) => id != playerId).toList();
    
    // Check if we still have enough players
    final newState = updatedPlayers.length < settings.minPlayers
        ? SessionState.waitingForPlayers
        : state;
    
    return GameSession(
      sessionId: sessionId,
      hostPlayerId: hostPlayerId,
      players: updatedPlayers,
      state: newState,
      rounds: rounds,
      settings: settings,
      createdAt: createdAt,
      playerOrder: updatedOrder,
    );
  }  
  /// Starts a new round in the game.
  /// 
  /// This is a pivotal moment in our game - like dealing a new hand of cards.
  /// We create chains for each player, each starting with a unique prompt.
  /// The prompts come from our settings, ensuring variety and fun.
  GameSession startNewRound(List<String> prompts) {
    // Validate we're in a state where we can start a round
    if (state != SessionState.ready && rounds.isEmpty) {
      throw StateError('Can only start first round when session is ready.');
    }
    
    if (state == SessionState.inProgress) {
      throw StateError('Cannot start new round while another is in progress.');
    }
    
    // We need exactly one prompt per player
    if (prompts.length != players.length) {
      throw ArgumentError(
        'Number of prompts (${prompts.length}) must match number of players (${players.length}).',
      );
    }
    
    // Create a chain for each player with their prompt
    // This is like giving each player their own storyline to start
    final chains = <DrawingChain>[];
    for (int i = 0; i < playerOrder.length; i++) {
      chains.add(DrawingChain(
        originalPrompt: prompts[i],
        startingPlayerId: playerOrder[i],
      ));
    }
    
    final newRound = GameRound(
      roundNumber: rounds.length + 1,
      chains: chains,
      startedAt: DateTime.now(),
    );
    
    return GameSession(
      sessionId: sessionId,
      hostPlayerId: hostPlayerId,
      players: players,
      state: SessionState.inProgress,
      rounds: [...rounds, newRound],
      settings: settings,
      createdAt: createdAt,
      playerOrder: playerOrder,
    );
  }
  
  /// Gets the current round being played.
  /// 
  /// Like checking which chapter you're on in a book.
  GameRound? get currentRound => rounds.isEmpty ? null : rounds.last;
  
  /// Determines what a specific player should do next.
  /// 
  /// This is the traffic controller of our game. When a player asks
  /// "What should I do now?", this method figures out if they should
  /// draw, guess, or wait for others.
  PlayerAction? getPlayerAction(String playerId) {
    if (state != SessionState.inProgress || currentRound == null) {
      return null; // No action needed if game isn't running
    }
    
    // Find which chain this player should contribute to
    final chain = currentRound!.getChainForPlayer(playerId);
    if (chain == null) {
      return PlayerAction.wait; // Player has completed their contributions
    }
    
    // Determine if they should draw or guess based on chain state
    final nextType = chain.nextLinkType;
    
    // If they need to draw, figure out what they're drawing
    if (nextType == ChainLinkType.drawing) {
      // If chain is empty, they draw the original prompt
      if (chain.links.isEmpty) {
        return PlayerAction.drawPrompt(chain.originalPrompt);
      }
      
      // Otherwise, they draw based on the last guess
      final lastGuess = (chain.lastLink as GuessLink).guess;
      return PlayerAction.drawGuess(lastGuess);
    } else {
      // They need to guess the last drawing
      final lastDrawing = (chain.lastLink as DrawingLink).drawing;
      return PlayerAction.guessDrawing(lastDrawing);
    }
  }  
  /// Processes a drawing submission from a player.
  /// 
  /// When a player finishes drawing and hits "submit", this method handles
  /// adding their drawing to the appropriate chain. It's like placing a new
  /// piece on a game board - we need to make sure it goes in the right spot
  /// and follows the rules.
  GameSession submitDrawing({
    required String playerId,
    required DrawingData drawing,
    required String linkId,
  }) {
    if (state != SessionState.inProgress || currentRound == null) {
      throw StateError('Cannot submit drawing when game is not in progress.');
    }
    
    // Find which chain this player should contribute to
    final chainIndex = currentRound!.chains.indexWhere(
      (chain) => chain.canPlayerContribute(playerId) && !chain.isComplete,
    );
    
    if (chainIndex == -1) {
      throw StateError('Player $playerId has no valid chain to contribute to.');
    }
    
    final chain = currentRound!.chains[chainIndex];
    
    // Verify they should be drawing (not guessing)
    if (chain.nextLinkType != ChainLinkType.drawing) {
      throw StateError('Player should be guessing, not drawing.');
    }
    
    // Create the drawing link
    final drawingLink = DrawingLink(
      id: linkId,
      playerId: playerId,
      createdAt: DateTime.now(),
      drawing: drawing,
    );
    
    // Update the chain with the new drawing
    final updatedChain = chain.addLink(drawingLink);
    
    // Update the round with the modified chain
    final updatedChains = List<DrawingChain>.from(currentRound!.chains);
    updatedChains[chainIndex] = updatedChain;
    
    final updatedRound = GameRound(
      roundNumber: currentRound!.roundNumber,
      chains: updatedChains,
      startedAt: currentRound!.startedAt,
      completedAt: currentRound!.completedAt,
    );
    
    // Check if we need to check for round completion after chain updates
    final updatedRounds = List<GameRound>.from(rounds);
    updatedRounds[updatedRounds.length - 1] = updatedRound;
    
    // Check if the round is now complete
    final newState = updatedRound.isComplete 
        ? SessionState.roundRevealing 
        : SessionState.inProgress;
    
    return GameSession(
      sessionId: sessionId,
      hostPlayerId: hostPlayerId,
      players: players,
      state: newState,
      rounds: updatedRounds,
      settings: settings,
      createdAt: createdAt,
      playerOrder: playerOrder,
    );
  }  
  /// Processes a guess submission from a player.
  /// 
  /// This is the textual counterpart to submitDrawing. When a player looks
  /// at a drawing and types what they think it is, this method adds their
  /// guess to the chain. The guess then becomes the prompt for the next
  /// player's drawing, continuing the cycle of interpretation.
  GameSession submitGuess({
    required String playerId,
    required String guess,
    required String linkId,
  }) {
    if (state != SessionState.inProgress || currentRound == null) {
      throw StateError('Cannot submit guess when game is not in progress.');
    }
    
    // Find the appropriate chain for this player
    final chainIndex = currentRound!.chains.indexWhere(
      (chain) => chain.canPlayerContribute(playerId) && !chain.isComplete,
    );
    
    if (chainIndex == -1) {
      throw StateError('Player $playerId has no valid chain to contribute to.');
    }
    
    final chain = currentRound!.chains[chainIndex];
    
    // Verify they should be guessing (not drawing)
    if (chain.nextLinkType != ChainLinkType.guess) {
      throw StateError('Player should be drawing, not guessing.');
    }
    
    // Create the guess link
    final guessLink = GuessLink(
      id: linkId,
      playerId: playerId,
      createdAt: DateTime.now(),
      guess: guess.trim(), // Remove any extra whitespace
    );
    
    // Update the chain
    final updatedChain = chain.addLink(guessLink);
    
    // Check if this completes the chain
    // A chain is complete when it returns to the starting player
    final nextPlayerIndex = _getNextPlayerIndex(playerId);
    final nextPlayerId = playerOrder[nextPlayerIndex];
    final isChainComplete = nextPlayerId == chain.startingPlayerId;
    
    final finalChain = isChainComplete 
        ? updatedChain.markComplete() 
        : updatedChain;
    
    // Update the round
    final updatedChains = List<DrawingChain>.from(currentRound!.chains);
    updatedChains[chainIndex] = finalChain;
    
    // Check if all chains in the round are complete
    final isRoundComplete = updatedChains.every((chain) => chain.isComplete);
    
    final updatedRound = GameRound(
      roundNumber: currentRound!.roundNumber,
      chains: updatedChains,
      startedAt: currentRound!.startedAt,
      completedAt: isRoundComplete ? DateTime.now() : null,
    );
    
    // Update session state
    final updatedRounds = List<GameRound>.from(rounds);
    updatedRounds[updatedRounds.length - 1] = updatedRound;
    
    final newState = isRoundComplete 
        ? SessionState.roundRevealing 
        : SessionState.inProgress;
    
    return GameSession(
      sessionId: sessionId,
      hostPlayerId: hostPlayerId,
      players: players,
      state: newState,
      rounds: updatedRounds,
      settings: settings,
      createdAt: createdAt,
      playerOrder: playerOrder,
    );
  }
  
  /// Helper method to find the next player in the circle.
  /// 
  /// This implements circular rotation - after the last player comes the first.
  /// It's like sitting around a round table where there's no "end".
  int _getNextPlayerIndex(String currentPlayerId) {
    final currentIndex = playerOrder.indexOf(currentPlayerId);
    return (currentIndex + 1) % playerOrder.length;
  }  
  /// Completes the reveal phase and prepares for the next round or game end.
  /// 
  /// After players have seen how their prompts transformed, we need to
  /// transition to the next phase. This is like turning the page to a new
  /// chapter - we acknowledge what happened and prepare for what's next.
  GameSession completeReveal() {
    if (state != SessionState.roundRevealing) {
      throw StateError('Can only complete reveal during reveal phase.');
    }
    
    // Check if we've played all requested rounds
    final hasMoreRounds = rounds.length < settings.totalRounds;
    
    final newState = hasMoreRounds 
        ? SessionState.ready  // Ready for next round
        : SessionState.completed;  // Game over!
    
    return GameSession(
      sessionId: sessionId,
      hostPlayerId: hostPlayerId,
      players: players,
      state: newState,
      rounds: rounds,
      settings: settings,
      createdAt: createdAt,
      playerOrder: playerOrder,
    );
  }
  
  /// Gets the total score for a player across all rounds.
  /// 
  /// Scoring in our game comes from votes during the reveal phase.
  /// This method tallies up all the points a player has earned.
  int getPlayerScore(String playerId) {
    return players[playerId]?.score ?? 0;
  }
  
  /// Checks if the session can be started (enough players, right state).
  bool get canStart => 
      state == SessionState.ready && 
      players.length >= settings.minPlayers &&
      players.length <= settings.maxPlayers;
  
  /// Gets a human-readable summary of the current game state.
  /// 
  /// This is incredibly useful for debugging and for showing players
  /// what's happening in the game. It's like a status report that
  /// anyone can understand.
  String get statusSummary {
    switch (state) {
      case SessionState.waitingForPlayers:
        final needed = settings.minPlayers - players.length;
        return 'Waiting for $needed more player${needed == 1 ? "" : "s"} to join';
      case SessionState.ready:
        return 'Ready to start! ${players.length} players connected';
      case SessionState.inProgress:
        final round = currentRound;
        if (round != null) {
          final completedChains = round.chains.where((c) => c.isComplete).length;
          return 'Round ${round.roundNumber}: $completedChains/${round.chains.length} chains complete';
        }
        return 'Game in progress';
      case SessionState.roundRevealing:
        return 'Revealing round ${currentRound?.roundNumber} results';
      case SessionState.completed:
        return 'Game completed after ${rounds.length} rounds';
    }
  }
  
  /// Converts the session to JSON for storage or transmission.
  /// 
  /// This is essential for saving game state or recovering from disconnections.
  /// We carefully structure this data to be both complete and efficient.
  Map<String, dynamic> toJson() => {
    'sessionId': sessionId,
    'hostPlayerId': hostPlayerId,
    'players': players.map((id, player) => 
        MapEntry(id, player.toJson())),
    'state': state.name,
    'rounds': rounds.map((round) => round.toJson()).toList(),
    'settings': settings.toJson(),
    'createdAt': createdAt.toIso8601String(),
    'playerOrder': playerOrder,
  };
  
  /// Creates a game session from JSON data
  factory GameSession.fromJson(Map<String, dynamic> json) {
    return GameSession(
      sessionId: json['sessionId'] as String,
      hostPlayerId: json['hostPlayerId'] as String,
      players: (json['players'] as Map<String, dynamic>).map(
        (id, playerJson) => MapEntry(
          id,
          Player.fromJson(playerJson as Map<String, dynamic>),
        ),
      ),
      state: SessionState.values.firstWhere(
        (s) => s.name == json['state'],
      ),
      rounds: (json['rounds'] as List<dynamic>)
          .map((roundJson) => GameRound.fromJson(roundJson as Map<String, dynamic>))
          .toList(),
      settings: GameSettings.fromJson(json['settings'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['createdAt'] as String),
      playerOrder: List<String>.from(json['playerOrder'] as List<dynamic>),
    );
  }
  
  @override
  List<Object?> get props => [
    sessionId,
    hostPlayerId,
    players,
    state,
    rounds,
    settings,
    createdAt,
    playerOrder,
  ];
}

/// Extension methods to add JSON serialization to GameRound.
/// 
/// Extensions are a powerful Dart feature that let us add methods to
/// existing classes without modifying their source code. It's like
/// adding new tools to your toolbox without rebuilding the whole box.
extension GameRoundSerialization on GameRound {
  Map<String, dynamic> toJson() => {
    'roundNumber': roundNumber,
    'chains': chains.map((chain) => chain.toJson()).toList(),
    'startedAt': startedAt.toIso8601String(),
    'completedAt': completedAt?.toIso8601String(),
  };
}

/// Extension to add JSON serialization to Player.
extension PlayerSerialization on Player {
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'deviceId': deviceId,
    'isConnected': isConnected,
    'score': score,
    'isHost': isHost,
  };
}
