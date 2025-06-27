import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'routes.dart';
import '../screens/game_lobby_screen.dart';
import '../screens/drawing_phase_screen.dart';
import '../screens/guessing_phase_screen.dart';
import '../screens/reveal_screen.dart';
import '../screens/end_game_screen.dart';
import '../screens/settings_screen.dart';
import '../providers/providers.dart';
import '../animations/page_transitions.dart';
import '../../main.dart';

/// Main router for the application.
/// 
/// This handles all navigation logic including route guards,
/// transitions, and deep linking support.
class AppRouter {
  /// Generate routes based on settings
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.home:
        return PageTransitions.fade(const HomeScreen());
        
      case Routes.lobby:
        return PageTransitions.slideFromRight(const GameLobbyScreen());
        
      case Routes.drawing:
        return PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const DrawingPhaseScreen(),
          settings: settings,
          transitionDuration: const Duration(milliseconds: 400),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOut;
            
            var tween = Tween(begin: begin, end: end).chain(
              CurveTween(curve: curve),
            );
            
            return SlideTransition(
              position: animation.drive(tween),
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            );
          },
        );
        
      case Routes.guessing:
        return PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const GuessingPhaseScreen(),
          settings: settings,
          transitionDuration: const Duration(milliseconds: 400),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOut;
            
            var tween = Tween(begin: begin, end: end).chain(
              CurveTween(curve: curve),
            );
            
            return SlideTransition(
              position: animation.drive(tween),
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            );
          },
        );
        
      case Routes.reveal:
        return PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const RevealScreen(),
          settings: settings,
          transitionDuration: const Duration(milliseconds: 600),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // Special reveal animation with scale and fade
            const curve = Curves.elasticOut;
            
            var scaleTween = Tween(begin: 0.8, end: 1.0).chain(
              CurveTween(curve: curve),
            );
            
            var fadeTween = Tween(begin: 0.0, end: 1.0).chain(
              CurveTween(curve: Curves.easeIn),
            );
            
            return ScaleTransition(
              scale: animation.drive(scaleTween),
              child: FadeTransition(
                opacity: animation.drive(fadeTween),
                child: child,
              ),
            );
          },
        );
        
      case Routes.endGame:
        return PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const EndGameScreen(),
          settings: settings,
          transitionDuration: const Duration(milliseconds: 800),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // Celebration animation with scale and rotation
            const curve = Curves.elasticOut;
            
            var scaleTween = Tween(begin: 0.5, end: 1.0).chain(
              CurveTween(curve: curve),
            );
            
            var fadeTween = Tween(begin: 0.0, end: 1.0).chain(
              CurveTween(curve: Curves.easeInOut),
            );
            
            return ScaleTransition(
              scale: animation.drive(scaleTween),
              child: FadeTransition(
                opacity: animation.drive(fadeTween),
                child: child,
              ),
            );
          },
        );
        
      case Routes.settings:
        return PageTransitions.slideFromBottom(const SettingsScreen());
        
      case Routes.error:
        final args = settings.arguments as Map<String, dynamic>?;
        return PageTransitions.fade(
          _ErrorScreen(
            message: args?[RouteArguments.errorMessage] ?? 'An error occurred',
            canRetry: args?[RouteArguments.canRetry] ?? false,
          ),
        );
        
      default:
        return PageTransitions.fade(
          const _ErrorScreen(
            message: 'Page not found',
            canRetry: true,
          ),
        );
    }
  }
  
  /// Navigate with route guards
  static Future<void> navigateTo(
    BuildContext context,
    String route, {
    Map<String, dynamic>? arguments,
    bool replace = false,
  }) async {
    // Add route guards here
    if (_canNavigateTo(context, route)) {
      if (replace) {
        await Navigator.pushReplacementNamed(
          context,
          route,
          arguments: arguments,
        );
      } else {
        await Navigator.pushNamed(
          context,
          route,
          arguments: arguments,
        );
      }
    }
  }
  
  /// Check if navigation is allowed
  static bool _canNavigateTo(BuildContext context, String route) {
    // Get current game state
    final container = ProviderScope.containerOf(context);
    final gameSession = container.read(gameSessionProvider);
    
    // Route guards
    switch (route) {
      case Routes.drawing:
      case Routes.guessing:
      case Routes.reveal:
      case Routes.endGame:
        // Can only access game screens if in a session
        return gameSession != null;
        
      default:
        return true;
    }
  }
  
  /// Pop until home
  static void popToHome(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }
}

/// Error screen for navigation errors
class _ErrorScreen extends StatelessWidget {
  final String message;
  final bool canRetry;
  
  const _ErrorScreen({
    required this.message,
    this.canRetry = false,
  });
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 24),
              Text(
                'Oops!',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 16),
              Text(
                message,
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              if (canRetry)
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Try Again'),
                )
              else
                ElevatedButton(
                  onPressed: () => AppRouter.popToHome(context),
                  child: const Text('Go Home'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}