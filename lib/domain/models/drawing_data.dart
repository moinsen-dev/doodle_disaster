import 'package:equatable/equatable.dart';

/// Represents a single point in a drawing stroke.
/// 
/// When you draw with your finger on a touchscreen, the device captures
/// your touch at many points along the path. Each of these points has
/// an x and y coordinate (like coordinates on a map) and a pressure value
/// that tells us how hard you pressed.
/// 
/// Think of this like plotting points on graph paper - each DrawingPoint
/// is one dot on that paper.
class DrawingPoint extends Equatable {
  final double x;
  final double y;
  final double pressure; // 0.0 to 1.0, where 1.0 is maximum pressure
  
  const DrawingPoint({
    required this.x,
    required this.y,
    this.pressure = 0.5, // Default to medium pressure if not provided
  });
  
  /// Converts this point to a Map for easy serialization.
  /// We'll need this when sending drawings over Bluetooth.
  Map<String, dynamic> toJson() => {
    'x': x,
    'y': y,
    'p': pressure, // Using 'p' instead of 'pressure' to save space
  };
  
  /// Creates a DrawingPoint from a Map (deserialization).
  factory DrawingPoint.fromJson(Map<String, dynamic> json) {
    return DrawingPoint(
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      pressure: (json['p'] as num?)?.toDouble() ?? 0.5,
    );
  }  
  @override
  List<Object?> get props => [x, y, pressure];
}

/// Represents a single continuous stroke made by the player.
/// 
/// When you draw, you might lift your finger and put it down again several
/// times. Each time you touch the screen and drag your finger until you lift
/// it again, that's one stroke. A drawing is made up of multiple strokes.
/// 
/// Imagine writing the letter "i" - that would be two strokes: one for the
/// vertical line and one for the dot.
class DrawingStroke extends Equatable {
  final List<DrawingPoint> points;
  final DateTime timestamp;
  
  const DrawingStroke({
    required this.points,
    required this.timestamp,
  });
  
  /// The canvas dimensions might vary between devices, so we normalize
  /// points to a 0-1 range. This ensures the drawing looks the same
  /// proportionally on all screen sizes.
  /// 
  /// Think of this like using percentages instead of fixed measurements -
  /// "50% from the left" works on any screen size.
  DrawingStroke normalize(double width, double height) {
    final normalizedPoints = points.map((point) => DrawingPoint(
      x: point.x / width,
      y: point.y / height,
      pressure: point.pressure,
    )).toList();
    
    return DrawingStroke(
      points: normalizedPoints,
      timestamp: timestamp,
    );
  }
  
  /// Converts a normalized stroke back to actual screen coordinates.
  DrawingStroke denormalize(double width, double height) {
    final denormalizedPoints = points.map((point) => DrawingPoint(
      x: point.x * width,
      y: point.y * height,
      pressure: point.pressure,
    )).toList();
    
    return DrawingStroke(
      points: denormalizedPoints,
      timestamp: timestamp,
    );
  }
  
  Map<String, dynamic> toJson() => {
    'points': points.map((p) => p.toJson()).toList(),
    'timestamp': timestamp.toIso8601String(),
  };
  
  factory DrawingStroke.fromJson(Map<String, dynamic> json) {
    return DrawingStroke(
      points: (json['points'] as List)
          .map((p) => DrawingPoint.fromJson(p as Map<String, dynamic>))
          .toList(),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
  
  @override
  List<Object?> get props => [points, timestamp];
}
/// Represents a complete drawing made up of multiple strokes.
/// 
/// This is the complete "photograph" of what the player drew. Just as a
/// sentence is made up of words, and words are made up of letters, a
/// DrawingData is made up of strokes, which are made up of points.
/// 
/// We keep track of the canvas dimensions because different devices have
/// different screen sizes. By storing this information, we can properly
/// scale drawings when displaying them on different devices.
class DrawingData extends Equatable {
  final List<DrawingStroke> strokes;
  final double canvasWidth;
  final double canvasHeight;
  final DateTime createdAt;
  
  const DrawingData({
    required this.strokes,
    required this.canvasWidth,
    required this.canvasHeight,
    required this.createdAt,
  });
  
  /// Creates an empty drawing - useful as a starting point.
  factory DrawingData.empty(double width, double height) {
    return DrawingData(
      strokes: const [],
      canvasWidth: width,
      canvasHeight: height,
      createdAt: DateTime.now(),
    );
  }
  
  /// Adds a new stroke to the drawing.
  /// 
  /// Remember, we're working with immutable objects, so we create a new
  /// DrawingData with the additional stroke rather than modifying the
  /// existing one. This is like adding a new page to a bound book - you
  /// can't change what's already printed, but you can create a new edition.
  DrawingData addStroke(DrawingStroke stroke) {
    return DrawingData(
      strokes: [...strokes, stroke],
      canvasWidth: canvasWidth,
      canvasHeight: canvasHeight,
      createdAt: createdAt,
    );
  }
  
  /// Removes the last stroke (undo functionality).
  /// 
  /// This is useful when players make mistakes. Have you ever wished you
  /// could take back the last thing you said? This is the drawing equivalent!
  DrawingData removeLastStroke() {
    if (strokes.isEmpty) return this;
    
    return DrawingData(
      strokes: strokes.sublist(0, strokes.length - 1),
      canvasWidth: canvasWidth,
      canvasHeight: canvasHeight,
      createdAt: createdAt,
    );
  }
  
  /// Clears all strokes (clear canvas functionality).
  DrawingData clear() {
    return DrawingData.empty(canvasWidth, canvasHeight);
  }
  
  /// Normalizes all strokes for device-independent storage.
  /// 
  /// This is crucial for our game. When player A draws on a large tablet
  /// and player B views it on a small phone, we want the drawing to look
  /// the same proportionally. Normalization makes this possible.
  DrawingData normalize() {
    final normalizedStrokes = strokes
        .map((stroke) => stroke.normalize(canvasWidth, canvasHeight))
        .toList();
    
    return DrawingData(
      strokes: normalizedStrokes,
      canvasWidth: 1.0, // Normalized width
      canvasHeight: 1.0, // Normalized height
      createdAt: createdAt,
    );
  }
  
  /// Converts the drawing to JSON for transmission over Bluetooth.
  /// 
  /// Notice how we structure this data? We're being mindful of size because
  /// Bluetooth has limitations on how much data we can send at once. Every
  /// byte counts when sending data wirelessly!
  Map<String, dynamic> toJson() => {
    'strokes': strokes.map((s) => s.toJson()).toList(),
    'width': canvasWidth,
    'height': canvasHeight,
    'created': createdAt.toIso8601String(),
  };
  
  factory DrawingData.fromJson(Map<String, dynamic> json) {
    return DrawingData(
      strokes: (json['strokes'] as List)
          .map((s) => DrawingStroke.fromJson(s as Map<String, dynamic>))
          .toList(),
      canvasWidth: (json['width'] as num).toDouble(),
      canvasHeight: (json['height'] as num).toDouble(),
      createdAt: DateTime.parse(json['created'] as String),
    );
  }
  
  /// Estimates the size of this drawing in bytes.
  /// 
  /// This helps us understand if a drawing might be too complex to send
  /// efficiently. Each point takes roughly 24 bytes when serialized.
  int get estimatedSizeInBytes {
    final totalPoints = strokes.fold(0, (sum, stroke) => sum + stroke.points.length);
    return totalPoints * 24 + 100; // 100 bytes for metadata
  }
  
  @override
  List<Object?> get props => [strokes, canvasWidth, canvasHeight, createdAt];
}
