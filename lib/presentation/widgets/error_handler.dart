import 'package:flutter/material.dart';
import 'game_dialog.dart';

/// Centralized error handling for the app
class ErrorHandler {
  /// Handle Bluetooth connection errors
  static Future<void> handleBluetoothError(
    BuildContext context,
    dynamic error, {
    VoidCallback? onRetry,
  }) async {
    String message;
    String title = 'Connection Error';
    
    if (error.toString().contains('Bluetooth')) {
      if (error.toString().contains('not available')) {
        title = 'Bluetooth Not Available';
        message = 'This device doesn\'t support Bluetooth or it\'s disabled. '
            'Please enable Bluetooth in your device settings.';
      } else if (error.toString().contains('permission')) {
        title = 'Permission Required';
        message = 'Bluetooth permission is required to play multiplayer games. '
            'Please grant permission in your device settings.';
      } else if (error.toString().contains('timeout')) {
        title = 'Connection Timeout';
        message = 'Failed to connect to the game. The host might be too far away '
            'or the game might have ended.';
      } else {
        message = 'Failed to connect via Bluetooth. Make sure both devices have '
            'Bluetooth enabled and are close to each other.';
      }
    } else {
      message = 'An unexpected error occurred: ${error.toString()}';
    }
    
    await GameDialog.showError(
      context: context,
      title: title,
      message: message,
    );
    
    if (onRetry != null && context.mounted) {
      final shouldRetry = await GameDialog.showConfirmation(
        context: context,
        title: 'Try Again?',
        message: 'Would you like to try connecting again?',
        confirmText: 'Retry',
        cancelText: 'Cancel',
      );
      
      if (shouldRetry) {
        onRetry();
      }
    }
  }
  
  /// Handle game state errors
  static Future<void> handleGameError(
    BuildContext context,
    dynamic error, {
    bool canRecover = false,
    VoidCallback? onRecover,
  }) async {
    String message;
    String title = 'Game Error';
    
    if (error.toString().contains('session')) {
      title = 'Session Error';
      message = 'There was a problem with the game session. This might happen '
          'if the host disconnected or the game ended unexpectedly.';
    } else if (error.toString().contains('drawing')) {
      title = 'Drawing Error';
      message = 'Failed to save your drawing. Please try drawing again.';
    } else if (error.toString().contains('guess')) {
      title = 'Submission Error';
      message = 'Failed to submit your guess. Please try again.';
    } else {
      message = 'An unexpected game error occurred: ${error.toString()}';
    }
    
    await GameDialog.showError(
      context: context,
      title: title,
      message: message,
    );
    
    if (canRecover && onRecover != null && context.mounted) {
      final shouldRecover = await GameDialog.showConfirmation(
        context: context,
        title: 'Try to Recover?',
        message: 'We can try to recover your progress. Continue?',
        confirmText: 'Recover',
        cancelText: 'Start Over',
      );
      
      if (shouldRecover) {
        onRecover();
      }
    }
  }
  
  /// Handle network/connectivity errors
  static Future<void> handleConnectivityError(
    BuildContext context,
    dynamic error, {
    VoidCallback? onRetry,
  }) async {
    String message = 'Connection lost with other players. This might happen if:\n\n'
        '• Players moved too far apart\n'
        '• Bluetooth was disabled\n'
        '• The host left the game\n\n'
        'You can try to reconnect or return to the main menu.';
    
    await GameDialog.showError(
      context: context,
      title: 'Connection Lost',
      message: message,
    );
    
    if (onRetry != null && context.mounted) {
      final action = await _showConnectionLostDialog(context);
      switch (action) {
        case ConnectionLostAction.retry:
          onRetry();
          break;
        case ConnectionLostAction.mainMenu:
          if (context.mounted) {
            Navigator.of(context).popUntil((route) => route.isFirst);
          }
          break;
        case ConnectionLostAction.cancel:
          break;
      }
    }
  }
  
  /// Show a specific dialog for connection lost scenarios
  static Future<ConnectionLostAction> _showConnectionLostDialog(
    BuildContext context,
  ) async {
    return await showDialog<ConnectionLostAction>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: Icon(
          Icons.signal_wifi_connected_no_internet_4,
          size: 48,
          color: Theme.of(context).colorScheme.error,
        ),
        title: const Text('Connection Lost'),
        content: const Text(
          'Lost connection with other players. What would you like to do?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(ConnectionLostAction.cancel),
            child: const Text('Stay Here'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(ConnectionLostAction.mainMenu),
            child: const Text('Main Menu'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(ConnectionLostAction.retry),
            child: const Text('Try to Reconnect'),
          ),
        ],
      ),
    ) ?? ConnectionLostAction.cancel;
  }
  
  /// Handle general app errors
  static Future<void> handleGeneralError(
    BuildContext context,
    dynamic error, {
    String? customMessage,
  }) async {
    final message = customMessage ?? 'Something went wrong: ${error.toString()}';
    
    await GameDialog.showError(
      context: context,
      title: 'Error',
      message: message,
    );
  }
}

/// Actions available when connection is lost
enum ConnectionLostAction {
  retry,
  mainMenu,
  cancel,
}