// 8*8 grid bool provider

import 'package:flutter/material.dart';
import 'package:game_template/src/play_session/grid_constants.dart';

class Grid extends ChangeNotifier {
  final List<List<bool>> _grid1= List.generate(grid_size+1, (_) => List.filled(grid_size, false));
  final List<List<bool>> _grid2 = List.generate(grid_size, (_) => List.filled(grid_size+1, false));
  final List<List<int>> _gridCount = List.generate(grid_size, (index) => List.filled(grid_size, 0));
  bool getStick1(int x, int y) => _grid1[x][y];
  bool getStick2(int x, int y) => _grid2[x][y];


  void setDot1(int x, int y, bool value) {
    _grid1[x][y] = value;
    notifyListeners();
  }

  void setDot2(int x, int y, bool value) {
    _grid2[x][y] = value;
    notifyListeners();
  }


  int getGridCount(int x, int y) => _gridCount[x][y];

  void reset1() {
    for (var x = 0; x < grid_size+1; x++) {
      for (var y = 0; y < grid_size; y++) {
        _grid1[x][y] = false;
      }
    }
    notifyListeners();
  }
  void reset2() {
    for (var x = 0; x < grid_size; x++) {
      for (var y = 0; y < grid_size+1; y++) {
        _grid2[x][y] = false;
      }
    }
    notifyListeners();
  }
}