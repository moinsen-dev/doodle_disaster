import 'dart:async';
import 'dart:convert';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../models/models.dart';

/// Service UUID for Doodle Disaster game
const String serviceUuid = '00001234-0000-1000-8000-00805F9B34FB';
const String characteristicUuid = '00001235-0000-1000-8000-00805F9B34FB';

/// Message types for Bluetooth communication
enum MessageType {
  playerJoined,
  playerLeft,
  gameStarted,
  roundStarted,
  drawingSubmitted,
  guessSubmitted,
  stateSync,
  error,
}

/// Base message class for Bluetooth communication
abstract class BluetoothMessage {
  final MessageType type;
  final String senderId;
  final DateTime timestamp;
  
  BluetoothMessage({
    required this.type,
    required this.senderId,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
  
  Map<String, dynamic> toJson();
  
  factory BluetoothMessage.fromJson(Map<String, dynamic> json) {
    final type = MessageType.values.firstWhere(
      (t) => t.name == json['type'],
    );
    
    switch (type) {
      case MessageType.playerJoined:
        return PlayerJoinedMessage.fromJson(json);
      case MessageType.playerLeft:
        return PlayerLeftMessage.fromJson(json);
      case MessageType.gameStarted:
        return GameStartedMessage.fromJson(json);
      case MessageType.roundStarted:
        return RoundStartedMessage.fromJson(json);
      case MessageType.drawingSubmitted:
        return DrawingSubmittedMessage.fromJson(json);
      case MessageType.guessSubmitted:
        return GuessSubmittedMessage.fromJson(json);
      case MessageType.stateSync:
        return StateSyncMessage.fromJson(json);
      case MessageType.error:
        return ErrorMessage.fromJson(json);
    }
  }
}

/// Player joined message
class PlayerJoinedMessage extends BluetoothMessage {
  final Player player;
  
  PlayerJoinedMessage({
    required String senderId,
    required this.player,
  }) : super(type: MessageType.playerJoined, senderId: senderId);
  
  @override
  Map<String, dynamic> toJson() => {
    'type': type.name,
    'senderId': senderId,
    'timestamp': timestamp.toIso8601String(),
    'player': player.toJson(),
  };
  
  factory PlayerJoinedMessage.fromJson(Map<String, dynamic> json) {
    return PlayerJoinedMessage(
      senderId: json['senderId'],
      player: Player.fromJson(json['player']),
    );
  }
}

/// Game state sync message
class StateSyncMessage extends BluetoothMessage {
  final GameSession gameSession;
  
  StateSyncMessage({
    required String senderId,
    required this.gameSession,
  }) : super(type: MessageType.stateSync, senderId: senderId);
  
  @override
  Map<String, dynamic> toJson() => {
    'type': type.name,
    'senderId': senderId,
    'timestamp': timestamp.toIso8601String(),
    'gameSession': gameSession.toJson(),
  };
  
  factory StateSyncMessage.fromJson(Map<String, dynamic> json) {
    return StateSyncMessage(
      senderId: json['senderId'],
      gameSession: GameSession.fromJson(json['gameSession']),
    );
  }
}

/// Other message types would follow similar pattern...
class PlayerLeftMessage extends BluetoothMessage {
  final String playerId;
  
  PlayerLeftMessage({
    required String senderId,
    required this.playerId,
  }) : super(type: MessageType.playerLeft, senderId: senderId);
  
  @override
  Map<String, dynamic> toJson() => {
    'type': type.name,
    'senderId': senderId,
    'timestamp': timestamp.toIso8601String(),
    'playerId': playerId,
  };
  
  factory PlayerLeftMessage.fromJson(Map<String, dynamic> json) {
    return PlayerLeftMessage(
      senderId: json['senderId'],
      playerId: json['playerId'],
    );
  }
}

class GameStartedMessage extends BluetoothMessage {
  GameStartedMessage({required String senderId}) 
    : super(type: MessageType.gameStarted, senderId: senderId);
  
  @override
  Map<String, dynamic> toJson() => {
    'type': type.name,
    'senderId': senderId,
    'timestamp': timestamp.toIso8601String(),
  };
  
  factory GameStartedMessage.fromJson(Map<String, dynamic> json) {
    return GameStartedMessage(senderId: json['senderId']);
  }
}

class RoundStartedMessage extends BluetoothMessage {
  final PlayerAction action;
  
  RoundStartedMessage({
    required String senderId,
    required this.action,
  }) : super(type: MessageType.roundStarted, senderId: senderId);
  
  @override
  Map<String, dynamic> toJson() => {
    'type': type.name,
    'senderId': senderId,
    'timestamp': timestamp.toIso8601String(),
    'action': action.toJson(),
  };
  
  factory RoundStartedMessage.fromJson(Map<String, dynamic> json) {
    return RoundStartedMessage(
      senderId: json['senderId'],
      action: PlayerAction.fromJson(json['action']),
    );
  }
}

class DrawingSubmittedMessage extends BluetoothMessage {
  final String playerId;
  final DrawingData drawing;
  final String linkId;
  
  DrawingSubmittedMessage({
    required String senderId,
    required this.playerId,
    required this.drawing,
    required this.linkId,
  }) : super(type: MessageType.drawingSubmitted, senderId: senderId);
  
  @override
  Map<String, dynamic> toJson() => {
    'type': type.name,
    'senderId': senderId,
    'timestamp': timestamp.toIso8601String(),
    'playerId': playerId,
    'drawing': drawing.toJson(),
    'linkId': linkId,
  };
  
  factory DrawingSubmittedMessage.fromJson(Map<String, dynamic> json) {
    return DrawingSubmittedMessage(
      senderId: json['senderId'],
      playerId: json['playerId'],
      drawing: DrawingData.fromJson(json['drawing']),
      linkId: json['linkId'],
    );
  }
}

class GuessSubmittedMessage extends BluetoothMessage {
  final String playerId;
  final String guess;
  final String linkId;
  
  GuessSubmittedMessage({
    required String senderId,
    required this.playerId,
    required this.guess,
    required this.linkId,
  }) : super(type: MessageType.guessSubmitted, senderId: senderId);
  
  @override
  Map<String, dynamic> toJson() => {
    'type': type.name,
    'senderId': senderId,
    'timestamp': timestamp.toIso8601String(),
    'playerId': playerId,
    'guess': guess,
    'linkId': linkId,
  };
  
  factory GuessSubmittedMessage.fromJson(Map<String, dynamic> json) {
    return GuessSubmittedMessage(
      senderId: json['senderId'],
      playerId: json['playerId'],
      guess: json['guess'],
      linkId: json['linkId'],
    );
  }
}

class ErrorMessage extends BluetoothMessage {
  final String error;
  final String? details;
  
  ErrorMessage({
    required String senderId,
    required this.error,
    this.details,
  }) : super(type: MessageType.error, senderId: senderId);
  
  @override
  Map<String, dynamic> toJson() => {
    'type': type.name,
    'senderId': senderId,
    'timestamp': timestamp.toIso8601String(),
    'error': error,
    if (details != null) 'details': details,
  };
  
  factory ErrorMessage.fromJson(Map<String, dynamic> json) {
    return ErrorMessage(
      senderId: json['senderId'],
      error: json['error'],
      details: json['details'],
    );
  }
}

/// Manages Bluetooth connectivity for the game
class BluetoothService {
  static final BluetoothService _instance = BluetoothService._internal();
  factory BluetoothService() => _instance;
  BluetoothService._internal();
  
  final _messageController = StreamController<BluetoothMessage>.broadcast();
  final _connectionStateController = StreamController<ConnectionState>.broadcast();
  final _discoveredDevicesController = StreamController<List<DiscoveredDevice>>.broadcast();
  
  Stream<BluetoothMessage> get messages => _messageController.stream;
  Stream<ConnectionState> get connectionState => _connectionStateController.stream;
  Stream<List<DiscoveredDevice>> get discoveredDevices => _discoveredDevicesController.stream;
  
  final List<DiscoveredDevice> _devices = [];
  BluetoothDevice? _connectedDevice;
  BluetoothCharacteristic? _characteristic;
  StreamSubscription? _scanSubscription;
  StreamSubscription? _messageSubscription;
  
  // bool _isHost = false; // TODO: Use for host functionality
  bool _isScanning = false;
  
  /// Initialize Bluetooth service
  Future<void> initialize() async {
    // Check if Bluetooth is available
    final isAvailable = await FlutterBluePlus.isSupported;
    if (!isAvailable) {
      throw Exception('Bluetooth is not available on this device');
    }
    
    // Check if Bluetooth is on
    final isOn = await FlutterBluePlus.adapterState.first;
    if (isOn != BluetoothAdapterState.on) {
      throw Exception('Please enable Bluetooth');
    }
  }
  
  /// Start hosting a game
  Future<void> startHosting(String roomCode) async {
    // _isHost = true;
    _connectionStateController.add(ConnectionState.hosting);
    
    // In a real implementation, we would:
    // 1. Make device discoverable
    // 2. Start advertising with room code
    // 3. Accept incoming connections
    // For now, we'll simulate this
    
    // TODO: Implement actual Bluetooth advertising
    // TODO: Implement actual Bluetooth advertising with room code
  }
  
  /// Start scanning for games
  Future<void> startScanning() async {
    if (_isScanning) return;
    
    _isScanning = true;
    _devices.clear();
    _connectionStateController.add(ConnectionState.scanning);
    
    _scanSubscription?.cancel();
    _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
      _devices.clear();
      for (var result in results) {
        // Filter for our game service
        if (result.advertisementData.serviceUuids.contains(Guid(serviceUuid))) {
          _devices.add(DiscoveredDevice(
            device: result.device,
            name: result.device.platformName,
            roomCode: _extractRoomCode(result.advertisementData),
          ));
        }
      }
      _discoveredDevicesController.add(List.from(_devices));
    });
    
    await FlutterBluePlus.startScan(
      timeout: const Duration(seconds: 30),
      withServices: [Guid(serviceUuid)],
    );
  }
  
  /// Stop scanning
  Future<void> stopScanning() async {
    _isScanning = false;
    await FlutterBluePlus.stopScan();
    _scanSubscription?.cancel();
  }
  
  /// Connect to a host
  Future<void> connectToHost(BluetoothDevice device) async {
    try {
      _connectionStateController.add(ConnectionState.connecting);
      
      await device.connect();
      _connectedDevice = device;
      
      // Discover services
      final services = await device.discoverServices();
      for (var service in services) {
        if (service.uuid.toString() == serviceUuid) {
          for (var characteristic in service.characteristics) {
            if (characteristic.uuid.toString() == characteristicUuid) {
              _characteristic = characteristic;
              await _setupMessageListener();
              _connectionStateController.add(ConnectionState.connected);
              return;
            }
          }
        }
      }
      
      throw Exception('Game service not found on device');
    } catch (e) {
      _connectionStateController.add(ConnectionState.disconnected);
      rethrow;
    }
  }
  
  /// Disconnect from current connection
  Future<void> disconnect() async {
    await _connectedDevice?.disconnect();
    _connectedDevice = null;
    _characteristic = null;
    _messageSubscription?.cancel();
    _connectionStateController.add(ConnectionState.disconnected);
  }
  
  /// Send a message
  Future<void> sendMessage(BluetoothMessage message) async {
    if (_characteristic == null) {
      throw Exception('Not connected');
    }
    
    final json = jsonEncode(message.toJson());
    final bytes = utf8.encode(json);
    
    // Split into chunks if needed (BLE has size limits)
    const chunkSize = 512;
    for (var i = 0; i < bytes.length; i += chunkSize) {
      final end = (i + chunkSize < bytes.length) ? i + chunkSize : bytes.length;
      final chunk = bytes.sublist(i, end);
      await _characteristic!.write(chunk);
    }
  }
  
  /// Setup message listener
  Future<void> _setupMessageListener() async {
    if (_characteristic == null) return;
    
    await _characteristic!.setNotifyValue(true);
    
    final buffer = <int>[];
    _messageSubscription = _characteristic!.lastValueStream.listen((value) {
      buffer.addAll(value);
      
      // Try to decode message
      try {
        final json = utf8.decode(buffer);
        final data = jsonDecode(json) as Map<String, dynamic>;
        final message = BluetoothMessage.fromJson(data);
        _messageController.add(message);
        buffer.clear();
      } catch (e) {
        // Not a complete message yet, wait for more data
      }
    });
  }
  
  /// Extract room code from advertisement data
  String _extractRoomCode(AdvertisementData data) {
    // In a real implementation, room code would be in manufacturer data
    // For now, return a placeholder
    return 'ABC123';
  }
  
  void dispose() {
    _scanSubscription?.cancel();
    _messageSubscription?.cancel();
    _messageController.close();
    _connectionStateController.close();
    _discoveredDevicesController.close();
  }
}

/// Connection states
enum ConnectionState {
  disconnected,
  scanning,
  connecting,
  connected,
  hosting,
}

/// Discovered device info
class DiscoveredDevice {
  final BluetoothDevice device;
  final String name;
  final String roomCode;
  
  DiscoveredDevice({
    required this.device,
    required this.name,
    required this.roomCode,
  });
}