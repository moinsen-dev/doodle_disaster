import 'package:flutter/material.dart';

/// Consistent dialog styles for the game.
/// 
/// Provides error, info, and confirmation dialogs with
/// a consistent look and feel throughout the app.
class GameDialog {
  /// Shows an error dialog
  static Future<void> showError({
    required BuildContext context,
    required String message,
    String? title,
    String buttonText = 'OK',
    VoidCallback? onDismiss,
  }) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _DialogContent(
        type: DialogType.error,
        title: title ?? 'Error',
        message: message,
        actions: [
          DialogAction(
            text: buttonText,
            onPressed: () {
              Navigator.of(context).pop();
              onDismiss?.call();
            },
            isPrimary: true,
          ),
        ],
      ),
    );
  }

  /// Shows an info dialog
  static Future<void> showInfo({
    required BuildContext context,
    required String message,
    String? title,
    String buttonText = 'Got it',
    VoidCallback? onDismiss,
  }) async {
    await showDialog(
      context: context,
      builder: (context) => _DialogContent(
        type: DialogType.info,
        title: title ?? 'Info',
        message: message,
        actions: [
          DialogAction(
            text: buttonText,
            onPressed: () {
              Navigator.of(context).pop();
              onDismiss?.call();
            },
            isPrimary: true,
          ),
        ],
      ),
    );
  }

  /// Shows a confirmation dialog
  static Future<bool> showConfirmation({
    required BuildContext context,
    required String message,
    String? title,
    String confirmText = 'Yes',
    String cancelText = 'No',
    bool isDestructive = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => _DialogContent(
        type: DialogType.confirmation,
        title: title ?? 'Confirm',
        message: message,
        actions: [
          DialogAction(
            text: cancelText,
            onPressed: () => Navigator.of(context).pop(false),
            isPrimary: false,
          ),
          DialogAction(
            text: confirmText,
            onPressed: () => Navigator.of(context).pop(true),
            isPrimary: true,
            isDestructive: isDestructive,
          ),
        ],
      ),
    );
    
    return result ?? false;
  }

  /// Shows a custom dialog with multiple actions
  static Future<T?> showCustom<T>({
    required BuildContext context,
    required String title,
    required Widget content,
    required List<DialogAction> actions,
    bool barrierDismissible = true,
  }) async {
    return await showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: content,
        actions: actions.map((action) => _buildActionButton(
          context,
          action,
        )).toList(),
      ),
    );
  }

  static Widget _buildActionButton(BuildContext context, DialogAction action) {
    final theme = Theme.of(context);
    
    if (action.isPrimary) {
      return ElevatedButton(
        onPressed: action.onPressed,
        style: action.isDestructive
            ? ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.error,
                foregroundColor: theme.colorScheme.onError,
              )
            : null,
        child: Text(action.text),
      );
    }
    
    return TextButton(
      onPressed: action.onPressed,
      child: Text(action.text),
    );
  }
}

/// Dialog content widget
class _DialogContent extends StatelessWidget {
  final DialogType type;
  final String title;
  final String message;
  final List<DialogAction> actions;

  const _DialogContent({
    required this.type,
    required this.title,
    required this.message,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AlertDialog(
      icon: _getIcon(theme),
      title: Text(title),
      content: Text(
        message,
        textAlign: TextAlign.center,
      ),
      actions: actions.map((action) => GameDialog._buildActionButton(
        context,
        action,
      )).toList(),
      actionsAlignment: MainAxisAlignment.spaceEvenly,
    );
  }

  Widget _getIcon(ThemeData theme) {
    IconData iconData;
    Color color;
    
    switch (type) {
      case DialogType.error:
        iconData = Icons.error_outline;
        color = theme.colorScheme.error;
        break;
      case DialogType.info:
        iconData = Icons.info_outline;
        color = theme.colorScheme.primary;
        break;
      case DialogType.confirmation:
        iconData = Icons.help_outline;
        color = theme.colorScheme.secondary;
        break;
    }
    
    return Icon(
      iconData,
      size: 48,
      color: color,
    );
  }
}

/// Dialog types
enum DialogType {
  error,
  info,
  confirmation,
}

/// Action button configuration
class DialogAction {
  final String text;
  final VoidCallback onPressed;
  final bool isPrimary;
  final bool isDestructive;

  const DialogAction({
    required this.text,
    required this.onPressed,
    this.isPrimary = false,
    this.isDestructive = false,
  });
}