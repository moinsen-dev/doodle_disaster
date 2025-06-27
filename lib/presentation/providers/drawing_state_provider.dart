import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/models.dart';

/// State for managing the current drawing operation
class DrawingState {
  final DrawingData? currentDrawing;
  final List<DrawingData> undoStack;
  final bool isSubmitted;
  
  const DrawingState({
    this.currentDrawing,
    this.undoStack = const [],
    this.isSubmitted = false,
  });
  
  DrawingState copyWith({
    DrawingData? currentDrawing,
    List<DrawingData>? undoStack,
    bool? isSubmitted,
  }) {
    return DrawingState(
      currentDrawing: currentDrawing ?? this.currentDrawing,
      undoStack: undoStack ?? this.undoStack,
      isSubmitted: isSubmitted ?? this.isSubmitted,
    );
  }
}

/// Manages drawing operations including undo/redo and submission.
/// 
/// This provider handles:
/// - Current drawing state
/// - Undo/redo operations
/// - Drawing submission
/// - Clearing the canvas
class DrawingStateNotifier extends StateNotifier<DrawingState> {
  DrawingStateNotifier() : super(const DrawingState());
  
  /// Updates the current drawing
  void updateDrawing(DrawingData drawing) {
    // Add previous state to undo stack if it exists and is different
    if (state.currentDrawing != null && 
        state.currentDrawing!.strokes.length < drawing.strokes.length) {
      state = state.copyWith(
        currentDrawing: drawing,
        undoStack: [...state.undoStack, state.currentDrawing!],
      );
    } else {
      state = state.copyWith(currentDrawing: drawing);
    }
  }
  
  /// Undoes the last drawing action
  void undo() {
    if (state.currentDrawing == null) return;
    
    final newDrawing = state.currentDrawing!.removeLastStroke();
    state = state.copyWith(currentDrawing: newDrawing);
  }
  
  /// Clears the entire drawing
  void clear() {
    if (state.currentDrawing == null) return;
    
    // Save current state to undo stack before clearing
    state = state.copyWith(
      currentDrawing: state.currentDrawing!.clear(),
      undoStack: [...state.undoStack, state.currentDrawing!],
    );
  }
  
  /// Restores the previous drawing state from undo stack
  void restore() {
    if (state.undoStack.isEmpty) return;
    
    final undoStack = List<DrawingData>.from(state.undoStack);
    final previousDrawing = undoStack.removeLast();
    
    state = state.copyWith(
      currentDrawing: previousDrawing,
      undoStack: undoStack,
    );
  }
  
  /// Submits the current drawing
  DrawingData? submitDrawing() {
    if (state.currentDrawing == null || 
        state.currentDrawing!.strokes.isEmpty ||
        state.isSubmitted) {
      return null;
    }
    
    state = state.copyWith(isSubmitted: true);
    return state.currentDrawing;
  }
  
  /// Resets the drawing state for a new drawing session
  void reset({double? canvasWidth, double? canvasHeight}) {
    state = DrawingState(
      currentDrawing: canvasWidth != null && canvasHeight != null
          ? DrawingData.empty(canvasWidth, canvasHeight)
          : null,
    );
  }
  
  /// Checks if there are strokes that can be undone
  bool get canUndo => state.currentDrawing?.strokes.isNotEmpty ?? false;
  
  /// Checks if there are strokes that can be cleared
  bool get canClear => state.currentDrawing?.strokes.isNotEmpty ?? false;
  
  /// Checks if the drawing can be submitted
  bool get canSubmit => 
      (state.currentDrawing?.strokes.isNotEmpty ?? false) && !state.isSubmitted;
}

/// Provider for the drawing state
final drawingStateProvider = StateNotifierProvider<DrawingStateNotifier, DrawingState>((ref) {
  return DrawingStateNotifier();
});