import 'package:flutter/material.dart';
import '../../domain/models/models.dart';
import 'drawing_canvas.dart';

/// A widget that displays a drawing in read-only mode with auto-scaling.
/// 
/// This is used when players need to view drawings but not edit them,
/// such as during the guessing phase or in the reveal screen.
/// The drawing automatically scales to fit within the available space
/// while maintaining its aspect ratio.
class DrawingPreview extends StatelessWidget {
  /// The drawing data to display
  final DrawingData? drawingData;
  
  /// Background color of the preview area
  final Color backgroundColor;
  
  /// Whether to show a border around the preview
  final bool showBorder;
  
  /// Padding around the drawing
  final EdgeInsets padding;

  const DrawingPreview({
    super.key,
    required this.drawingData,
    this.backgroundColor = Colors.white,
    this.showBorder = true,
    this.padding = const EdgeInsets.all(8.0),
  });

  @override
  Widget build(BuildContext context) {
    if (drawingData == null) {
      return Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          border: showBorder
              ? Border.all(
                  color: Theme.of(context).colorScheme.outline,
                  width: 2,
                )
              : null,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            'No drawing yet',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate the aspect ratio of the original drawing
        final originalAspectRatio = drawingData!.canvasWidth / drawingData!.canvasHeight;
        
        // Calculate the maximum size that fits within constraints while maintaining aspect ratio
        double previewWidth = constraints.maxWidth;
        double previewHeight = constraints.maxHeight;
        
        if (previewWidth / previewHeight > originalAspectRatio) {
          // Container is wider than the drawing aspect ratio
          previewWidth = previewHeight * originalAspectRatio;
        } else {
          // Container is taller than the drawing aspect ratio
          previewHeight = previewWidth / originalAspectRatio;
        }
        
        return Container(
          width: previewWidth,
          height: previewHeight,
          decoration: BoxDecoration(
            color: backgroundColor,
            border: showBorder
                ? Border.all(
                    color: Theme.of(context).colorScheme.outline,
                    width: 2,
                  )
                : null,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: padding,
            child: FittedBox(
              fit: BoxFit.contain,
              child: SizedBox(
                width: drawingData!.canvasWidth,
                height: drawingData!.canvasHeight,
                child: CustomPaint(
                  painter: DrawingPainter(
                    drawingData: drawingData!,
                    currentStroke: const [],
                  ),
                  size: Size(
                    drawingData!.canvasWidth,
                    drawingData!.canvasHeight,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}