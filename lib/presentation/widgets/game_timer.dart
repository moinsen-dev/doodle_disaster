import 'dart:async';
import 'package:flutter/material.dart';

/// A countdown timer widget with animation and color changes.
/// 
/// The timer changes color as time runs out:
/// - Green when > 50% time remaining
/// - Yellow when 20-50% time remaining  
/// - Red when < 20% time remaining
/// 
/// Includes subtle pulse animation when time is running low.
class GameTimer extends StatefulWidget {
  /// Total duration in seconds
  final int duration;
  
  /// Callback when timer reaches zero
  final VoidCallback? onTimerComplete;
  
  /// Whether to auto-start the timer
  final bool autoStart;
  
  /// Size of the timer display
  final double size;
  
  /// Whether to show the time as text
  final bool showText;

  const GameTimer({
    super.key,
    required this.duration,
    this.onTimerComplete,
    this.autoStart = true,
    this.size = 60,
    this.showText = true,
  });

  @override
  State<GameTimer> createState() => _GameTimerState();
}

class _GameTimerState extends State<GameTimer>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  Timer? _timer;
  late int _remainingSeconds;
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.duration;
    
    // Setup pulse animation for urgency
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    if (widget.autoStart) {
      start();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void start() {
    if (_isRunning) return;
    
    setState(() {
      _isRunning = true;
    });
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _remainingSeconds--;
        
        // Start pulse animation when time is low
        if (_remainingSeconds <= 10 && _remainingSeconds > 0) {
          _pulseController.repeat(reverse: true);
        }
        
        if (_remainingSeconds <= 0) {
          timer.cancel();
          _isRunning = false;
          _pulseController.stop();
          widget.onTimerComplete?.call();
        }
      });
    });
  }

  void pause() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
    });
  }

  void reset() {
    _timer?.cancel();
    _pulseController.stop();
    _pulseController.reset();
    setState(() {
      _remainingSeconds = widget.duration;
      _isRunning = false;
    });
  }

  Color _getTimerColor() {
    final percentage = _remainingSeconds / widget.duration;
    
    if (percentage > 0.5) {
      return Colors.green;
    } else if (percentage > 0.2) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final color = _getTimerColor();
    final progress = _remainingSeconds / widget.duration;
    
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        final scale = _remainingSeconds <= 10 ? _pulseAnimation.value : 1.0;
        
        return Transform.scale(
          scale: scale,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: color.withValues(alpha: 0.3),
                width: 3,
              ),
            ),
            child: Stack(
              children: [
                // Circular progress indicator
                SizedBox(
                  width: widget.size,
                  height: widget.size,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 6,
                    backgroundColor: color.withValues(alpha: 0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
                
                // Time text
                if (widget.showText)
                  Center(
                    child: Text(
                      _formatTime(_remainingSeconds),
                      style: TextStyle(
                        fontSize: widget.size * 0.3,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// A linear timer bar that shrinks as time runs out
class GameTimerBar extends StatelessWidget {
  final int duration;
  final int remainingSeconds;
  final double height;
  
  const GameTimerBar({
    super.key,
    required this.duration,
    required this.remainingSeconds,
    this.height = 8,
  });
  
  Color _getTimerColor() {
    final percentage = remainingSeconds / duration;
    
    if (percentage > 0.5) {
      return Colors.green;
    } else if (percentage > 0.2) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final progress = remainingSeconds / duration;
    final color = _getTimerColor();
    
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(height / 2),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress,
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(height / 2),
          ),
        ),
      ),
    );
  }
}