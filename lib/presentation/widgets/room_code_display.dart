import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Displays the room code prominently with copy and share functionality.
/// 
/// The code is displayed in a large, easy-to-read format with
/// visual feedback when copied to clipboard.
class RoomCodeDisplay extends StatefulWidget {
  /// The room code to display
  final String roomCode;
  
  /// Size of the display (small, medium, large)
  final RoomCodeSize size;
  
  /// Whether to show the copy button
  final bool showCopyButton;
  
  /// Whether to show the share button
  final bool showShareButton;

  const RoomCodeDisplay({
    super.key,
    required this.roomCode,
    this.size = RoomCodeSize.medium,
    this.showCopyButton = true,
    this.showShareButton = true,
  });

  @override
  State<RoomCodeDisplay> createState() => _RoomCodeDisplayState();
}

class _RoomCodeDisplayState extends State<RoomCodeDisplay> {
  bool _copied = false;

  void _copyToClipboard() async {
    await Clipboard.setData(ClipboardData(text: widget.roomCode));
    
    setState(() {
      _copied = true;
    });
    
    // Reset after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _copied = false;
        });
      }
    });
    
    // Show snackbar
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Room code copied!'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _share() {
    // For now, just copy to clipboard
    // In a real app, we'd use share_plus package
    _copyToClipboard();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fontSize = _getFontSize();
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Room Code',
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: widget.size == RoomCodeSize.small ? 16 : 24,
            vertical: widget.size == RoomCodeSize.small ? 12 : 16,
          ),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.5),
              width: 2,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Room code text
              Text(
                _formatRoomCode(widget.roomCode),
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                  color: theme.colorScheme.primary,
                  fontFamily: 'monospace',
                ),
              ),
              
              if (widget.showCopyButton || widget.showShareButton) ...[
                const SizedBox(width: 16),
                
                // Action buttons
                if (widget.showCopyButton)
                  _ActionButton(
                    icon: _copied ? Icons.check : Icons.copy,
                    onPressed: _copyToClipboard,
                    tooltip: 'Copy code',
                    color: _copied ? Colors.green : null,
                  ),
                
                if (widget.showShareButton) ...[
                  const SizedBox(width: 8),
                  _ActionButton(
                    icon: Icons.share,
                    onPressed: _share,
                    tooltip: 'Share code',
                  ),
                ],
              ],
            ],
          ),
        ),
      ],
    );
  }

  double _getFontSize() {
    switch (widget.size) {
      case RoomCodeSize.small:
        return 20;
      case RoomCodeSize.medium:
        return 28;
      case RoomCodeSize.large:
        return 36;
    }
  }

  String _formatRoomCode(String code) {
    // Add spaces between pairs for readability
    if (code.length == 6) {
      return '${code.substring(0, 3)} ${code.substring(3)}';
    }
    return code;
  }
}

/// Size options for the room code display
enum RoomCodeSize {
  small,
  medium,
  large,
}

/// Small action button used in the room code display
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final String tooltip;
  final Color? color;

  const _ActionButton({
    required this.icon,
    required this.onPressed,
    required this.tooltip,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon),
      onPressed: onPressed,
      tooltip: tooltip,
      iconSize: 20,
      color: color,
      constraints: const BoxConstraints(
        minWidth: 36,
        minHeight: 36,
      ),
      padding: const EdgeInsets.all(8),
    );
  }
}