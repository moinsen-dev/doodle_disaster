import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

/// Represents a player in the Doodle Disaster game.
/// 
/// Think of this class as a digital representation of each person sitting
/// around the table. Just like how each person has a name tag at a party,
/// each Player has unique identifying information that helps us keep track
/// of who's who throughout the game.
/// 
/// We extend Equatable to make comparing players easier. This is like having
/// a reliable way to check if two name tags refer to the same person.
class Player extends Equatable {
  /// Unique identifier for this player. This never changes once created,
  /// like a person's fingerprint.
  final String id;
  
  /// The display name chosen by the player. This is what other players
  /// will see on their screens.
  final String name;
  
  /// The Bluetooth device ID associated with this player. This is how
  /// we maintain the connection to their physical device.
  final String? deviceId;
  
  /// Indicates whether this player is currently connected to the game.
  /// Think of this as checking if someone is still at the table or if
  /// they've temporarily stepped away.
  final bool isConnected;
  
  /// The player's current score. We track this across multiple rounds
  /// to determine the overall winner.
  final int score;
  
  /// Indicates if this player is the host (the one who created the game).
  /// The host has special privileges like starting rounds and managing
  /// game settings.
  final bool isHost;  
  /// Creates a new Player instance.
  /// 
  /// Notice how we use 'const' here? This is an optimization technique in Dart.
  /// When we create immutable objects (objects that don't change after creation),
  /// using 'const' helps Dart reuse the same object in memory when possible.
  const Player({
    required this.id,
    required this.name,
    this.deviceId,
    this.isConnected = true,
    this.score = 0,
    this.isHost = false,
  });
  
  /// Factory constructor to create a new player with a generated ID.
  /// 
  /// Factory constructors are special - they can return an instance of the class
  /// or even a subclass. Here, we use it as a convenient way to create a player
  /// without requiring the caller to generate their own ID.
  /// 
  /// Think of this like a helpful receptionist who assigns you a visitor badge
  /// number automatically when you sign in.
  factory Player.create({
    required String name,
    String? deviceId,
    bool isHost = false,
  }) {
    return Player(
      id: const Uuid().v4(), // Generates a unique ID like "f47ac10b-58cc-4372-a567-0e02b2c3d479"
      name: name,
      deviceId: deviceId,
      isHost: isHost,
    );
  }
  
  /// Creates a copy of this player with optionally modified fields.
  /// 
  /// This is called the "copyWith" pattern, and it's essential for immutable
  /// objects. Since we can't change a Player after it's created, we instead
  /// create a new Player with the changes we want.
  /// 
  /// Imagine you have a form filled out in pen. To make changes, you can't
  /// erase - instead, you copy everything to a new form, changing only the
  /// fields you need to update.
  Player copyWith({
    String? id,
    String? name,
    String? deviceId,
    bool? isConnected,
    int? score,
    bool? isHost,
  }) {
    return Player(
      id: id ?? this.id,
      name: name ?? this.name,
      deviceId: deviceId ?? this.deviceId,
      isConnected: isConnected ?? this.isConnected,
      score: score ?? this.score,
      isHost: isHost ?? this.isHost,
    );
  }
  
  /// Defines which properties determine if two Players are equal.
  /// 
  /// By only including 'id' here, we're saying that two Player objects
  /// represent the same player if they have the same ID, regardless of
  /// other properties. This makes sense because a player might disconnect
  /// and reconnect, changing their isConnected status, but they're still
  /// the same player.
  @override
  List<Object?> get props => [id];
  
  /// Provides a readable string representation for debugging.
  /// 
  /// This is incredibly helpful during development. When you print a Player
  /// object or see it in the debugger, you'll get meaningful information
  /// instead of just "Instance of Player".
  @override
  String toString() => 'Player(id: $id, name: $name, connected: $isConnected, score: $score)';
  
  /// Converts the player to JSON for serialization
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'deviceId': deviceId,
    'isConnected': isConnected,
    'score': score,
    'isHost': isHost,
  };
  
  /// Creates a player from JSON data
  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      id: json['id'] as String,
      name: json['name'] as String,
      deviceId: json['deviceId'] as String?,
      isConnected: json['isConnected'] as bool? ?? true,
      score: json['score'] as int? ?? 0,
      isHost: json['isHost'] as bool? ?? false,
    );
  }
}
