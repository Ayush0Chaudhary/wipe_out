// 8*8 grid bool provider

import 'package:flutter/material.dart';
import 'package:game_template/src/play_session/grid_constants.dart';

class Grid extends ChangeNotifier {
  final List<List<bool>> _grid = List.generate(8, (_) => List.filled(grid_size, false));

  bool getDot(int x, int y) => _grid[x][y];

  void setDot(int x, int y, bool value) {
    _grid[x][y] = value;
    notifyListeners();
  }

  void reset() {
    for (var x = 0; x < grid_size; x++) {
      for (var y = 0; y < grid_size; y++) {
        _grid[x][y] = false;
      }
    }
    notifyListeners();
  }
}