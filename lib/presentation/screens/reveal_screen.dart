import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/widgets.dart';
import '../providers/providers.dart';
import '../navigation/routes.dart';
import '../../domain/models/models.dart';

/// Screen that reveals the drawing chain transformations.
/// 
/// Shows how the original prompt transformed through drawings and guesses.
/// Allows voting if enabled in settings.
class RevealScreen extends ConsumerStatefulWidget {
  const RevealScreen({super.key});

  @override
  ConsumerState<RevealScreen> createState() => _RevealScreenState();
}

class _RevealScreenState extends ConsumerState<RevealScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  bool _hasVoted = false;
  final Map<String, int> _chainVotes = {}; // Track votes for each chain
  
  DrawingChain? get chain {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    return args?['chain'] ?? _createMockChain();
  }
  
  DrawingChain _createMockChain() {
    // Create a simple mock chain for testing
    return DrawingChain(
      originalPrompt: 'A happy cat',
      startingPlayerId: 'player1',
      links: [
        ChainLink.create(id: '1', playerId: 'player1', guess: 'A happy cat'),
        ChainLink.create(id: '2', playerId: 'player2', drawing: DrawingData.empty(200, 200)),
        ChainLink.create(id: '3', playerId: 'player3', guess: 'A weird circle'),
      ],
    );
  }
  
  bool get canVote {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    return args?['canVote'] ?? false;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _voteForChain() async {
    if (_hasVoted || chain == null) return;
    
    final shouldVote = await GameDialog.showConfirmation(
      context: context,
      title: 'Vote for this chain?',
      message: 'You think this is the funniest transformation?',
      confirmText: 'Vote',
      cancelText: 'Cancel',
    );
    
    if (shouldVote && mounted) {
      final chainId = chain!.startingPlayerId;
      
      setState(() {
        _hasVoted = true;
        _chainVotes[chainId] = (_chainVotes[chainId] ?? 0) + 1;
      });
      
      // Award points to the players who contributed to this chain
      final session = ref.read(gameSessionProvider);
      if (session != null) {
        final votedChain = session.currentRound?.chains.firstWhere(
          (c) => c.startingPlayerId == chainId,
        );
        
        if (votedChain != null) {
          // Award 10 points to each contributor
          final contributors = <String>{};
          for (final link in votedChain.links) {
            contributors.add(link.playerId);
          }
          
          // Update scores for each contributor
          for (final playerId in contributors) {
            final player = session.players[playerId];
            if (player != null) {
              ref.read(gameSessionProvider.notifier).addPlayer(
                player.copyWith(score: player.score + 10),
              );
            }
          }
        }
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vote recorded! Contributors earned 10 points!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _continueToNext() async {
    final session = ref.read(gameSessionProvider);
    if (session == null) return;
    
    // Complete the reveal phase
    ref.read(gameSessionProvider.notifier).nextRound();
    
    // Check if game is complete or more rounds to play
    final updatedSession = ref.read(gameSessionProvider);
    if (updatedSession?.state == SessionState.completed) {
      // Navigate to end game screen
      Navigator.of(context).pushNamedAndRemoveUntil(
        Routes.endGame,
        (route) => false,
      );
    } else if (updatedSession?.state == SessionState.inProgress) {
      // Navigate to drawing screen for next round
      Navigator.of(context).pushReplacementNamed(Routes.drawing);
    } else {
      // Something went wrong, go home
      Navigator.of(context).pushNamedAndRemoveUntil(
        Routes.home,
        (route) => false,
      );
    }
  }

  Widget _buildChainLink(ChainLink link, int index) {
    final theme = Theme.of(context);
    final gameSession = ref.watch(gameSessionProvider);
    final player = gameSession?.players[link.playerId];
    final isFirst = index == 0;
    // final isLast = index == chain!.links.length - 1; // TODO: Use for future features
    
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Step indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (index > 0)
                Icon(
                  Icons.arrow_back,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isFirst ? 'Original' : 'Step ${index + 1}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
              if (index < chain!.links.length - 1)
                Icon(
                  Icons.arrow_forward,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Content
          Expanded(
            child: Center(
              child: link.type == ChainLinkType.drawing
                  ? AspectRatio(
                      aspectRatio: 1,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: DrawingPreview(
                            drawingData: (link as DrawingLink).drawing,
                            showBorder: false,
                          ),
                        ),
                      ),
                    )
                  : Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isFirst ? Icons.lightbulb : Icons.text_fields,
                            size: 48,
                            color: theme.colorScheme.onSecondaryContainer,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            link.type == ChainLinkType.guess
                                ? (link as GuessLink).guess
                                : chain!.originalPrompt,
                            style: theme.textTheme.headlineMedium?.copyWith(
                              color: theme.colorScheme.onSecondaryContainer,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Player attribution
          if (player != null && !isFirst)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  link.type == ChainLinkType.drawing ? Icons.brush : Icons.edit,
                  size: 16,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Text(
                  link.type == ChainLinkType.drawing 
                      ? 'Drawn by ${player.name}'
                      : 'Guessed by ${player.name}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (chain == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    final totalSteps = chain!.links.length;
    
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('The Big Reveal!'),
          automaticallyImplyLeading: false,
          actions: [
            if (canVote)
              _hasVoted
                  ? Chip(
                      avatar: const Icon(Icons.check_circle, size: 16),
                      label: const Text('Voted'),
                      backgroundColor: theme.colorScheme.primaryContainer,
                    )
                  : TextButton.icon(
                      onPressed: _voteForChain,
                      icon: const Icon(Icons.star),
                      label: const Text('Vote'),
                      style: TextButton.styleFrom(
                        foregroundColor: theme.colorScheme.primary,
                      ),
                    ),
          ],
        ),
        body: Column(
          children: [
            // Progress indicator
            SizedBox(
              height: 4,
              child: LinearProgressIndicator(
                value: (_currentIndex + 1) / totalSteps,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
              ),
            ),
            
            // Chain display
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: totalSteps,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  return _buildChainLink(chain!.links[index], index);
                },
              ),
            ),
            
            // Navigation controls
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Previous button
                  IconButton.filled(
                    onPressed: _currentIndex > 0
                        ? () {
                            _pageController.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        : null,
                    icon: const Icon(Icons.arrow_back),
                    style: IconButton.styleFrom(
                      backgroundColor: _currentIndex > 0
                          ? theme.colorScheme.secondaryContainer
                          : theme.colorScheme.surfaceContainerHighest,
                      foregroundColor: _currentIndex > 0
                          ? theme.colorScheme.onSecondaryContainer
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  
                  // Step indicator
                  Text(
                    '${_currentIndex + 1} / $totalSteps',
                    style: theme.textTheme.titleMedium,
                  ),
                  
                  // Next/Continue button
                  if (_currentIndex < totalSteps - 1)
                    IconButton.filled(
                      onPressed: () {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      icon: const Icon(Icons.arrow_forward),
                      style: IconButton.styleFrom(
                        backgroundColor: theme.colorScheme.primaryContainer,
                        foregroundColor: theme.colorScheme.onPrimaryContainer,
                      ),
                    )
                  else
                    FilledButton.icon(
                      onPressed: _continueToNext,
                      icon: const Icon(Icons.check),
                      label: const Text('Continue'),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}