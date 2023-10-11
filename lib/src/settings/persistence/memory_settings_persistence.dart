// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'settings_persistence.dart';

/// An in-memory implementation of [SettingsPersistence].
/// Useful for testing.
class MemoryOnlySettingsPersistence implements SettingsPersistence {
  bool musicOn = true;

  bool soundsOn = true;

  bool muted = false;

  String player1Name = 'Player1';

  String player2Name = 'Player2';

  @override
  Future<bool> getMusicOn() async => musicOn;

  @override
  Future<bool> getMuted({required bool defaultValue}) async => muted;

  @override
  Future<String> getPlayer1Name() async => player1Name;

  @override
  Future<String> getPlayer2Name() async => player2Name;

  @override
  Future<bool> getSoundsOn() async => soundsOn;

  @override
  Future<void> saveMusicOn(bool value) async => musicOn = value;

  @override
  Future<void> saveMuted(bool value) async => muted = value;

  @override
  Future<void> savePlayer1Name(String value) async => player1Name = value;

  @override
  Future<void> savePlayer2Name(String value) async => player2Name = value;

  @override
  Future<void> saveSoundsOn(bool value) async => soundsOn = value;
}
