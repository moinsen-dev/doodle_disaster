import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../domain/models/models.dart';
import 'player_provider.dart';

/// Manages the overall game session state.
/// 
/// This provider handles:
/// - Creating and joining game sessions
/// - Managing game flow and transitions
/// - Tracking player turns and actions
/// - Submitting drawings and guesses
class GameSessionNotifier extends StateNotifier<GameSession?> {
  final Ref ref;
  final Uuid _uuid = const Uuid();
  
  GameSessionNotifier(this.ref) : super(null);
  
  /// Creates a new game session with the current player as host
  Future<String> createGame() async {
    final player = await ref.read(currentPlayerProvider.future);
    
    // Update player to be host
    ref.read(playerProvider.notifier).setIsHost(true);
    
    // Generate a simple room code (6 characters)
    final roomCode = _generateRoomCode();
    
    final session = GameSession(
      sessionId: _uuid.v4(),
      hostPlayerId: player.id,
      players: {player.id: player.copyWith(isHost: true)},
      state: SessionState.waitingForPlayers,
      rounds: [],
      settings: const GameSettings(),
      createdAt: DateTime.now(),
      playerOrder: [player.id],
    );
    
    state = session;
    return roomCode;
  }
  
  /// Joins an existing game session (in real app, would connect via Bluetooth)
  Future<void> joinGame(String roomCode) async {
    final player = await ref.read(currentPlayerProvider.future);
    
    // For now, create a mock session for testing
    // In real implementation, this would connect to host via Bluetooth
    final mockHost = Player(
      id: _uuid.v4(),
      name: 'Host Player',
      isHost: true,
    );
    
    final session = GameSession(
      sessionId: _uuid.v4(),
      hostPlayerId: mockHost.id,
      players: {
        mockHost.id: mockHost,
        player.id: player,
      },
      state: SessionState.waitingForPlayers,
      rounds: [],
      settings: const GameSettings(),
      createdAt: DateTime.now(),
      playerOrder: [mockHost.id, player.id],
    );
    
    state = session;
  }
  
  /// Starts the game (host only)
  void startGame() {
    if (state == null || state!.state != SessionState.waitingForPlayers) return;
    
    final currentPlayer = ref.read(playerProvider);
    if (currentPlayer?.id != state!.hostPlayerId) return;
    
    // Generate prompts for each player (in real app, these would come from a prompt bank)
    final prompts = List.generate(
      state!.players.length,
      (index) => 'Draw prompt ${index + 1}',
    );
    
    state = state!.startNewRound(prompts);
  }
  
  /// Submits a drawing for the current player
  void submitDrawing(DrawingData drawing) {
    if (state == null) return;
    
    final currentPlayerId = ref.read(playerProvider)?.id;
    if (currentPlayerId == null) return;
    
    final action = state!.getPlayerAction(currentPlayerId);
    if (action == null) return;
    
    // Check if the player should be drawing
    bool shouldDraw = false;
    action.when(
      drawPrompt: (_) => shouldDraw = true,
      drawGuess: (_) => shouldDraw = true,
      guessDrawing: (_) => shouldDraw = false,
      wait: () => shouldDraw = false,
    );
    
    if (!shouldDraw) return;
    
    // Submit the drawing
    state = state!.submitDrawing(
      playerId: currentPlayerId,
      drawing: drawing,
      linkId: _uuid.v4(),
    );
  }
  
  /// Submits a guess for the current player
  void submitGuess(String guess) {
    if (state == null) return;
    
    final currentPlayerId = ref.read(playerProvider)?.id;
    if (currentPlayerId == null) return;
    
    final action = state!.getPlayerAction(currentPlayerId);
    if (action == null) return;
    
    // Check if the player should be guessing
    bool shouldGuess = false;
    action.when(
      drawPrompt: (_) => shouldGuess = false,
      drawGuess: (_) => shouldGuess = false,
      guessDrawing: (_) => shouldGuess = true,
      wait: () => shouldGuess = false,
    );
    
    if (!shouldGuess) return;
    
    // Submit the guess
    state = state!.submitGuess(
      playerId: currentPlayerId,
      guess: guess,
      linkId: _uuid.v4(),
    );
  }
  
  /// Moves to the next round
  void nextRound() {
    if (state == null || state!.state != SessionState.roundRevealing) return;
    
    // Complete the reveal phase first
    state = state!.completeReveal();
    
    // If the game is ready for another round, start it
    if (state!.state == SessionState.ready) {
      // Generate new prompts
      final prompts = List.generate(
        state!.players.length,
        (index) => 'Draw prompt ${state!.rounds.length + 1}-${index + 1}',
      );
      state = state!.startNewRound(prompts);
    }
  }
  
  /// Gets the current player's action
  PlayerAction? get currentPlayerAction {
    final currentPlayerId = ref.read(playerProvider)?.id;
    if (currentPlayerId == null || state == null) return null;
    
    return state!.getPlayerAction(currentPlayerId);
  }
  
  /// Generates a simple room code
  String _generateRoomCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = DateTime.now().millisecondsSinceEpoch;
    String code = '';
    
    for (int i = 0; i < 6; i++) {
      code += chars[(random + i * 7) % chars.length];
    }
    
    return code;
  }
  
  /// Add a player to the session
  void addPlayer(Player player) {
    if (state == null) return;
    
    final updatedPlayers = Map<String, Player>.from(state!.players);
    updatedPlayers[player.id] = player;
    
    final updatedOrder = List<String>.from(state!.playerOrder);
    if (!updatedOrder.contains(player.id)) {
      updatedOrder.add(player.id);
    }
    
    state = state!.copyWith(
      players: updatedPlayers,
      playerOrder: updatedOrder,
    );
  }
  
  /// Remove a player from the session
  void removePlayer(String playerId) {
    if (state == null) return;
    
    final updatedPlayers = Map<String, Player>.from(state!.players);
    updatedPlayers.remove(playerId);
    
    final updatedOrder = List<String>.from(state!.playerOrder);
    updatedOrder.remove(playerId);
    
    state = state!.copyWith(
      players: updatedPlayers,
      playerOrder: updatedOrder,
    );
  }
  
  /// Sync entire game state (for guests receiving updates from host)
  void syncState(GameSession newSession) {
    state = newSession;
  }
  
  /// Set the current player action
  void setCurrentAction(PlayerAction action) {
    // Store the action for the current player
    // This would typically update the game state to reflect the new action
    // For now, we'll just trigger a state change
    if (state != null) {
      state = state!.copyWith();
    }
  }
  
  /// Leave the current game
  void leaveGame() {
    state = null;
  }
  
  /// Reset the game for a new round while keeping players
  void resetForNewGame() {
    if (state == null) return;
    
    // Keep the same players but reset the game state
    state = GameSession(
      sessionId: state!.sessionId,
      hostPlayerId: state!.hostPlayerId,
      players: state!.players.map((id, player) => 
        MapEntry(id, player.copyWith(score: 0))
      ),
      state: SessionState.waitingForPlayers,
      rounds: [],
      settings: state!.settings,
      createdAt: DateTime.now(),
      playerOrder: state!.playerOrder,
    );
  }
  
  /// Clear the session completely
  void clearSession() {
    state = null;
  }
}

/// Provider for the game session
final gameSessionProvider = StateNotifierProvider<GameSessionNotifier, GameSession?>((ref) {
  return GameSessionNotifier(ref);
});

/// Provider for the current room code (mock for now)
final roomCodeProvider = Provider<String?>((ref) {
  // In a real app, this would be stored separately
  // For now, generate from session ID
  final session = ref.watch(gameSessionProvider);
  if (session == null) return null;
  
  return session.sessionId.substring(0, 6).toUpperCase();
});