import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/services/bluetooth_service.dart';
import '../../domain/models/models.dart';
import 'game_session_provider.dart';
import 'player_provider.dart';

/// Provides the singleton BluetoothService instance
final bluetoothServiceProvider = Provider<BluetoothService>((ref) {
  return BluetoothService();
});

/// Tracks the current Bluetooth connection state
final connectionStateProvider = StreamProvider<ConnectionState>((ref) {
  final service = ref.watch(bluetoothServiceProvider);
  return service.connectionState;
});

/// Provides the list of discovered devices when scanning
final discoveredDevicesProvider = StreamProvider<List<DiscoveredDevice>>((ref) {
  final service = ref.watch(bluetoothServiceProvider);
  return service.discoveredDevices;
});

/// Listens to incoming Bluetooth messages and updates game state
final bluetoothMessageListenerProvider = Provider<void>((ref) {
  final service = ref.watch(bluetoothServiceProvider);
  final gameSessionNotifier = ref.read(gameSessionProvider.notifier);
  
  // Listen to messages
  service.messages.listen((message) {
    switch (message.type) {
      case MessageType.playerJoined:
        final msg = message as PlayerJoinedMessage;
        gameSessionNotifier.addPlayer(msg.player);
        break;
        
      case MessageType.playerLeft:
        final msg = message as PlayerLeftMessage;
        gameSessionNotifier.removePlayer(msg.playerId);
        break;
        
      case MessageType.gameStarted:
        gameSessionNotifier.startGame();
        break;
        
      case MessageType.stateSync:
        final msg = message as StateSyncMessage;
        // Update entire game state from host
        gameSessionNotifier.syncState(msg.gameSession);
        break;
        
      case MessageType.drawingSubmitted:
        final msg = message as DrawingSubmittedMessage;
        // Store the drawing for the player
        // In a real implementation, we'd update the game state directly
        // For now, we'll just trigger the current player's submission
        if (ref.read(playerProvider)?.id == msg.playerId) {
          gameSessionNotifier.submitDrawing(msg.drawing);
        }
        break;
        
      case MessageType.guessSubmitted:
        final msg = message as GuessSubmittedMessage;
        // Store the guess for the player
        // In a real implementation, we'd update the game state directly
        // For now, we'll just trigger the current player's submission
        if (ref.read(playerProvider)?.id == msg.playerId) {
          gameSessionNotifier.submitGuess(msg.guess);
        }
        break;
        
      case MessageType.roundStarted:
        final msg = message as RoundStartedMessage;
        gameSessionNotifier.setCurrentAction(msg.action);
        break;
        
      case MessageType.error:
        final msg = message as ErrorMessage;
        // Handle error - could show dialog or update UI
        // TODO: Show error dialog or update UI with error message
        break;
    }
  });
});

/// Manages Bluetooth operations for the game
class BluetoothNotifier extends StateNotifier<BluetoothState> {
  final Ref ref;
  
  BluetoothNotifier(this.ref) : super(const BluetoothState());
  
  /// Initialize Bluetooth
  Future<void> initialize() async {
    final service = ref.read(bluetoothServiceProvider);
    
    state = state.copyWith(isInitializing: true);
    try {
      await service.initialize();
      state = state.copyWith(
        isInitialized: true,
        isInitializing: false,
      );
    } catch (e) {
      state = state.copyWith(
        isInitializing: false,
        error: e.toString(),
      );
    }
  }
  
  /// Start hosting a game
  Future<void> startHosting(String roomCode) async {
    final service = ref.read(bluetoothServiceProvider);
    
    state = state.copyWith(isConnecting: true, error: null);
    try {
      await service.startHosting(roomCode);
      state = state.copyWith(
        isConnecting: false,
        isHost: true,
      );
      
      // Start listening for messages
      ref.read(bluetoothMessageListenerProvider);
    } catch (e) {
      state = state.copyWith(
        isConnecting: false,
        error: e.toString(),
      );
    }
  }
  
  /// Start scanning for games
  Future<void> startScanning() async {
    final service = ref.read(bluetoothServiceProvider);
    
    state = state.copyWith(isScanning: true, error: null);
    try {
      await service.startScanning();
    } catch (e) {
      state = state.copyWith(
        isScanning: false,
        error: e.toString(),
      );
    }
  }
  
  /// Stop scanning
  Future<void> stopScanning() async {
    final service = ref.read(bluetoothServiceProvider);
    await service.stopScanning();
    state = state.copyWith(isScanning: false);
  }
  
  /// Connect to a host
  Future<void> connectToHost(DiscoveredDevice device) async {
    final service = ref.read(bluetoothServiceProvider);
    final player = await ref.read(currentPlayerProvider.future);
    
    state = state.copyWith(isConnecting: true, error: null);
    try {
      await service.connectToHost(device.device);
      
      // Send join message
      await service.sendMessage(PlayerJoinedMessage(
        senderId: player.id,
        player: player,
      ));
      
      state = state.copyWith(
        isConnecting: false,
        connectedDevice: device,
      );
      
      // Start listening for messages
      ref.read(bluetoothMessageListenerProvider);
    } catch (e) {
      state = state.copyWith(
        isConnecting: false,
        error: e.toString(),
      );
    }
  }
  
  /// Disconnect from current connection
  Future<void> disconnect() async {
    final service = ref.read(bluetoothServiceProvider);
    final player = await ref.read(currentPlayerProvider.future);
    
    // Send leave message if connected
    if (state.connectedDevice != null) {
      try {
        await service.sendMessage(PlayerLeftMessage(
          senderId: player.id,
          playerId: player.id,
        ));
      } catch (_) {
        // Ignore errors when leaving
      }
    }
    
    await service.disconnect();
    state = state.copyWith(
      connectedDevice: null,
      isHost: false,
    );
  }
  
  /// Broadcast game state to all players (host only)
  Future<void> broadcastState() async {
    if (!state.isHost) return;
    
    final service = ref.read(bluetoothServiceProvider);
    final gameSession = ref.read(gameSessionProvider);
    final player = await ref.read(currentPlayerProvider.future);
    
    if (gameSession != null) {
      await service.sendMessage(StateSyncMessage(
        senderId: player.id,
        gameSession: gameSession,
      ));
    }
  }
  
  /// Send player action (host only)
  Future<void> sendPlayerAction(PlayerAction action) async {
    if (!state.isHost) return;
    
    final service = ref.read(bluetoothServiceProvider);
    final player = await ref.read(currentPlayerProvider.future);
    
    await service.sendMessage(RoundStartedMessage(
      senderId: player.id,
      action: action,
    ));
  }
}

/// Bluetooth state
class BluetoothState {
  final bool isInitialized;
  final bool isInitializing;
  final bool isScanning;
  final bool isConnecting;
  final bool isHost;
  final DiscoveredDevice? connectedDevice;
  final String? error;
  
  const BluetoothState({
    this.isInitialized = false,
    this.isInitializing = false,
    this.isScanning = false,
    this.isConnecting = false,
    this.isHost = false,
    this.connectedDevice,
    this.error,
  });
  
  BluetoothState copyWith({
    bool? isInitialized,
    bool? isInitializing,
    bool? isScanning,
    bool? isConnecting,
    bool? isHost,
    DiscoveredDevice? connectedDevice,
    String? error,
  }) {
    return BluetoothState(
      isInitialized: isInitialized ?? this.isInitialized,
      isInitializing: isInitializing ?? this.isInitializing,
      isScanning: isScanning ?? this.isScanning,
      isConnecting: isConnecting ?? this.isConnecting,
      isHost: isHost ?? this.isHost,
      connectedDevice: connectedDevice ?? this.connectedDevice,
      error: error ?? this.error,
    );
  }
}

/// Provider for Bluetooth operations
final bluetoothProvider = StateNotifierProvider<BluetoothNotifier, BluetoothState>((ref) {
  return BluetoothNotifier(ref);
});