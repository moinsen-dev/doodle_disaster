import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';
import '../navigation/routes.dart';
import '../navigation/app_router.dart';
import 'loading_overlay.dart';
import '../../domain/services/bluetooth_service.dart';

/// Dialog for joining a game via Bluetooth or room code
class JoinGameDialog extends ConsumerStatefulWidget {
  const JoinGameDialog({super.key});

  @override
  ConsumerState<JoinGameDialog> createState() => _JoinGameDialogState();
}

class _JoinGameDialogState extends ConsumerState<JoinGameDialog> {
  final _roomCodeController = TextEditingController();
  bool _isScanning = false;
  
  @override
  void initState() {
    super.initState();
    _initializeBluetooth();
  }
  
  Future<void> _initializeBluetooth() async {
    try {
      await ref.read(bluetoothProvider.notifier).initialize();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Bluetooth error: $e')),
        );
      }
    }
  }
  
  @override
  void dispose() {
    _roomCodeController.dispose();
    if (_isScanning) {
      ref.read(bluetoothProvider.notifier).stopScanning();
    }
    super.dispose();
  }
  
  Future<void> _startScanning() async {
    setState(() => _isScanning = true);
    try {
      await ref.read(bluetoothProvider.notifier).startScanning();
    } catch (e) {
      if (mounted) {
        setState(() => _isScanning = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Scan error: $e')),
        );
      }
    }
  }
  
  Future<void> _stopScanning() async {
    await ref.read(bluetoothProvider.notifier).stopScanning();
    setState(() => _isScanning = false);
  }
  
  Future<void> _connectToDevice(DiscoveredDevice device) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const LoadingOverlay(
        isLoading: true,
        message: 'Connecting to game...',
        child: SizedBox(),
      ),
    );
    
    try {
      await ref.read(bluetoothProvider.notifier).connectToHost(device);
      if (mounted) {
        Navigator.of(context).pop(); // Close loading
        Navigator.of(context).pop(); // Close join dialog
        AppRouter.navigateTo(
          context,
          Routes.lobby,
          arguments: {
            RouteArguments.roomCode: device.roomCode,
            RouteArguments.isHost: false,
          },
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Close loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to connect: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
  
  Future<void> _joinWithCode() async {
    final code = _roomCodeController.text.trim().toUpperCase();
    if (code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Room code must be 6 characters')),
      );
      return;
    }
    
    // For now, create a mock session
    await ref.read(gameSessionProvider.notifier).joinGame(code);
    
    if (mounted) {
      Navigator.of(context).pop();
      AppRouter.navigateTo(
        context,
        Routes.lobby,
        arguments: {
          RouteArguments.roomCode: code,
          RouteArguments.isHost: false,
        },
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bluetoothState = ref.watch(bluetoothProvider);
    final discoveredDevicesAsync = ref.watch(discoveredDevicesProvider);
    
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Join Game',
                style: theme.textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              
              // Room code input
              TextField(
                controller: _roomCodeController,
                decoration: InputDecoration(
                  labelText: 'Room Code',
                  hintText: 'Enter 6-letter code',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.arrow_forward),
                    onPressed: _joinWithCode,
                  ),
                ),
                textCapitalization: TextCapitalization.characters,
                maxLength: 6,
                onSubmitted: (_) => _joinWithCode(),
              ),
              
              const SizedBox(height: 16),
              
              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'OR',
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Bluetooth section
              if (!bluetoothState.isInitialized)
                const Center(child: CircularProgressIndicator())
              else if (bluetoothState.error != null)
                Column(
                  children: [
                    Icon(
                      Icons.bluetooth_disabled,
                      size: 48,
                      color: theme.colorScheme.error,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Bluetooth unavailable',
                      style: TextStyle(color: theme.colorScheme.error),
                    ),
                  ],
                )
              else ...[
                ElevatedButton.icon(
                  onPressed: _isScanning ? _stopScanning : _startScanning,
                  icon: Icon(_isScanning ? Icons.stop : Icons.bluetooth_searching),
                  label: Text(_isScanning ? 'Stop Scanning' : 'Find Nearby Games'),
                ),
                
                const SizedBox(height: 16),
                
                // Device list
                if (_isScanning)
                  Expanded(
                    child: discoveredDevicesAsync.when(
                      data: (devices) {
                        if (devices.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const CircularProgressIndicator(),
                                const SizedBox(height: 16),
                                Text(
                                  'Searching for games...',
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          );
                        }
                        
                        return ListView.builder(
                          shrinkWrap: true,
                          itemCount: devices.length,
                          itemBuilder: (context, index) {
                            final device = devices[index];
                            return Card(
                              child: ListTile(
                                leading: const Icon(Icons.phone_android),
                                title: Text(device.name),
                                subtitle: Text('Room: ${device.roomCode}'),
                                trailing: const Icon(Icons.arrow_forward),
                                onTap: () => _connectToDevice(device),
                              ),
                            );
                          },
                        );
                      },
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (error, stack) => Center(
                        child: Text(
                          'Error: $error',
                          style: TextStyle(color: theme.colorScheme.error),
                        ),
                      ),
                    ),
                  ),
              ],
              
              const SizedBox(height: 16),
              
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}