import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';
import '../widgets/widgets.dart';

/// Settings screen for the game
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _nameController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    // Initialize with current player name
    final currentName = ref.read(playerProvider)?.name ?? '';
    _nameController.text = currentName;
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
  
  Future<void> _saveName() async {
    final newName = _nameController.text.trim();
    if (newName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a name')),
      );
      return;
    }
    
    await ref.read(playerProvider.notifier).setName(newName);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name saved!')),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final player = ref.watch(playerProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Player Settings Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Player Settings',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Your Name',
                      hintText: 'Enter your display name',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.save),
                        onPressed: _saveName,
                      ),
                    ),
                    textCapitalization: TextCapitalization.words,
                    onSubmitted: (_) => _saveName(),
                  ),
                  if (player != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Player ID: ${player.id.substring(0, 8)}...',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Game Preferences Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Game Preferences',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Sound Effects'),
                    subtitle: const Text('Coming soon'),
                    value: false,
                    onChanged: null,
                  ),
                  SwitchListTile(
                    title: const Text('Vibration'),
                    subtitle: const Text('Coming soon'),
                    value: false,
                    onChanged: null,
                  ),
                  SwitchListTile(
                    title: const Text('Show Tutorial'),
                    subtitle: const Text('Show help on first game'),
                    value: true,
                    onChanged: null,
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // About Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'About',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: const Icon(Icons.info),
                    title: const Text('Doodle Disaster'),
                    subtitle: const Text('Version 1.0.0'),
                    onTap: () {
                      showAboutDialog(
                        context: context,
                        applicationName: 'Doodle Disaster',
                        applicationVersion: '1.0.0',
                        applicationIcon: Icon(
                          Icons.brush,
                          size: 48,
                          color: theme.colorScheme.primary,
                        ),
                        children: [
                          const Text(
                            'A fun drawing and guessing game to play with friends!',
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Draw, guess, and laugh as simple prompts transform into hilarious misunderstandings.',
                          ),
                        ],
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.code),
                    title: const Text('Open Source'),
                    subtitle: const Text('View on GitHub'),
                    onTap: () {
                      // TODO: Open GitHub repository
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('GitHub link coming soon!'),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.privacy_tip),
                    title: const Text('Privacy Policy'),
                    onTap: () {
                      GameDialog.showInfo(
                        context: context,
                        title: 'Privacy Policy',
                        message: 'Doodle Disaster does not collect any personal data. '
                            'All game data is stored locally on your device and shared '
                            'only via Bluetooth with other players in your game.',
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Debug Section (only in debug mode)
          if (const bool.fromEnvironment('dart.vm.product') == false) ...[
            Card(
              color: theme.colorScheme.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Debug Tools',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.colorScheme.onErrorContainer,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          ref.invalidate(playerProvider);
                          ref.invalidate(gameSessionProvider);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('App state reset!'),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.error,
                          foregroundColor: theme.colorScheme.onError,
                        ),
                        child: const Text('Reset App State'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}