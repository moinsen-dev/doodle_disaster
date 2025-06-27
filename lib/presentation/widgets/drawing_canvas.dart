import 'package:flutter/material.dart';
import 'package:perfect_freehand/perfect_freehand.dart';
import '../../domain/models/models.dart';
import 'drawing_controls.dart';

/// A widget that captures touch input and renders drawing strokes.
/// 
/// This is the core interaction component where players create their doodles.
/// It converts touch gestures into DrawingData that can be shared with other players.
class DrawingCanvas extends StatefulWidget {
  /// Callback when the drawing data changes
  final ValueChanged<DrawingData>? onDrawingChanged;
  
  /// Initial drawing data to display (useful for editing)
  final DrawingData? initialDrawing;
  
  /// Whether the canvas is read-only (for previewing)
  final bool readOnly;
  
  /// Whether to show drawing controls (undo, clear, done)
  final bool showControls;
  
  /// Callback when the done button is pressed
  final VoidCallback? onDone;

  const DrawingCanvas({
    super.key,
    this.onDrawingChanged,
    this.initialDrawing,
    this.readOnly = false,
    this.showControls = false,
    this.onDone,
  });

  @override
  State<DrawingCanvas> createState() => _DrawingCanvasState();
}

class _DrawingCanvasState extends State<DrawingCanvas> {
  late DrawingData _drawingData;
  List<DrawingPoint> _currentStroke = [];
  Size? _canvasSize;

  @override
  void initState() {
    super.initState();
    // We'll initialize with empty drawing data once we have the canvas size
    _drawingData = widget.initialDrawing ?? DrawingData.empty(100, 100);
  }

  void _handlePanStart(DragStartDetails details) {
    if (widget.readOnly || _canvasSize == null) return;
    
    setState(() {
      _currentStroke = [
        DrawingPoint(
          x: details.localPosition.dx,
          y: details.localPosition.dy,
          pressure: 1.0,
        ),
      ];
    });
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    if (widget.readOnly || _canvasSize == null) return;
    
    setState(() {
      _currentStroke.add(
        DrawingPoint(
          x: details.localPosition.dx,
          y: details.localPosition.dy,
          pressure: 1.0, // Flutter doesn't provide pressure on all devices
        ),
      );
    });
  }

  void _handlePanEnd(DragEndDetails details) {
    if (widget.readOnly || _canvasSize == null) return;
    
    if (_currentStroke.isNotEmpty) {
      setState(() {
        final newStroke = DrawingStroke(
          points: List.from(_currentStroke),
          timestamp: DateTime.now(),
        );
        
        _drawingData = _drawingData.addStroke(newStroke);
        _currentStroke = [];
      });
      
      widget.onDrawingChanged?.call(_drawingData);
    }
  }
  
  void _handleUndo() {
    if (_drawingData.strokes.isNotEmpty) {
      setState(() {
        _drawingData = _drawingData.removeLastStroke();
      });
      widget.onDrawingChanged?.call(_drawingData);
    }
  }
  
  void _handleClear() {
    setState(() {
      _drawingData = _drawingData.clear();
    });
    widget.onDrawingChanged?.call(_drawingData);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Initialize canvas size if not set
        if (_canvasSize == null && constraints.hasBoundedWidth && constraints.hasBoundedHeight) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() {
              _canvasSize = Size(constraints.maxWidth, constraints.maxHeight);
              _drawingData = widget.initialDrawing ?? 
                  DrawingData.empty(constraints.maxWidth, constraints.maxHeight);
            });
          });
        }
        
        final canvas = ClipRect(
          child: GestureDetector(
            onPanStart: _handlePanStart,
            onPanUpdate: _handlePanUpdate,
            onPanEnd: _handlePanEnd,
            child: CustomPaint(
              painter: DrawingPainter(
                drawingData: _drawingData,
                currentStroke: _currentStroke,
              ),
              size: Size.infinite,
            ),
          ),
        );
        
        if (widget.showControls && !widget.readOnly) {
          return Stack(
            children: [
              canvas,
              DrawingControls(
                canUndo: _drawingData.strokes.isNotEmpty,
                canClear: _drawingData.strokes.isNotEmpty,
                canSubmit: _drawingData.strokes.isNotEmpty,
                onUndo: _handleUndo,
                onClear: _handleClear,
                onDone: widget.onDone,
              ),
            ],
          );
        }
        
        return canvas;
      },
    );
  }
}

/// Custom painter that renders the drawing strokes
class DrawingPainter extends CustomPainter {
  final DrawingData drawingData;
  final List<DrawingPoint> currentStroke;

  DrawingPainter({
    required this.drawingData,
    required this.currentStroke,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Paint all completed strokes
    for (final stroke in drawingData.strokes) {
      _paintStroke(canvas, stroke);
    }
    
    // Paint current stroke being drawn
    if (currentStroke.isNotEmpty) {
      _paintStroke(
        canvas,
        DrawingStroke(
          points: currentStroke,
          timestamp: DateTime.now(),
        ),
      );
    }
  }

  void _paintStroke(Canvas canvas, DrawingStroke stroke) {
    if (stroke.points.isEmpty) return;
    
    // Convert DrawingPoints to perfect_freehand format
    final points = stroke.points
        .map((p) => PointVector(p.x, p.y, p.pressure))
        .toList();
    
    // Generate smooth stroke outline using perfect_freehand
    final outlinePoints = getStroke(points);
    
    // Create path from outline points
    final path = Path();
    if (outlinePoints.isNotEmpty) {
      path.moveTo(outlinePoints[0].dx, outlinePoints[0].dy);
      for (int i = 1; i < outlinePoints.length; i++) {
        path.lineTo(outlinePoints[i].dx, outlinePoints[i].dy);
      }
      path.close();
    }
    
    // Draw the path
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(DrawingPainter oldDelegate) {
    return oldDelegate.drawingData != drawingData ||
           oldDelegate.currentStroke.length != currentStroke.length;
  }
}