import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'presentation/screens/test_drawing_screen.dart';
import 'presentation/navigation/app_router.dart';
import 'presentation/navigation/routes.dart';
import 'presentation/providers/providers.dart';
import 'presentation/widgets/join_game_dialog.dart';
import 'presentation/animations/page_transitions.dart';

/// The entry point of our Doodle Disaster game.
/// 
/// Notice how we wrap our entire app with ProviderScope? This is like
/// setting up the electrical wiring in a house before you can plug in
/// any appliances. ProviderScope creates the container that holds all
/// our app's state, making it available throughout the widget tree.
/// 
/// Think of ProviderScope as the foundation that enables Riverpod's
/// magic - without it, our providers (state holders) have nowhere to live.
void main() {
  runApp(
    const ProviderScope(
      child: DoodleDisasterApp(),
    ),
  );
}

/// The root widget of our application.
/// 
/// This widget sets up the overall theme and navigation structure.
/// It's like the frame of a house - it doesn't have much detail itself,
/// but it holds everything else together.
class DoodleDisasterApp extends StatelessWidget {
  const DoodleDisasterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Doodle Disaster',
      
      // Let's create a fun, playful theme that matches our game's spirit
      theme: ThemeData(
        // Using Material 3 (Material You) for modern design
        useMaterial3: true,
        
        // A bright, playful color scheme
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        
        // Large, readable text for game elements
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
          ),
          headlineMedium: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w600,
          ),
        ),
        
        // Rounded buttons that feel friendly and approachable
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              horizontal: 32,
              vertical: 16,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      
      home: const HomeScreen(),
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}

/// The home screen where players can create or join games.
/// 
/// This is the first screen players see when they open the app.
/// Think of it as the lobby of a game center - from here, players
/// can either start hosting a new game or join an existing one.
/// 
/// We're using ConsumerWidget instead of StatelessWidget because
/// this widget will need to read and react to state changes from
/// our Riverpod providers.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Extract theme data for consistent styling
    final theme = Theme.of(context);
    
    return Scaffold(
      body: Container(
        // A gradient background makes the app feel more dynamic and fun
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary.withValues(alpha: 0.1),
              theme.colorScheme.secondary.withValues(alpha: 0.1),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                
                // Game title with playful styling and animation
                AnimatedGameCard(
                  delay: const Duration(milliseconds: 300),
                  child: Column(
                    children: [
                      Text(
                        'Doodle',
                        style: theme.textTheme.displayLarge?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      Text(
                        'Disaster',
                        style: theme.textTheme.displayLarge?.copyWith(
                          color: theme.colorScheme.secondary,
                          fontSize: 56, // Slightly larger for emphasis
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Tagline with animation
                AnimatedGameCard(
                  delay: const Duration(milliseconds: 600),
                  child: Text(
                    'Draw it. Pass it. Watch it fall apart!',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                
                const Spacer(),
                
                // Main action buttons with animation
                AnimatedGameCard(
                  delay: const Duration(milliseconds: 900),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: AnimatedGameButton(
                          onPressed: () async {
                            // Show loading indicator with loading dots
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (_) => Dialog(
                                backgroundColor: Colors.transparent,
                                child: Container(
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.surface,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const AnimatedLoadingDots(),
                                      const SizedBox(height: 16),
                                      Text(
                                        'Creating game...',
                                        style: theme.textTheme.bodyLarge,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                            
                            try {
                              // Create a game session
                              final roomCode = await ref.read(gameSessionProvider.notifier).createGame();
                              if (context.mounted) {
                                Navigator.of(context).pop(); // Close loading
                                AppRouter.navigateTo(
                                  context,
                                  Routes.lobby,
                                  arguments: {
                                    RouteArguments.roomCode: roomCode,
                                    RouteArguments.isHost: true,
                                  },
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                Navigator.of(context).pop(); // Close loading
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Failed to create game: $e'),
                                    backgroundColor: Theme.of(context).colorScheme.error,
                                  ),
                                );
                              }
                            }
                          },
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
                          child: const Text('Create Game'),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      SizedBox(
                        width: double.infinity,
                        child: AnimatedGameButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => const JoinGameDialog(),
                            );
                          },
                          backgroundColor: Colors.transparent,
                          foregroundColor: theme.colorScheme.primary,
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: theme.colorScheme.primary,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                            child: const Center(
                              child: Text('Join Game'),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const Spacer(),
                
                // Settings button with animation
                AnimatedGameCard(
                  delay: const Duration(milliseconds: 1200),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Temporary test button
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            PageTransitions.slideFromBottom(const TestDrawingScreen()),
                          );
                        },
                        child: const Text('Test Canvas'),
                      ),
                      IconButton(
                        onPressed: () {
                          AppRouter.navigateTo(context, Routes.settings);
                        },
                        icon: const Icon(Icons.settings),
                        tooltip: 'Settings',
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
