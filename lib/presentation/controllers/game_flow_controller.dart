import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../navigation/routes.dart';
import '../navigation/app_router.dart';
import '../providers/providers.dart';
import '../widgets/game_dialog.dart';
import '../../domain/models/models.dart';

/// Controls the flow of the game by listening to state changes
/// and navigating between screens accordingly.
class GameFlowController {
  final WidgetRef ref;
  final BuildContext context;
  
  GameFlowController({
    required this.ref,
    required this.context,
  });
  
  /// Initialize the game flow controller
  void initialize() {
    // Listen to game session state changes
    ref.listen<GameSession?>(gameSessionProvider, (previous, current) {
      if (current == null) {
        // Game ended or disconnected
        _handleGameEnd();
      } else if (previous?.state != current.state) {
        // Game state changed
        _handleStateChange(current);
      }
    });
    
    // Listen to player actions
    ref.listen<PlayerAction?>(
      gameSessionProvider.select((session) => 
        session != null 
          ? ref.read(gameSessionProvider.notifier).currentPlayerAction 
          : null
      ),
      (previous, current) {
        if (current != null && previous != current) {
          _handlePlayerAction(current);
        }
      },
    );
  }
  
  /// Handle game state changes
  void _handleStateChange(GameSession session) {
    switch (session.state) {
      case SessionState.waitingForPlayers:
        // Stay in lobby
        break;
        
      case SessionState.ready:
        // Game is ready to start
        _showReadyDialog();
        break;
        
      case SessionState.inProgress:
        // Navigate based on player action
        final action = ref.read(gameSessionProvider.notifier).currentPlayerAction;
        if (action != null) {
          _handlePlayerAction(action);
        }
        break;
        
      case SessionState.roundRevealing:
        // Navigate to reveal screen
        AppRouter.navigateTo(context, Routes.reveal, replace: true);
        break;
        
      case SessionState.completed:
        // Show game over dialog
        _showGameOverDialog();
        break;
    }
  }
  
  /// Handle player action changes
  void _handlePlayerAction(PlayerAction action) {
    action.when(
      drawPrompt: (prompt) {
        AppRouter.navigateTo(
          context,
          Routes.drawing,
          replace: true,
          arguments: {
            RouteArguments.prompt: prompt,
            RouteArguments.timeLimit: ref.read(gameSessionProvider)!.settings.drawingTimeSeconds,
          },
        );
      },
      drawGuess: (guess) {
        AppRouter.navigateTo(
          context,
          Routes.drawing,
          replace: true,
          arguments: {
            RouteArguments.prompt: guess,
            RouteArguments.timeLimit: ref.read(gameSessionProvider)!.settings.drawingTimeSeconds,
          },
        );
      },
      guessDrawing: (drawing) {
        AppRouter.navigateTo(
          context,
          Routes.guessing,
          replace: true,
          arguments: {
            RouteArguments.drawingData: drawing,
            RouteArguments.timeLimit: ref.read(gameSessionProvider)!.settings.guessingTimeSeconds,
          },
        );
      },
      wait: () {
        // Show waiting screen or stay on current screen
        _showWaitingDialog();
      },
    );
  }
  
  /// Handle game end
  void _handleGameEnd() {
    GameDialog.showError(
      context: context,
      title: 'Game Ended',
      message: 'The game has ended or you were disconnected.',
      onDismiss: () {
        AppRouter.popToHome(context);
      },
    );
  }
  
  /// Show ready dialog
  void _showReadyDialog() {
    GameDialog.showInfo(
      context: context,
      title: 'Get Ready!',
      message: 'The game is about to start...',
    );
  }
  
  /// Show waiting dialog
  void _showWaitingDialog() {
    GameDialog.showInfo(
      context: context,
      title: 'Please Wait',
      message: 'Waiting for other players to finish...',
    );
  }
  
  /// Show game over dialog
  void _showGameOverDialog() {
    GameDialog.showInfo(
      context: context,
      title: 'Game Over!',
      message: 'Thanks for playing Doodle Disaster!',
      onDismiss: () {
        AppRouter.popToHome(context);
      },
    );
  }
  
  /// Submit drawing
  Future<void> submitDrawing(DrawingData drawing) async {
    try {
      ref.read(gameSessionProvider.notifier).submitDrawing(drawing);
    } catch (e) {
      GameDialog.showError(
        context: context,
        message: 'Failed to submit drawing. Please try again.',
      );
    }
  }
  
  /// Submit guess
  Future<void> submitGuess(String guess) async {
    if (guess.trim().isEmpty) {
      GameDialog.showError(
        context: context,
        message: 'Please enter a guess!',
      );
      return;
    }
    
    try {
      ref.read(gameSessionProvider.notifier).submitGuess(guess);
    } catch (e) {
      GameDialog.showError(
        context: context,
        message: 'Failed to submit guess. Please try again.',
      );
    }
  }
  
  /// Leave game
  Future<bool> confirmLeaveGame() async {
    final shouldLeave = await GameDialog.showConfirmation(
      context: context,
      title: 'Leave Game?',
      message: 'Are you sure you want to leave the game?',
      confirmText: 'Leave',
      cancelText: 'Stay',
      isDestructive: true,
    );
    
    if (shouldLeave && context.mounted) {
      // TODO: Implement leave game logic
      AppRouter.popToHome(context);
    }
    
    return shouldLeave;
  }
}