import 'package:flutter/material.dart';
import 'package:memory/helpers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ResultsPage extends StatefulWidget {
  final int score;
  final int totalSeconds;
  final int moveCount;

  const ResultsPage(
      {Key? key,
      required this.score,
      required this.totalSeconds,
      required this.moveCount})
      : super(key: key);

  @override
  State<ResultsPage> createState() => _ResultsPageState();
}

class _ResultsPageState extends State<ResultsPage> {
  static const String bestScoreKey = 'best_score';

  double _bestScore = 0;

  double _totalScore() {
    return widget.score - (widget.moveCount * 0.5 + widget.totalSeconds * 0.1);
  }

  Future<SharedPreferences> _prefs() async {
    return await SharedPreferences.getInstance();
  }

  Future<void> _setBestScore(double bestScore) async {
    final sharedPreferences = await _prefs();

    await sharedPreferences.setDouble(bestScoreKey, bestScore);
  }

  Future<void> _getBestScore() async {
    final sharedPreferences = await _prefs();

    double bs = sharedPreferences.getDouble(bestScoreKey) ?? _totalScore();

    if (bs > _totalScore()) {
      setState(() {
        _bestScore = bs;
      });
    } else {
      setState(() {
        _bestScore = _totalScore();
      });
      _setBestScore(_bestScore);
    }
  }

  IconButton _playAgainButton() {
    return IconButton(
      icon: const Icon(Icons.refresh),
      onPressed: () {
        Navigator.pop(context);
      },
    );
  }

  @override
  void initState() {
    super.initState();

    _getBestScore();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            Text('Score: ${widget.score}'),
            const SizedBox(
              height: 10,
            ),
            Text('Time: ' + timeFormat(widget.totalSeconds)),
            const SizedBox(
              height: 10,
            ),
            Text('Moves: ${widget.moveCount}'),
            const SizedBox(
              height: 10,
            ),
            Text('Total Score: ${_totalScore()}'),
            const SizedBox(
              height: 10,
            ),
            Text('Best Score: $_bestScore'),
            const SizedBox(
              height: 50,
            ),
            _playAgainButton(),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
