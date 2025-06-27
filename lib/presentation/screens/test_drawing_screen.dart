import 'package:flutter/material.dart';
import '../widgets/widgets.dart';
import '../../domain/models/models.dart';

/// Temporary test screen to verify drawing functionality
class TestDrawingScreen extends StatefulWidget {
  const TestDrawingScreen({super.key});

  @override
  State<TestDrawingScreen> createState() => _TestDrawingScreenState();
}

class _TestDrawingScreenState extends State<TestDrawingScreen> {
  DrawingData? _currentDrawing;

  void _handleDone() {
    // In a real game, this would submit the drawing
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Drawing submitted with ${_currentDrawing?.strokes.length ?? 0} strokes!'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Drawing Canvas'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: Colors.white,
              child: DrawingCanvas(
                initialDrawing: _currentDrawing,
                showControls: true,
                onDrawingChanged: (drawing) {
                  setState(() {
                    _currentDrawing = drawing;
                  });
                },
                onDone: _handleDone,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Text(
              'Strokes: ${_currentDrawing?.strokes.length ?? 0}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }
}