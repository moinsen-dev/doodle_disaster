import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../domain/models/models.dart';

/// Manages the current player's identity and preferences.
/// 
/// This provider handles:
/// - Generating and persisting a unique player ID
/// - Storing and retrieving the player's display name
/// - Creating Player objects for game sessions
class PlayerNotifier extends StateNotifier<Player?> {
  static const String _playerIdKey = 'player_id';
  static const String _playerNameKey = 'player_name';
  final Uuid _uuid = const Uuid();
  
  PlayerNotifier() : super(null) {
    _loadPlayer();
  }
  
  /// Loads the player data from local storage
  Future<void> _loadPlayer() async {
    final prefs = await SharedPreferences.getInstance();
    final playerId = prefs.getString(_playerIdKey);
    final playerName = prefs.getString(_playerNameKey);
    
    if (playerId != null) {
      state = Player(
        id: playerId,
        name: playerName ?? 'Player',
        isHost: false, // Will be set when creating/joining games
      );
    }
  }
  
  /// Creates or updates the current player
  Future<void> setPlayerName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Get or create player ID
    String playerId = state?.id ?? prefs.getString(_playerIdKey) ?? _uuid.v4();
    
    // Save to preferences
    await prefs.setString(_playerIdKey, playerId);
    await prefs.setString(_playerNameKey, name);
    
    // Update state
    state = Player(
      id: playerId,
      name: name,
      isHost: state?.isHost ?? false,
    );
  }
  
  /// Updates whether the current player is the host
  void setIsHost(bool isHost) {
    if (state != null) {
      state = state!.copyWith(isHost: isHost);
    }
  }
  
  /// Updates the player's name
  Future<void> setName(String name) async {
    if (state == null) return;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_playerNameKey, name);
    
    state = state!.copyWith(name: name);
  }
  
  /// Gets or creates a player if one doesn't exist
  Future<Player> getOrCreatePlayer() async {
    if (state != null) return state!;
    
    final prefs = await SharedPreferences.getInstance();
    String playerId = prefs.getString(_playerIdKey) ?? _uuid.v4();
    String playerName = prefs.getString(_playerNameKey) ?? 'Player ${playerId.substring(0, 4)}';
    
    // Save new player data
    await prefs.setString(_playerIdKey, playerId);
    await prefs.setString(_playerNameKey, playerName);
    
    final player = Player(
      id: playerId,
      name: playerName,
      isHost: false,
    );
    
    state = player;
    return player;
  }
}

/// Provider for the current player
final playerProvider = StateNotifierProvider<PlayerNotifier, Player?>((ref) {
  return PlayerNotifier();
});

/// Provider that ensures a player exists (creates one if needed)
final currentPlayerProvider = FutureProvider<Player>((ref) async {
  final playerNotifier = ref.read(playerProvider.notifier);
  return playerNotifier.getOrCreatePlayer();
});