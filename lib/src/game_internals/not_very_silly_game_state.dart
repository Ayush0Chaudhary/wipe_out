import 'package:flutter/foundation.dart';

import '../play_session/grid_constants.dart';

/// An extremely silly example of a game state.
///
/// Tracks only a single variable, [progress], and calls [onWin] when
/// total number of boxes acquired reaches grid_size * grid_size
class GameState extends ChangeNotifier {
  final VoidCallback onWin;

  /// setting default value, we dont need it thu
  GameState({required this.onWin});

  void evaluate(int currentTotal) {
    if (currentTotal >= grid_size * grid_size) {
      onWin();
    }
  }
}
