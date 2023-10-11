// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/foundation.dart';

import 'persistence/settings_persistence.dart';

/// An class that holds settings like [playerName] or [musicOn],
/// and saves them to an injected persistence store.
class SettingsController {
  final SettingsPersistence _persistence;

  /// Whether or not the sound is on at all. This overrides both music
  /// and sound.
  ValueNotifier<bool> muted = ValueNotifier(false);

  ValueNotifier<String> player1Name = ValueNotifier('Player1');

  ValueNotifier<String> player2Name = ValueNotifier('Player2');

  ValueNotifier<bool> soundsOn = ValueNotifier(false);

  ValueNotifier<bool> musicOn = ValueNotifier(false);

  /// Creates a new instance of [SettingsController] backed by [persistence].
  SettingsController({required SettingsPersistence persistence})
      : _persistence = persistence;

  /// Asynchronously loads values from the injected persistence store.
  Future<void> loadStateFromPersistence() async {
    await Future.wait([
      _persistence
          // On the web, sound can only start after user interaction, so
          // we start muted there.
          // On any other platform, we start unmuted.
          .getMuted(defaultValue: kIsWeb)
          .then((value) => muted.value = value),
      _persistence.getSoundsOn().then((value) => soundsOn.value = value),
      _persistence.getMusicOn().then((value) => musicOn.value = value),
      _persistence.getPlayer1Name().then((value) => player1Name.value = value),
      _persistence.getPlayer2Name().then((value) => player2Name.value = value)
    ]);
  }

  void setPlayer1Name(String name) {
    player1Name.value = name;
    _persistence.savePlayer1Name(player1Name.value);
  }

  void setPlayer2Name(String name) {
    player2Name.value = name;
    _persistence.savePlayer2Name(player2Name.value);
  }

  void toggleMusicOn() {
    musicOn.value = !musicOn.value;
    _persistence.saveMusicOn(musicOn.value);
  }

  void toggleMuted() {
    muted.value = !muted.value;
    _persistence.saveMuted(muted.value);
  }

  void toggleSoundsOn() {
    soundsOn.value = !soundsOn.value;
    _persistence.saveSoundsOn(soundsOn.value);
  }
}
