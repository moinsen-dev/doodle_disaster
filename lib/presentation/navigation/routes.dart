/// Route constants for navigation throughout the app.
/// 
/// Using constants prevents typos and makes refactoring easier.
/// If we need to change a route path, we only update it here.
class Routes {
  // Prevent instantiation
  Routes._();
  
  /// Home screen where players can create or join games
  static const String home = '/';
  
  /// Game lobby where players wait before starting
  static const String lobby = '/lobby';
  
  /// Drawing phase where players create their doodles
  static const String drawing = '/drawing';
  
  /// Guessing phase where players interpret drawings
  static const String guessing = '/guessing';
  
  /// Reveal screen showing the transformation chain
  static const String reveal = '/reveal';
  
  /// End game screen showing final scores and winner
  static const String endGame = '/end-game';
  
  /// Settings screen for player preferences
  static const String settings = '/settings';
  
  /// Error screen for unrecoverable errors
  static const String error = '/error';
}

/// Route arguments for passing data between screens
class RouteArguments {
  /// Arguments for the lobby screen
  static const String roomCode = 'roomCode';
  static const String isHost = 'isHost';
  
  /// Arguments for drawing screen
  static const String prompt = 'prompt';
  static const String timeLimit = 'timeLimit';
  
  /// Arguments for guessing screen
  static const String drawingData = 'drawingData';
  
  /// Arguments for error screen
  static const String errorMessage = 'errorMessage';
  static const String canRetry = 'canRetry';
}