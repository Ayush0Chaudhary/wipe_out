// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:game_template/src/game_internals/not_very_silly_game_state.dart';
import 'package:game_template/src/play_session/grid_constants.dart';
import 'package:game_template/src/settings/settings.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart' hide Level;
import 'package:provider/provider.dart';

import '../ads/ads_controller.dart';
import '../audio/audio_controller.dart';
import '../audio/sounds.dart';
import '../games_services/games_services.dart';
import '../in_app_purchase/in_app_purchase.dart';
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

  static const _celebrationDuration = Duration(milliseconds: 3000);

  static const _preCelebrationDuration = Duration(milliseconds: 500);

  bool _duringCelebration = false;

  late DateTime _startOfPlay;

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<Palette>();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (context) => GameState(onWin: _playerWon))
      ],
      child: IgnorePointer(
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
                          child: const Text('Quit'),
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

    GoRouter.of(context).go(
      '/',
    );
  }
}

class GameGrid extends StatefulWidget {
  const GameGrid({super.key});

  @override
  State<GameGrid> createState() => _GameGridState();
}

class _GameGridState extends State<GameGrid> {
  @override
  Widget build(BuildContext context) {
    final gridProvider = context.watch<Grid>();
    final palette = context.watch<Palette>();
    final settings = context.watch<SettingsController>();

    return Consumer<GameState>(builder: (context, gameState, child) {
      return Center(
        child: Column(
          children: [
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      settings.player1Name.value,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Permanent Marker',
                        color: palette.pen,
                        fontSize: 15,
                        height: 1,
                      ),
                    ),
                    Text(
                      settings.player2Name.value,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Permanent Marker',
                        color: palette.redPen,
                        fontSize: 15,
                        height: 1,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      gridProvider.getp1().toString(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Permanent Marker',
                        color: palette.pen,
                        fontSize: 15,
                        height: 1,
                      ),
                    ),
                    Text(
                      gridProvider.getp2().toString(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Permanent Marker',
                        color: palette.redPen,
                        fontSize: 15,
                        height: 1,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(
              height: 60,
            ),
            Text(
              gridProvider.getPlayer()
                  ? "${settings.player1Name.value}'s turn"
                  : "${settings.player2Name.value}'s turn",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Permanent Marker',
                color: gridProvider.getPlayer() ? palette.pen : palette.redPen,
                fontSize: 30,
                height: 1,
              ),
            ),
            SizedBox(
              height: 60,
            ),
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
                              onTap: () {
                                if (!gridProvider.getStick1(0, y)) {
                                  gridProvider.incrementGridCount(0, y);
                                }
                                gridProvider.setDot1(0, y, true);
                                if (gridProvider.getGridCount(0, y) != 4) {
                                  gridProvider.setPlayer();
                                } else {
                                  if (gridProvider.getWinner(0, y) == -1) {
                                    int winner =
                                        gridProvider.getPlayer() ? 1 : 0;
                                    gridProvider.setWinner(0, y, winner);
                                  }
                                }
                                gameState.evaluate(gridProvider.getp1() +
                                    gridProvider.getp2());
                              },
                              child:
                                  horizontalBar(gridProvider.getStick1(0, y)),
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
                            if (gridProvider.getStick2(x, 0)) {
                              return;
                            }
                            gridProvider.setDot2(x, 0, true);
                            gridProvider.incrementGridCount(x, 0);
                            if (gridProvider.getGridCount(x, 0) != 4) {
                              gridProvider.setPlayer();
                            } else {
                              if (gridProvider.getWinner(x, 0) == -1) {
                                int winner = gridProvider.getPlayer() ? 1 : 0;
                                gridProvider.setWinner(x, 0, winner);
                              }
                            }
                            gameState.evaluate(
                                gridProvider.getp1() + gridProvider.getp2());
                          },
                          child: verticalBar(gridProvider.getStick2(x, 0))),
                      ...List.generate(
                          grid_size,
                          (y) => Row(
                                children: [
                                  box(
                                      gridProvider.getWinner(x, y) == 1
                                          ? palette.pen
                                          : palette.redPen,
                                      visible:
                                          gridProvider.getGridCount(x, y) == 4),
                                  InkWell(
                                    onTap: () {
                                      bool scored = false;
                                      int winner =
                                          gridProvider.getPlayer() ? 1 : 0;
                                      if (gridProvider.getStick2(x, y + 1)) {
                                        return;
                                      }
                                      gridProvider.incrementGridCount(x, y);
                                      if (y != grid_size - 1) {
                                        gridProvider.incrementGridCount(
                                            x, y + 1);
                                      }
                                      gridProvider.setDot2(x, y + 1, true);

                                      if (gridProvider.getGridCount(x, y) ==
                                          4) {
                                        if (gridProvider.getWinner(x, y) ==
                                            -1) {
                                          gridProvider.setWinner(x, y, winner);
                                          scored = true;
                                        }
                                      }
                                      if (y != grid_size - 1 &&
                                          gridProvider.getGridCount(x, y + 1) ==
                                              4) {
                                        if (gridProvider.getWinner(x, y + 1) ==
                                            -1) {
                                          gridProvider.setWinner(
                                              x, y + 1, winner);
                                          scored = true;
                                        }
                                      }
                                      if (scored == false) {
                                        gridProvider.setPlayer();
                                      }

                                      gameState.evaluate(gridProvider.getp1() +
                                          gridProvider.getp2());
                                    },
                                    child: verticalBar(
                                        gridProvider.getStick2(x, y + 1)),
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
                                  InkWell(
                                      onTap: () {
                                        /// to keep track of current player in integer form, no bool to int like cpp :(
                                        ///
                                        int winner =
                                            gridProvider.getPlayer() ? 1 : 0;

                                        /// To keep check whether the player scored in current move
                                        ///
                                        bool scored = false;

                                        if (gridProvider.getStick1(x + 1, y)) {
                                          return;
                                        }
                                        gridProvider.incrementGridCount(x, y);
                                        if (x != grid_size - 1) {
                                          gridProvider.incrementGridCount(
                                              x + 1, y);
                                        }

                                        /// Now checking for the block with coordinate {x, y}
                                        ///
                                        /// if eligible for the being part of someone score
                                        if (gridProvider.getGridCount(x, y) ==
                                            4) {
                                          /// checking whether the block is already assigned to someone.
                                          if (gridProvider.getWinner(x, y) ==
                                              -1) {
                                            /// enter here when block not assigned to anyone
                                            ///
                                            /// Now assign the block win to current player
                                            gridProvider.setWinner(
                                                x, y, winner);

                                            /// Telling our code that player have scored
                                            ///
                                            scored = true;
                                          }
                                        }

                                        /// Now checking for the block with coordinate {x+1, y}
                                        ///
                                        /// if the stick even have next block, the adjacent case
                                        if (x != grid_size - 1) {
                                          /// we know now the block exist, pheww!
                                          ///
                                          /// below if statement checks whether
                                          /// the block is eligible to be part of someone score
                                          if (gridProvider.getGridCount(
                                                  x + 1, y) ==
                                              4) {
                                            /// Making sure the {x+1, y} block is not assigned.
                                            ///
                                            if (gridProvider.getWinner(
                                                    x + 1, y) ==
                                                -1) {
                                              /// now assignation of the current block to current player
                                              ///
                                              gridProvider.setWinner(
                                                  x + 1, y, winner);

                                              /// Telling our code that player have scored
                                              ///
                                              scored = true;
                                            }
                                          }
                                        }

                                        /// if the player have scored, he gets another chance, yaay!
                                        ///
                                        if (scored == false) {
                                          gridProvider.setPlayer();
                                        }

                                        /// marking the stick touched :)
                                        gridProvider.setDot1(x + 1, y, true);

                                        /// checking if the game has ended
                                        ///
                                        ///
                                        gameState.evaluate(
                                            gridProvider.getp1() +
                                                gridProvider.getp2());
                                      },
                                      child: horizontalBar(
                                          gridProvider.getStick1(x + 1, y))),
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
    });
  }
}

Widget horizontalBar(bool visible) {
  return Container(
    height: dot_size,
    width: bar_size,
    decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: visible ? Colors.blue : const Color.fromARGB(75, 0, 0, 0),
        shape: BoxShape.rectangle),
  );
}

Widget verticalBar(bool visible) {
  return Container(
    height: bar_size,
    width: dot_size,
    decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: visible ? Colors.blue : const Color.fromARGB(75, 0, 0, 0),
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

Widget box(Color color, {bool visible = false}) {
  return Container(
    width: bar_size,
    height: bar_size,
    decoration: BoxDecoration(
        color: visible ? color : Colors.transparent, shape: BoxShape.rectangle),
  );
}
