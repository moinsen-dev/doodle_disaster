import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';
import '../navigation/routes.dart';
import '../animations/page_transitions.dart';
import '../../domain/models/models.dart';

/// Screen that shows final game results and scores
class EndGameScreen extends ConsumerStatefulWidget {
  const EndGameScreen({super.key});

  @override
  ConsumerState<EndGameScreen> createState() => _EndGameScreenState();
}

class _EndGameScreenState extends ConsumerState<EndGameScreen> {
  @override
  void initState() {
    super.initState();
    // Show confetti or celebration animation after a delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          // Trigger celebration
        });
      }
    });
  }

  List<MapEntry<String, Player>> _getSortedPlayers() {
    final session = ref.watch(gameSessionProvider);
    if (session == null) return [];
    
    final playerList = session.players.entries.toList();
    playerList.sort((a, b) => b.value.score.compareTo(a.value.score));
    return playerList;
  }

  Widget _buildPlayerRank(MapEntry<String, Player> entry, int rank) {
    final theme = Theme.of(context);
    final player = entry.value;
    final isWinner = rank == 1;
    
    // Medal colors
    final medalColor = switch (rank) {
      1 => Colors.amber,
      2 => Colors.grey[400],
      3 => Colors.brown[400],
      _ => null,
    };
    
    return AnimatedGameCard(
      delay: Duration(milliseconds: 300 + (rank * 100)),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isWinner 
              ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          border: isWinner 
              ? Border.all(
                  color: theme.colorScheme.primary,
                  width: 2,
                )
              : null,
          boxShadow: [
            if (isWinner)
              BoxShadow(
                color: theme.colorScheme.primary.withValues(alpha: 0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Row(
          children: [
            // Rank indicator
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: medalColor ?? theme.colorScheme.surfaceContainerHighest,
              ),
              child: Center(
                child: rank <= 3 && medalColor != null
                    ? Icon(
                        Icons.emoji_events,
                        color: Colors.white,
                        size: 24,
                      )
                    : Text(
                        '$rank',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 16),
            
            // Player info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    player.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: isWinner ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  if (player.isHost)
                    Text(
                      'Host',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                ],
              ),
            ),
            
            // Score
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${player.score}',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isWinner ? theme.colorScheme.primary : null,
                  ),
                ),
                Text(
                  'points',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameStats() {
    final theme = Theme.of(context);
    final session = ref.watch(gameSessionProvider);
    if (session == null) return const SizedBox();
    
    final totalRounds = session.rounds.length;
    final totalChains = session.rounds.fold<int>(
      0, 
      (sum, round) => sum + round.chains.length,
    );
    
    return AnimatedGameCard(
      delay: const Duration(milliseconds: 800),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _StatItem(
              icon: Icons.repeat,
              value: '$totalRounds',
              label: 'Rounds',
            ),
            Container(
              width: 1,
              height: 40,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.2),
            ),
            _StatItem(
              icon: Icons.draw,
              value: '$totalChains',
              label: 'Drawings',
            ),
            Container(
              width: 1,
              height: 40,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.2),
            ),
            _StatItem(
              icon: Icons.people,
              value: '${session.players.length}',
              label: 'Players',
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _playAgain() async {
    final session = ref.read(gameSessionProvider);
    if (session == null) return;
    
    // Reset the game session for a new game
    ref.read(gameSessionProvider.notifier).resetForNewGame();
    
    // Navigate back to lobby
    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        Routes.lobby,
        (route) => false,
        arguments: {
          'roomCode': session.sessionId,
          'isHost': session.hostPlayerId == ref.read(playerProvider)?.id,
        },
      );
    }
  }

  Future<void> _exitGame() async {
    // Clear game session
    ref.read(gameSessionProvider.notifier).clearSession();
    
    // Navigate to home
    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        Routes.home,
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sortedPlayers = _getSortedPlayers();
    final session = ref.watch(gameSessionProvider);
    final currentPlayer = ref.watch(playerProvider);
    final isHost = currentPlayer?.id == session?.hostPlayerId;
    
    if (sortedPlayers.isEmpty) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                'Loading results...',
                style: theme.textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      );
    }
    
    final winner = sortedPlayers.first.value;
    
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Winner announcement
                AnimatedGameCard(
                  delay: const Duration(milliseconds: 200),
                  child: Column(
                    children: [
                      Icon(
                        Icons.emoji_events,
                        size: 64,
                        color: Colors.amber,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Game Over!',
                        style: theme.textTheme.headlineLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${winner.name} wins!',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Game stats
                _buildGameStats(),
                
                const SizedBox(height: 24),
                
                // Player rankings
                Expanded(
                  child: ListView.builder(
                    itemCount: sortedPlayers.length,
                    itemBuilder: (context, index) {
                      return _buildPlayerRank(
                        sortedPlayers[index],
                        index + 1,
                      );
                    },
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Action buttons
                AnimatedGameCard(
                  delay: const Duration(milliseconds: 1000),
                  child: Column(
                    children: [
                      if (isHost) ...[
                        SizedBox(
                          width: double.infinity,
                          child: AnimatedGameButton(
                            onPressed: _playAgain,
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: theme.colorScheme.onPrimary,
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.refresh),
                                SizedBox(width: 8),
                                Text('Play Again'),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: _exitGame,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text('Exit to Menu'),
                        ),
                      ),
                    ],
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

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 24,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }
}