import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/widgets.dart';
import '../providers/providers.dart';
import '../navigation/routes.dart';
import '../navigation/app_router.dart';
import '../../domain/models/models.dart';

/// The game lobby where players wait before starting.
/// 
/// Shows the room code, player list, and game settings.
/// Host can start the game when ready.
class GameLobbyScreen extends ConsumerStatefulWidget {
  const GameLobbyScreen({super.key});

  @override
  ConsumerState<GameLobbyScreen> createState() => _GameLobbyScreenState();
}

class _GameLobbyScreenState extends ConsumerState<GameLobbyScreen> {
  @override
  Widget build(BuildContext context) {
    final gameSession = ref.watch(gameSessionProvider);
    final currentPlayer = ref.watch(playerProvider);
    final roomCode = ref.watch(roomCodeProvider);
    
    // Listen to game session state changes for navigation
    ref.listen<GameSession?>(gameSessionProvider, (previous, current) {
      if (current == null) {
        // Game ended or disconnected, go back to home
        AppRouter.popToHome(context);
      } else if (previous?.state != current.state) {
        // Game state changed, handle navigation
        switch (current.state) {
          case SessionState.inProgress:
            // Game started, navigate to drawing phase
            AppRouter.navigateTo(
              context,
              Routes.drawing,
              arguments: {
                RouteArguments.prompt: 'A happy cat',
                RouteArguments.timeLimit: 60,
              },
              replace: true,
            );
            break;
          default:
            // Stay in lobby for other states
            break;
        }
      }
    });
    
    if (gameSession == null || currentPlayer == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    final isHost = currentPlayer.id == gameSession.hostPlayerId;
    final players = gameSession.players.values.toList();
    final canStart = players.length >= gameSession.settings.minPlayers;
    
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          final shouldLeave = await GameDialog.showConfirmation(
            context: context,
            title: 'Leave Game?',
            message: 'Are you sure you want to leave the game?',
            confirmText: 'Leave',
            cancelText: 'Stay',
            isDestructive: true,
          );
          
          if (shouldLeave && context.mounted) {
            // Clear game session and go home
            ref.read(gameSessionProvider.notifier).leaveGame();
            AppRouter.popToHome(context);
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Game Lobby'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () async {
              final shouldLeave = await GameDialog.showConfirmation(
                context: context,
                title: 'Leave Game?',
                message: 'Are you sure you want to leave the game?',
                confirmText: 'Leave',
                cancelText: 'Stay',
                isDestructive: true,
              );
              
              if (shouldLeave && context.mounted) {
                ref.read(gameSessionProvider.notifier).leaveGame();
                AppRouter.popToHome(context);
              }
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                // TODO: Show game settings
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Settings coming soon!')),
                );
              },
            ),
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Room code display
                if (roomCode != null)
                  RoomCodeDisplay(
                    roomCode: roomCode,
                    size: RoomCodeSize.large,
                  ),
                
                const SizedBox(height: 32),
                
                // Player list
                Expanded(
                  child: PlayerList(
                    players: players,
                    hostPlayerId: gameSession.hostPlayerId,
                    currentPlayerId: currentPlayer.id,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Game info
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        gameSession.settings.summary,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      if (!canStart) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Need at least ${gameSession.settings.minPlayers} players to start',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Start button (host only)
                if (isHost)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: canStart
                          ? () {
                              ref.read(gameSessionProvider.notifier).startGame();
                            }
                          : null,
                      child: Text(
                        canStart ? 'Start Game' : 'Waiting for Players...',
                      ),
                    ),
                  )
                else
                  Text(
                    'Waiting for host to start...',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}