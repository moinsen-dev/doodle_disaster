import 'package:flutter/material.dart';

/// Controls for the drawing canvas including undo, clear, and done buttons.
/// 
/// These controls float at the bottom of the drawing area, providing
/// easy access to common drawing operations without cluttering the canvas.
class DrawingControls extends StatelessWidget {
  /// Called when the undo button is pressed
  final VoidCallback? onUndo;
  
  /// Called when the clear button is pressed
  final VoidCallback? onClear;
  
  /// Called when the done button is pressed
  final VoidCallback? onDone;
  
  /// Whether there are strokes that can be undone
  final bool canUndo;
  
  /// Whether there are strokes that can be cleared
  final bool canClear;
  
  /// Whether the done button should be enabled
  final bool canSubmit;

  const DrawingControls({
    super.key,
    this.onUndo,
    this.onClear,
    this.onDone,
    this.canUndo = false,
    this.canClear = false,
    this.canSubmit = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Positioned(
      bottom: 24,
      left: 16,
      right: 16,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Undo button
          _ControlButton(
            onPressed: canUndo ? onUndo : null,
            icon: Icons.undo,
            label: 'Undo',
            backgroundColor: theme.colorScheme.surface,
            foregroundColor: theme.colorScheme.onSurface,
          ),
          
          // Clear button
          _ControlButton(
            onPressed: canClear ? onClear : null,
            icon: Icons.clear,
            label: 'Clear',
            backgroundColor: theme.colorScheme.errorContainer,
            foregroundColor: theme.colorScheme.onErrorContainer,
          ),
          
          // Done button
          _ControlButton(
            onPressed: canSubmit ? onDone : null,
            icon: Icons.check,
            label: 'Done',
            backgroundColor: theme.colorScheme.primaryContainer,
            foregroundColor: theme.colorScheme.onPrimaryContainer,
            isLarge: true,
          ),
        ],
      ),
    );
  }
}

/// Individual control button with icon and label
class _ControlButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final String label;
  final Color backgroundColor;
  final Color foregroundColor;
  final bool isLarge;

  const _ControlButton({
    required this.onPressed,
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
    this.isLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    final size = isLarge ? 64.0 : 56.0;
    final iconSize = isLarge ? 32.0 : 24.0;
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          elevation: onPressed != null ? 4 : 0,
          borderRadius: BorderRadius.circular(size / 2),
          color: backgroundColor.withValues(alpha: onPressed != null ? 1.0 : 0.5),
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(size / 2),
            child: Container(
              width: size,
              height: size,
              alignment: Alignment.center,
              child: Icon(
                icon,
                size: iconSize,
                color: foregroundColor.withValues(alpha: onPressed != null ? 1.0 : 0.5),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: foregroundColor.withValues(alpha: onPressed != null ? 1.0 : 0.5),
          ),
        ),
      ],
    );
  }
}