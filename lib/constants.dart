import 'package:flutter/material.dart';

enum GameBoxAnimStatus {
  initial,
  flip,
  waitingToMatch,
  matched,
  unMatched,
  gameOver
}

/* flip tweens */
final flipTween = Tween(begin: 1.0, end: 2.0);

/* waiting to match tweens */
final waitingToMatchColorTweenSequence = TweenSequence([
  TweenSequenceItem(
      tween: ColorTween(begin: Colors.deepOrange, end: Colors.orange),
      weight: 1),
  TweenSequenceItem(
      tween: ColorTween(begin: Colors.orange, end: Colors.deepOrange),
      weight: 1),
]);

final waitingToMatchScaleTweenSequence = TweenSequence([
  TweenSequenceItem(tween: Tween(begin: 1.1, end: 0.9), weight: 1),
  TweenSequenceItem(tween: Tween(begin: 0.9, end: 1.1), weight: 1),
]);

/* matched tweens */
final matchedColorTweenSequence = TweenSequence([
  TweenSequenceItem(
      tween: ColorTween(begin: Colors.green[800], end: Colors.green[300]),
      weight: 1),
  TweenSequenceItem(
      tween: ColorTween(begin: Colors.green[300], end: Colors.green[800]),
      weight: 1),
  TweenSequenceItem(
      tween: ColorTween(begin: Colors.green[800], end: Colors.green[300]),
      weight: 1),
  TweenSequenceItem(
      tween: ColorTween(begin: Colors.green[300], end: Colors.green[800]),
      weight: 1),
]);

final matchedScaleTweenSequence = TweenSequence([
  TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.8), weight: 1),
  TweenSequenceItem(tween: Tween(begin: 0.8, end: 1.2), weight: 1),
  TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0), weight: 1),
  TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.8), weight: 1),
  TweenSequenceItem(tween: Tween(begin: 0.8, end: 1.2), weight: 1),
  TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0), weight: 1),
]);

/* unmatched tweens */
final unMatchedFlipTween = Tween(begin: 2.0, end: 1.0);

final unMatchedColorTweenSequence = TweenSequence([
  TweenSequenceItem(
      tween: ColorTween(begin: Colors.red[300], end: Colors.red[800]),
      weight: 1),
  TweenSequenceItem(
      tween: ColorTween(begin: Colors.red[800], end: Colors.red[300]),
      weight: 1),
  TweenSequenceItem(
      tween: ColorTween(begin: Colors.red[300], end: Colors.red[800]),
      weight: 1),
  TweenSequenceItem(
      tween: ColorTween(begin: Colors.red[800], end: Colors.red[300]),
      weight: 1),
]);

/* initial tweens */
final initialColorTweenSequence = TweenSequence([
  TweenSequenceItem(
      tween: ColorTween(begin: Colors.blue, end: Colors.blue[800]), weight: 1),
  TweenSequenceItem(
      tween: ColorTween(begin: Colors.blue[800], end: Colors.blue), weight: 1),
]);

/* game over tweens */
final gameOverOpacityTweenSequence = TweenSequence([
  TweenSequenceItem(
    tween: Tween(begin: 1.0, end: 0.2),
    weight: 1,
  ),
  TweenSequenceItem(
    tween: Tween(begin: 0.2, end: 1.0),
    weight: 1,
  ),
]);

/* hint tweens */
final hintTweenSequence = TweenSequence([
  TweenSequenceItem(
    tween: ColorTween(begin: Colors.deepOrange, end: Colors.yellow),
    weight: 1,
  ),
  TweenSequenceItem(
    tween: ColorTween(begin: Colors.yellow, end: Colors.deepOrange),
    weight: 1,
  ),
]);

/* Anim durations */
const initialAnimDuration = Duration(milliseconds: 1500);
const flipAnimDuration = Duration(milliseconds: 400);
const waitingToMatchAnimDuration = Duration(milliseconds: 1000);
const unMatchedAnimDuration = Duration(milliseconds: 500);
const matchedAnimDuration = Duration(milliseconds: 1500);
const gameOverAnimDuration = Duration(milliseconds: 1000);

/* Scores */
const int forHintedBoxesPoint = 5;
const int normalPoint = 10;

const int initialHintCount = 5;
