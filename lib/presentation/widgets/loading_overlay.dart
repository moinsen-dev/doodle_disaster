import 'package:flutter/material.dart';
import '../animations/page_transitions.dart';

/// A full-screen loading overlay that prevents user interaction.
/// 
/// Displays a loading indicator with an optional message.
/// Useful for async operations like connecting to games.
class LoadingOverlay extends StatelessWidget {
  /// Whether to show the overlay
  final bool isLoading;
  
  /// Optional message to display
  final String? message;
  
  /// The child widget to overlay
  final Widget child;
  
  /// Custom loading indicator
  final Widget? loadingIndicator;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
    this.loadingIndicator,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black54,
            child: Center(
              child: _LoadingContent(
                message: message,
                loadingIndicator: loadingIndicator,
              ),
            ),
          ),
      ],
    );
  }
}

/// Content of the loading overlay
class _LoadingContent extends StatelessWidget {
  final String? message;
  final Widget? loadingIndicator;

  const _LoadingContent({
    this.message,
    this.loadingIndicator,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          loadingIndicator ?? 
              AnimatedGameCard(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 48,
                      height: 48,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    AnimatedLoadingDots(
                      color: theme.colorScheme.primary,
                      size: 6,
                    ),
                  ],
                ),
              ),
          if (message != null) ...[
            const SizedBox(height: 24),
            Text(
              message!,
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

/// Shows a loading overlay as a modal barrier
class LoadingScreen {
  static void show(BuildContext context, {String? message}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (_) => PopScope(
        canPop: false,
        child: Center(
          child: _LoadingContent(message: message),
        ),
      ),
    );
  }
  
  static void hide(BuildContext context) {
    Navigator.of(context).pop();
  }
}