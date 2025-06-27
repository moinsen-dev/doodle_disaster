/// This file exports all domain models for easy importing throughout the app.
/// 
/// Instead of writing multiple import statements like:
///   import 'package:doodle_disaster/domain/models/player.dart';
///   import 'package:doodle_disaster/domain/models/drawing_data.dart';
///   import 'package:doodle_disaster/domain/models/chain_link.dart';
/// 
/// You can simply write:
///   import 'package:doodle_disaster/domain/models/models.dart';
/// 
/// This pattern keeps imports clean and makes refactoring easier. If we ever
/// need to reorganize our file structure, we only need to update this one file
/// rather than hunting down imports throughout the entire codebase.
library;

export 'player.dart';
export 'drawing_data.dart';
export 'chain_link.dart';
export 'drawing_chain.dart';
export 'game_session.dart';
export 'game_settings.dart';
export 'player_action.dart';
