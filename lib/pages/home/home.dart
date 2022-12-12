import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:memory/constants.dart';
import 'package:memory/models/game_box_model.dart';
import 'package:memory/pages/home/components/game_box.dart';
import 'package:memory/pages/home/components/hint_button.dart';
import 'package:memory/pages/results/results_page.dart';
import 'dart:math' as math;
import 'dart:async';
import 'package:flutter/foundation.dart';

import '../../box_animations.dart';
import '../../helpers.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final gameIcons = const [
    Icons.add_alert,
    Icons.adb,
    Icons.airplanemode_active,
    Icons.all_inclusive,
    Icons.anchor,
    Icons.attach_money,
    Icons.attachment,
    Icons.audiotrack,
    Icons.account_balance,
    Icons.bluetooth,
    Icons.camera,
    Icons.child_care,
    Icons.family_restroom,
    Icons.fitness_center,
    Icons.hardware
  ];

  final boxRowCount = 6;
  final boxColumnCount = 5;

  final _gameBoxModelMatrix = <List<GameBoxModel>>[];
  final _openedCouple = <GameBoxModel>[];

  final AudioCache audioCache = AudioCache(prefix: 'audios/');

  late final Timer _timer;

  final ValueNotifier<int> _elapsedTime = ValueNotifier<int>(0);

  int _score = 0;
  int _moveCount = 0;
  int _hintCount = initialHintCount;

  String? localAudioCacheURI;

  /*
  ** Initialize game box model matrix
  ** with random icons
  */
  void _initGameBoxModels() {
    final randomIndexes =
        List.generate(gameIcons.length * 2, (index) => index ~/ 2)..shuffle();

    int counter = -1;

    for (int r = 0; r < boxRowCount; r++) {
      _gameBoxModelMatrix.add([]);

      for (int c = 0; c < boxColumnCount; c++) {
        counter++;

        final gameBoxModel = GameBoxModel(
            icon: gameIcons[randomIndexes[counter]],
            animController: AnimationController(
                vsync: this, duration: initialAnimDuration));

        _gameBoxModelMatrix[r].add(gameBoxModel);

        gameBoxModel.animController.repeat();

        // Add listeners to game boxes animation controllers
        gameBoxModel.animController.addListener(() =>
            _gameBoxAnimListen(gameBoxModel.animController, gameBoxModel));
      }
    }
  }

  /*
  ** Change game box animation status and duration and play.HomePage
  */
  void _changeBoxAnim(GameBoxModel gameBoxModel, GameBoxAnimStatus status,
      Duration duration, bool repeat) {
    gameBoxModel.animStatus = status;
    gameBoxModel.animController.duration = duration;

    gameBoxModel.animController.reset();

    if (repeat) {
      gameBoxModel.animController.repeat();
    } else {
      gameBoxModel.animController.forward(from: 0);
    }
  }

  /*
  ** Do when tapped boxes don't match
  */
  void _onUnMatched() {
    // Hide icons
    _openedCouple[0].open = false;
    _openedCouple[1].open = false;

    // Box animation: unMatched
    _changeBoxAnim(_openedCouple[0], GameBoxAnimStatus.unMatched,
        unMatchedAnimDuration, false);
    _changeBoxAnim(_openedCouple[1], GameBoxAnimStatus.unMatched,
        unMatchedAnimDuration, false);

    // Play unmatched sound
    _playUnMatchedSound();

    // If there are hints then clear them
    for (var gameBoxes in _gameBoxModelMatrix) {
      for (var box in gameBoxes) {
        setState(() {
          box.hint = false;
        });
      }
    }
  }

  /*
  ** Do when tapped boxes match
  */
  void _onMatched() {
    // Box animation: matched
    _changeBoxAnim(_openedCouple[0], GameBoxAnimStatus.matched,
        matchedAnimDuration, false);
    _changeBoxAnim(_openedCouple[1], GameBoxAnimStatus.matched,
        matchedAnimDuration, false);

    // Enable all game boxes (they were disabled when tapped)
    _enableAllGameBoxes();

    // Play matched sound
    _playMatchedSound();

    // Increase score according to boxes hinted status
    setState(() {
      if (_openedCouple[0].hint || _openedCouple[1].hint) {
        _score += forHintedBoxesPoint;
      } else {
        _score += normalPoint;
      }

      _openedCouple.clear();
    });
  }

  void _checkMatches() {
    // Unmatched
    if (_openedCouple[0].icon != _openedCouple[1].icon) {
      _onUnMatched();
    }
    // Matched
    else {
      _onMatched();
    }
  }

  /*
  ** When box flip anim ends if one box is open
  ** turn its animation to waitingToMatch
  ** if two box is open check match situation, increase move count
  */
  void _whenBoxFlipAnimEnd(
      AnimationController controller, GameBoxModel gameBoxModel) {
    if (controller.isCompleted &&
        gameBoxModel.animStatus == GameBoxAnimStatus.flip) {
      if (_openedCouple.length == 1) {
        _changeBoxAnim(gameBoxModel, GameBoxAnimStatus.waitingToMatch,
            waitingToMatchAnimDuration, true);
      } else if (_openedCouple.length == 2 &&
          _openedCouple[1].animController.isCompleted &&
          _openedCouple[1].animStatus == GameBoxAnimStatus.flip) {
        setState(() {
          _moveCount++;
        });
        _checkMatches();
      }
    }
  }

  /*
  ** When unmatched animation ends turn opened couple boxes animation
  ** status to initial and enable all game boxes
  */
  void _whenBoxUnMatchedAnimEnd(
      AnimationController controller, GameBoxModel gameBoxModel) {
    if (controller.isCompleted &&
        _openedCouple.length == 2 &&
        gameBoxModel.animStatus == GameBoxAnimStatus.unMatched) {
      // Turn opened couple boxes animation status to initial
      _changeBoxAnim(_openedCouple[0], GameBoxAnimStatus.initial,
          initialAnimDuration, true);
      _changeBoxAnim(_openedCouple[1], GameBoxAnimStatus.initial,
          initialAnimDuration, true);

      // For sync
      for (var gameBoxes in _gameBoxModelMatrix) {
        for (var box in gameBoxes) {
          if (box.animStatus == GameBoxAnimStatus.initial) {
            box.animController.reset();
            box.animController.repeat();
          }
        }
      }

      _openedCouple.clear();
      _enableAllGameBoxes();
    }
  }

  void _gameBoxAnimListen(
      AnimationController controller, GameBoxModel gameBoxModel) {
    _whenBoxFlipAnimEnd(controller, gameBoxModel);
    _whenBoxUnMatchedAnimEnd(controller, gameBoxModel);
  }

  double _gameArenaSize() {
    if (MediaQuery.of(context).size.width > 320) {
      return 320;
    }

    return MediaQuery.of(context).size.width;
  }

  /*
  ** Build animated game box with AnimatedBuilder widget.
  */
  Widget _buildAnimatedGameBox(GameBoxModel gameBox) {
    return AnimatedBuilder(
        animation: gameBox.animController,
        builder: (context, child) {
          switch (gameBox.animStatus) {
            case GameBoxAnimStatus.initial:
              return GameBox(
                onTap: () {
                  if (gameBox.enabled) {
                    _onTapGameBox(gameBox);
                  }
                },
                borderColor:
                    !gameBox.hint ? Colors.white : hintAnim(gameBox).value,
                backgroundColor: initialColorAnim(gameBox).value,
                icon: gameBox.icon,
                open: gameBox.open,
              );
            case GameBoxAnimStatus.flip:
              return Transform(
                alignment: Alignment.center,
                transform: Matrix4.rotationY(flipAnim(gameBox).value * math.pi),
                child: GameBox(
                  onTap: () {
                    if (gameBox.enabled) {
                      _onTapGameBox(gameBox);
                    }
                  },
                  icon: gameBox.icon,
                  open: gameBox.open,
                ),
              );
            case GameBoxAnimStatus.waitingToMatch:
              return Transform.scale(
                scale: waitingToMatchScaleAnim(gameBox).value,
                child: GameBox(
                  onTap: () {
                    if (gameBox.enabled) {
                      _onTapGameBox(gameBox);
                    }
                  },
                  backgroundColor: waitingToMatchColorAnim(gameBox).value,
                  icon: gameBox.icon,
                  open: gameBox.open,
                ),
              );
            case GameBoxAnimStatus.matched:
              return Transform.scale(
                scale: matchedScaleAnim(gameBox).value,
                child: GameBox(
                  onTap: () {
                    if (gameBox.enabled) {
                      _onTapGameBox(gameBox);
                    }
                  },
                  backgroundColor: matchedColorAnim(gameBox).value,
                  icon: gameBox.icon,
                  open: gameBox.open,
                ),
              );
            case GameBoxAnimStatus.unMatched:
              return Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.rotationY(
                      unMatchedFlipAnim(gameBox).value * math.pi),
                  child: GameBox(
                    onTap: () {
                      if (gameBox.enabled) {
                        _onTapGameBox(gameBox);
                      }
                    },
                    backgroundColor: unMatchedColorAnim(gameBox).value,
                    icon: gameBox.icon,
                    open: gameBox.open,
                  ));
            case GameBoxAnimStatus.gameOver:
              return Opacity(
                opacity: gameOverOpacityAnim(gameBox).value,
                child: GameBox(
                  onTap: () {
                    if (gameBox.enabled) {
                      _onTapGameBox(gameBox);
                    }
                  },
                  backgroundColor: matchedColorAnim(gameBox).value,
                  icon: gameBox.icon,
                  open: gameBox.open,
                ),
              );
          }
        });
  }

  /*
  ** Build game boxes
  */
  Column _buildGameArena() {
    return Column(
      children: List.generate(
          _gameBoxModelMatrix.length,
          (r) => Expanded(
                child: Row(
                    children: List.generate(_gameBoxModelMatrix[r].length, (c) {
                  final gameBoxModel = _gameBoxModelMatrix[r][c];

                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: _buildAnimatedGameBox(gameBoxModel),
                    ),
                  );
                })),
              )),
    );
  }

  /*
  ** When tapped the game box
  */
  void _onTapGameBox(GameBoxModel gameBoxModel) {
    setState(() {
      // Can't tap if the box is open
      if (!gameBoxModel.open) {
        // Play flip anim
        _changeBoxAnim(
            gameBoxModel, GameBoxAnimStatus.flip, flipAnimDuration, false);
        gameBoxModel.open = true;
        // Add the opened box to the opened couple list
        _openedCouple.add(gameBoxModel);
        // Play flip sound
        _playFlipSound();
        // If there are two opened boxes then disable all game boxes
        if (_openedCouple.length == 2) {
          _disableAllGameBoxes();
        }
      }

      // Check wheter game over
      _gameOverControl();
    });
  }

  /*
  ** When tapped hint button
  */
  void _onTapHintButton() {
    // If there is no opened box
    if (_openedCouple.isEmpty) {
      var icons = [];

      // Add all closed boxes icons to icons list
      for (var gameBoxes in _gameBoxModelMatrix) {
        for (var box in gameBoxes) {
          if (!box.open) {
            icons.add(box.icon);
          }
        }
      }

      // Randomize
      icons.shuffle();
      // Random icon from icons list
      final randomIcon = icons[0];

      // Show hints
      for (var gameBoxes in _gameBoxModelMatrix) {
        for (var box in gameBoxes) {
          if (!box.open) {
            setState(() {
              if (box.icon == randomIcon) {
                box.hint = true;
              } else {
                box.hint = false;
              }
            });
          }
        }
      }

      // Decrease hint count
      setState(() {
        _hintCount--;
      });
    }
  }

  /*
  ** Check game over and show results page
  */
  void _gameOverControl() {
    // If all game boxes are open then change their animation status to gameOver
    final gameOver = _gameBoxModelMatrix
        .every((gameBoxes) => gameBoxes.every((box) => box.open));

    if (gameOver) {
      for (var gameBoxes in _gameBoxModelMatrix) {
        for (var box in gameBoxes) {
          _changeBoxAnim(
              box, GameBoxAnimStatus.gameOver, gameOverAnimDuration, true);
        }
      }

      _showResultsPage();
    }
  }

  void _disableAllGameBoxes() {
    setState(() {
      for (var gameBoxes in _gameBoxModelMatrix) {
        for (var box in gameBoxes) {
          box.enabled = false;
        }
      }
    });
  }

  void _enableAllGameBoxes() {
    setState(() {
      for (var gameBoxes in _gameBoxModelMatrix) {
        for (var box in gameBoxes) {
          box.enabled = true;
        }
      }
    });
  }

  void _resetGame() {
    setState(() {
      for (var gameBoxes in _gameBoxModelMatrix) {
        for (var box in gameBoxes) {
          box.enabled = true;
          box.open = false;
          box.hint = false;

          _changeBoxAnim(
              box, GameBoxAnimStatus.initial, initialAnimDuration, true);
        }
      }

      _openedCouple.clear();
      _score = 0;
      _moveCount = 0;
      _elapsedTime.value = 0;
      _hintCount = initialHintCount;
    });
  }

  /*
  ** Show results page. When user returns to home page
  ** Reset game.
  */
  Future<void> _showResultsPage() async {
    await Future.delayed(const Duration(milliseconds: 1300));
    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ResultsPage(
                score: _score,
                totalSeconds: _elapsedTime.value,
                moveCount: _moveCount)));
    _resetGame();
  }

  /*
  ** If platform is Android play sound
  */
  Future<void> _playSound(String path) async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final file = await audioCache.loadAsFile(path);
      final bytes = await file.readAsBytes();

      audioCache.playBytes(bytes);
    }
  }

  void _playFlipSound() {
    _playSound('flip.mp3');
  }

  void _playMatchedSound() {
    _playSound('matched.mp3');
  }

  void _playUnMatchedSound() {
    _playSound('unmatched.mp3');
  }

  @override
  void initState() {
    _initGameBoxModels();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _elapsedTime.value++;
    });

    super.initState();
  }

  @override
  void dispose() {
    // Dispose all game box animation controllers
    for (var gameBoxes in _gameBoxModelMatrix) {
      for (var box in gameBoxes) {
        box.animController.dispose();
      }
    }

    _timer.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Memory Game',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text('SCORE: $_score'),
                ],
              ),
            ),
            Center(
              child: SizedBox(
                  width: _gameArenaSize(),
                  height: _gameArenaSize(),
                  child: _buildGameArena()),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ValueListenableBuilder(
                      valueListenable: _elapsedTime,
                      builder:
                          (BuildContext context, int value, Widget? child) {
                        return Text('Passing Time: ${timeFormat(value)}');
                      }),
                  const SizedBox(height: 10),
                  Text('Moves: $_moveCount'),
                  if (_hintCount > 0) const SizedBox(height: 10),
                  if (_hintCount > 0)
                    HintButton(
                      hintCount: _hintCount,
                      onTap: _onTapHintButton,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
