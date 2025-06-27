import 'package:flutter/material.dart';
import '../../domain/models/models.dart';

/// Displays a list of players with their status indicators.
/// 
/// Shows player names, avatars, host crown, and status
/// (ready, drawing, guessing, waiting).
class PlayerList extends StatelessWidget {
  /// List of players to display
  final List<Player> players;
  
  /// ID of the host player
  final String hostPlayerId;
  
  /// Current player's ID (to highlight)
  final String? currentPlayerId;
  
  /// Map of player statuses
  final Map<String, PlayerStatus>? playerStatuses;
  
  /// Whether to show in compact mode
  final bool compact;

  const PlayerList({
    super.key,
    required this.players,
    required this.hostPlayerId,
    this.currentPlayerId,
    this.playerStatuses,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return _buildCompactList(context);
    }
    
    return _buildFullList(context);
  }

  Widget _buildFullList(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Players (${players.length})',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        ...players.map((player) => _PlayerTile(
          player: player,
          isHost: player.id == hostPlayerId,
          isCurrentPlayer: player.id == currentPlayerId,
          status: playerStatuses?[player.id] ?? PlayerStatus.waiting,
        )),
      ],
    );
  }

  Widget _buildCompactList(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: players.map((player) => _PlayerChip(
        player: player,
        isHost: player.id == hostPlayerId,
        isCurrentPlayer: player.id == currentPlayerId,
        status: playerStatuses?[player.id] ?? PlayerStatus.waiting,
      )).toList(),
    );
  }
}

/// Status of a player during the game
enum PlayerStatus {
  waiting,
  ready,
  drawing,
  guessing,
  done,
}

/// Full player tile for lobby view
class _PlayerTile extends StatelessWidget {
  final Player player;
  final bool isHost;
  final bool isCurrentPlayer;
  final PlayerStatus status;

  const _PlayerTile({
    required this.player,
    required this.isHost,
    required this.isCurrentPlayer,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCurrentPlayer 
            ? theme.colorScheme.primaryContainer 
            : theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: isCurrentPlayer 
            ? Border.all(color: theme.colorScheme.primary, width: 2)
            : null,
      ),
      child: Row(
        children: [
          // Avatar
          _PlayerAvatar(
            playerName: player.name,
            size: 40,
          ),
          const SizedBox(width: 12),
          
          // Name and status
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      player.name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: isCurrentPlayer ? FontWeight.bold : null,
                      ),
                    ),
                    if (isHost) ...[
                      const SizedBox(width: 8),
                      Icon(
                        Icons.star,
                        size: 16,
                        color: Colors.amber,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  _getStatusText(status),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: _getStatusColor(status),
                  ),
                ),
              ],
            ),
          ),
          
          // Status icon
          _StatusIcon(status: status),
        ],
      ),
    );
  }

  String _getStatusText(PlayerStatus status) {
    switch (status) {
      case PlayerStatus.waiting:
        return 'Waiting...';
      case PlayerStatus.ready:
        return 'Ready!';
      case PlayerStatus.drawing:
        return 'Drawing...';
      case PlayerStatus.guessing:
        return 'Guessing...';
      case PlayerStatus.done:
        return 'Done!';
    }
  }

  Color _getStatusColor(PlayerStatus status) {
    switch (status) {
      case PlayerStatus.waiting:
        return Colors.grey;
      case PlayerStatus.ready:
        return Colors.green;
      case PlayerStatus.drawing:
        return Colors.blue;
      case PlayerStatus.guessing:
        return Colors.orange;
      case PlayerStatus.done:
        return Colors.green;
    }
  }
}

/// Compact player chip for in-game view
class _PlayerChip extends StatelessWidget {
  final Player player;
  final bool isHost;
  final bool isCurrentPlayer;
  final PlayerStatus status;

  const _PlayerChip({
    required this.player,
    required this.isHost,
    required this.isCurrentPlayer,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isCurrentPlayer 
            ? theme.colorScheme.primaryContainer 
            : theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
        border: isCurrentPlayer 
            ? Border.all(color: theme.colorScheme.primary, width: 2)
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PlayerAvatar(
            playerName: player.name,
            size: 24,
          ),
          const SizedBox(width: 8),
          Text(
            player.name,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: isCurrentPlayer ? FontWeight.bold : null,
            ),
          ),
          if (isHost) ...[
            const SizedBox(width: 4),
            Icon(
              Icons.star,
              size: 14,
              color: Colors.amber,
            ),
          ],
          const SizedBox(width: 4),
          _StatusIcon(status: status, size: 16),
        ],
      ),
    );
  }
}

/// Player avatar with initials
class _PlayerAvatar extends StatelessWidget {
  final String playerName;
  final double size;

  const _PlayerAvatar({
    required this.playerName,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final initials = _getInitials(playerName);
    final color = _getAvatarColor(playerName);
    
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.4,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final words = name.trim().split(' ');
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    }
    return name.substring(0, 2).toUpperCase();
  }

  Color _getAvatarColor(String name) {
    // Generate a color based on the name
    final colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.indigo,
      Colors.pink,
    ];
    
    final index = name.length % colors.length;
    return colors[index];
  }
}

/// Status icon for player
class _StatusIcon extends StatelessWidget {
  final PlayerStatus status;
  final double size;

  const _StatusIcon({
    required this.status,
    this.size = 20,
  });

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;
    
    switch (status) {
      case PlayerStatus.waiting:
        icon = Icons.hourglass_empty;
        color = Colors.grey;
        break;
      case PlayerStatus.ready:
        icon = Icons.check_circle;
        color = Colors.green;
        break;
      case PlayerStatus.drawing:
        icon = Icons.brush;
        color = Colors.blue;
        break;
      case PlayerStatus.guessing:
        icon = Icons.help_outline;
        color = Colors.orange;
        break;
      case PlayerStatus.done:
        icon = Icons.done_all;
        color = Colors.green;
        break;
    }
    
    return Icon(
      icon,
      size: size,
      color: color,
    );
  }
}