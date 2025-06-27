import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/widgets.dart';
import '../navigation/routes.dart';
import '../navigation/app_router.dart';
import '../../domain/models/models.dart';

/// Screen where players guess what others have drawn.
/// 
/// Shows the drawing preview and a text input field.
/// Automatically submits when timer expires.
class GuessingPhaseScreen extends ConsumerStatefulWidget {
  const GuessingPhaseScreen({super.key});

  @override
  ConsumerState<GuessingPhaseScreen> createState() => _GuessingPhaseScreenState();
}

class _GuessingPhaseScreenState extends ConsumerState<GuessingPhaseScreen> {
  final _guessController = TextEditingController();
  final _focusNode = FocusNode();
  bool _isSubmitting = false;
  DrawingData? _drawing;
  
  DrawingData? get drawing {
    if (_drawing != null) return _drawing;
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    _drawing = args?['drawing'];
    return _drawing;
  }
  
  int get _timeLimit {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    return args?['timeLimit'] ?? 45;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Auto-focus the text field
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _guessController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _submitGuess() async {
    final guess = _guessController.text.trim();
    
    if (guess.isEmpty) {
      GameDialog.showError(
        context: context,
        message: 'Please enter a guess!',
      );
      return;
    }
    
    // Confirm submission
    final shouldSubmit = await GameDialog.showConfirmation(
      context: context,
      title: 'Submit Guess?',
      message: 'Your guess: "$guess"',
      confirmText: 'Submit',
      cancelText: 'Keep Editing',
    );
    
    if (shouldSubmit && mounted) {
      setState(() {
        _isSubmitting = true;
      });
      
      // Submit guess and navigate to reveal phase
      AppRouter.navigateTo(
        context,
        Routes.reveal,
        arguments: {
          'chain': null, // TODO: Pass actual chain data
          'canVote': true,
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
    AppRouter.navigateTo(
      context,
      Routes.reveal,
      arguments: {
        'chain': null, // TODO: Pass actual chain data
        'canVote': true,
      },
      replace: true,
    );
  }

  void _showDrawingFullscreen() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            color: Colors.black54,
            child: Center(
              child: AspectRatio(
                aspectRatio: 1,
                child: Container(
                  color: Colors.white,
                  child: DrawingPreview(
                    drawingData: drawing!,
                    showBorder: false,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (drawing == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
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
        ),
        body: LoadingOverlay(
          isLoading: _isSubmitting,
          message: 'Submitting your guess...',
          child: Column(
            children: [
              // Drawing preview section
              Expanded(
                child: GestureDetector(
                  onTap: _showDrawingFullscreen,
                  child: Container(
                    color: theme.colorScheme.surfaceContainerHighest,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(
                          'What is this drawing?',
                          style: theme.textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap to enlarge',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: DrawingPreview(
                                  drawingData: drawing!,
                                  showBorder: false,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Guess input section
              Container(
                padding: const EdgeInsets.all(16),
                color: theme.colorScheme.surface,
                child: Column(
                  children: [
                    TextField(
                      controller: _guessController,
                      focusNode: _focusNode,
                      decoration: InputDecoration(
                        hintText: 'Enter your guess...',
                        filled: true,
                        fillColor: theme.colorScheme.surfaceContainerHighest,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: const Icon(Icons.edit),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _guessController.clear();
                            _focusNode.requestFocus();
                          },
                        ),
                      ),
                      textCapitalization: TextCapitalization.sentences,
                      maxLength: 50,
                      maxLines: 1,
                      style: theme.textTheme.bodyLarge,
                      onSubmitted: (_) => _submitGuess(),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _submitGuess,
                        icon: const Icon(Icons.send),
                        label: const Text('Submit Guess'),
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