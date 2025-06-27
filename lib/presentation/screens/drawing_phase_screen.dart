import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/widgets.dart';
import '../navigation/routes.dart';
import '../navigation/app_router.dart';
import '../../domain/models/models.dart';

/// Screen where players draw their doodles.
/// 
/// Shows the prompt, drawing canvas, and timer.
/// Automatically submits when timer expires.
class DrawingPhaseScreen extends ConsumerStatefulWidget {
  const DrawingPhaseScreen({super.key});

  @override
  ConsumerState<DrawingPhaseScreen> createState() => _DrawingPhaseScreenState();
}

class _DrawingPhaseScreenState extends ConsumerState<DrawingPhaseScreen> {
  DrawingData? _currentDrawing;
  bool _isSubmitting = false;
  
  String get _prompt {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    return args?['prompt'] ?? 'Draw something!';
  }
  
  int get _timeLimit {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    return args?['timeLimit'] ?? 60;
  }

  Future<void> _submitDrawing() async {
    if (_currentDrawing == null || _currentDrawing!.strokes.length < 3) {
      GameDialog.showError(
        context: context,
        message: 'Please draw something! (at least 3 strokes)',
      );
      return;
    }
    
    // Confirm submission
    final shouldSubmit = await GameDialog.showConfirmation(
      context: context,
      title: 'Submit Drawing?',
      message: 'Are you happy with your drawing?',
      confirmText: 'Submit',
      cancelText: 'Keep Drawing',
    );
    
    if (shouldSubmit && mounted) {
      setState(() {
        _isSubmitting = true;
      });
      
      // Submit drawing and navigate to guessing phase
      AppRouter.navigateTo(
        context,
        Routes.guessing,
        arguments: {
          'drawing': _currentDrawing,
          'timeLimit': 45,
        },
        replace: true,
      );
    }
  }

  Future<void> _handleTimerComplete() async {
    setState(() {
      _isSubmitting = true;
    });
    
    // Auto-submit when timer completes
    final drawingToSubmit = _currentDrawing?.strokes.isNotEmpty == true 
        ? _currentDrawing 
        : DrawingData.empty(100, 100);
    
    AppRouter.navigateTo(
      context,
      Routes.guessing,
      arguments: {
        'drawing': drawingToSubmit,
        'timeLimit': 45,
      },
      replace: true,
    );
  }

  void _showPromptAgain() {
    GameDialog.showInfo(
      context: context,
      title: 'Your Prompt',
      message: _prompt,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          title: GameTimer(
            duration: _timeLimit,
            onTimerComplete: _handleTimerComplete,
            showText: true,
            size: 48,
          ),
          centerTitle: true,
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.help_outline),
              onPressed: _showPromptAgain,
              tooltip: 'Show prompt again',
            ),
          ],
        ),
        body: LoadingOverlay(
          isLoading: _isSubmitting,
          message: 'Submitting your masterpiece...',
          child: Column(
            children: [
              // Prompt display
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                color: theme.colorScheme.primaryContainer,
                child: Column(
                  children: [
                    Text(
                      'Draw this:',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _prompt,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              
              // Drawing canvas
              Expanded(
                child: Container(
                  color: Colors.white,
                  child: DrawingCanvas(
                    showControls: true,
                    onDrawingChanged: (drawing) {
                      _currentDrawing = drawing;
                    },
                    onDone: _submitDrawing,
                  ),
                ),
              ),
              
              // Status bar
              Container(
                padding: const EdgeInsets.all(12),
                color: theme.colorScheme.surfaceContainerHighest,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Strokes: ${_currentDrawing?.strokes.length ?? 0}',
                      style: theme.textTheme.bodyMedium,
                    ),
                    Text(
                      _currentDrawing?.strokes.isEmpty ?? true
                          ? 'Start drawing!'
                          : 'Tap done when finished',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}