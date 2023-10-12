// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:game_template/src/play_session/grid_constants.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart' hide Level;
import 'package:provider/provider.dart';

import '../ads/ads_controller.dart';
import '../audio/audio_controller.dart';
import '../audio/sounds.dart';
import '../games_services/games_services.dart';
import '../games_services/score.dart';
import '../in_app_purchase/in_app_purchase.dart';
import '../level_selection/levels.dart';
import '../player_progress/player_progress.dart';
import '../style/confetti.dart';
import '../style/palette.dart';
import 'grid_provider.dart';

class PlaySessionScreen extends StatefulWidget {
  const PlaySessionScreen({super.key});

  @override
  State<PlaySessionScreen> createState() => _PlaySessionScreenState();
}

class _PlaySessionScreenState extends State<PlaySessionScreen> {
  static final _log = Logger('PlaySessionScreen');

  static const _celebrationDuration = Duration(milliseconds: 2000);

  static const _preCelebrationDuration = Duration(milliseconds: 500);

  bool _duringCelebration = false;

  late DateTime _startOfPlay;

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<Palette>();

    return IgnorePointer(
      ignoring: _duringCelebration,
      child: Scaffold(
        backgroundColor: palette.backgroundPlaySession,
        body: Stack(
          children: [
            Center(
              // This is the entirety of the "game".
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: InkResponse(
                      onTap: () => GoRouter.of(context).push('/settings'),
                      child: Image.asset(
                        'assets/images/settings.png',
                        semanticLabel: 'Settings',
                      ),
                    ),
                  ),
                  const Spacer(),
                  GameGrid(),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () => GoRouter.of(context).go('/play'),
                        child: const Text('Back'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox.expand(
              child: Visibility(
                visible: _duringCelebration,
                child: IgnorePointer(
                  child: Confetti(
                    isStopped: !_duringCelebration,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    _startOfPlay = DateTime.now();

    // Preload ad for the win screen.
    final adsRemoved =
        context.read<InAppPurchaseController?>()?.adRemoval.active ?? false;
    if (!adsRemoved) {
      final adsController = context.read<AdsController?>();
      adsController?.preloadAd();
    }
  }

  Future<void> _playerWon() async {
    // _log.info('Level ${widget.level.number} won');

    // final score = Score(
    //   // widget.level.number,
    //   // widget.level.difficulty,
    //   DateTime.now().difference(_startOfPlay),
    // );

    final playerProgress = context.read<PlayerProgress>();
    // playerProgress.setLevelReached(widget.level.number);

    // Let the player see the game just after winning for a bit.
    await Future<void>.delayed(_preCelebrationDuration);
    if (!mounted) return;

    setState(() {
      _duringCelebration = true;
    });

    final audioController = context.read<AudioController>();
    audioController.playSfx(SfxType.congrats);

    final gamesServicesController = context.read<GamesServicesController?>();
    if (gamesServicesController != null) {
      // Award achievement.
      // if (widget.level.awardsAchievement) {
      //   await gamesServicesController.awardAchievement(
      //     android: widget.level.achievementIdAndroid!,
      //     iOS: widget.level.achievementIdIOS!,
      //   );
      // }

      // Send score to leaderboard.
      // await gamesServicesController.submitLeaderboardScore(score);
    }

    /// Give the player some time to see the celebration animation.
    await Future<void>.delayed(_celebrationDuration);
    if (!mounted) return;

    // GoRouter.of(context).go('/play/won', extra: {'score': score});
  }
}

class GameGrid extends StatefulWidget {
  const GameGrid({super.key});

  @override
  State<GameGrid> createState() => _GameGridState();
}

class _GameGridState extends State<GameGrid> {
  late List<List<int>> gridColor;

  @override
  void initState() {
    // TODO: implement initState
    List<int> temp = List.filled(5, 0);
    gridColor = List.filled(5, temp);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final grid_provider = context.watch<Grid>();
    return Center(
      child: Column(
        children: [
          // dot and Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              dot(),
              ...List.generate(
                  grid_size,
                  (y) => Row(
                        children: [
                          InkWell(
                            onTap:(){
                              grid_provider.setDot1(0, y, true);
                            },
                              child: horizontalBar(grid_provider.getStick1(0, y)),
                          ),
                          dot(),
                        ],
                      )),
            ],
          ),
          ...List.generate(grid_size, (x) {
            return Column(
              children: [
                // bar and box
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                        onTap: () {
                          grid_provider.setDot2(x, 0, true);
                        },
                        child: verticalBar(grid_provider.getStick2(x, 0))),
                    ...List.generate(
                        grid_size,
                        (y) => Row(
                              children: [
                                box(Colors.red),
                                InkWell(
                                  onTap: () {
                                    grid_provider.setDot2(x, y+1, true);
                                  },
                                  child: verticalBar(grid_provider.getStick2(x, y+1)),
                                ),
                              ],
                            )),
                  ],
                ),
                // dot and bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    dot(),
                    ...List.generate(
                        grid_size,
                        (y) => Row(
                              children: [
                                InkWell(onTap: () {
                                  grid_provider.setDot1(x+1, y, true);
                                  // gridColor[][],
                                }, child: horizontalBar(grid_provider.getStick1(x+1, y))),
                                dot(),
                              ],
                            )),
                  ],
                ),
              ],
            );
          })
        ],
      ),
    );
  }
}

Widget horizontalBar(bool visible) {
  return Container(
    height: dot_size,
    width: bar_size,
    decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: visible ? Colors.blue : Colors.transparent ,
        shape: BoxShape.rectangle),
  );
}

Widget verticalBar(bool visible) {
  return Container(
    height: bar_size,
    width: dot_size,
    decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: visible ? Colors.blue : Colors.transparent ,
        shape: BoxShape.rectangle),
  );
}

Widget dot() {
  return Container(
    width: dot_size,
    height: dot_size,
    decoration: BoxDecoration(color: Colors.black, shape: BoxShape.circle),
  );
}

Widget box(Color color) {
  return Container(
    width: bar_size,
    height: bar_size,
    decoration: BoxDecoration(color: color, shape: BoxShape.rectangle),
  );
}
