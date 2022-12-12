import 'package:flutter/material.dart';
import 'constants.dart';
import 'models/game_box_model.dart';

Animation initialColorAnim(GameBoxModel gameBoxModel) =>
    initialColorTweenSequence.animate(gameBoxModel.animController);

Animation flipAnim(GameBoxModel gameBoxModel) =>
    flipTween.animate(CurvedAnimation(
        parent: gameBoxModel.animController, curve: Curves.bounceInOut));

Animation waitingToMatchColorAnim(GameBoxModel gameBoxModel) =>
    waitingToMatchColorTweenSequence.animate(CurvedAnimation(
        parent: gameBoxModel.animController, curve: Curves.easeInCubic));

Animation waitingToMatchScaleAnim(GameBoxModel gameBoxModel) =>
    waitingToMatchScaleTweenSequence.animate(CurvedAnimation(
        parent: gameBoxModel.animController, curve: Curves.easeInCubic));

Animation unMatchedFlipAnim(GameBoxModel gameBoxModel) =>
    unMatchedFlipTween.animate(CurvedAnimation(
        parent: gameBoxModel.animController, curve: const Interval(0.5, 1.0)));

Animation unMatchedColorAnim(GameBoxModel gameBoxModel) =>
    unMatchedColorTweenSequence.animate(gameBoxModel.animController);

Animation matchedColorAnim(GameBoxModel gameBoxModel) =>
    matchedColorTweenSequence.animate(CurvedAnimation(
        parent: gameBoxModel.animController, curve: Curves.easeInCubic));

Animation matchedScaleAnim(GameBoxModel gameBoxModel) =>
    matchedScaleTweenSequence.animate(CurvedAnimation(
        parent: gameBoxModel.animController, curve: Curves.bounceInOut));

Animation gameOverOpacityAnim(GameBoxModel gameBoxModel) =>
    gameOverOpacityTweenSequence.animate(CurvedAnimation(
        parent: gameBoxModel.animController, curve: Curves.bounceInOut));

Animation hintAnim(GameBoxModel gameBoxModel) => hintTweenSequence.animate(
    CurvedAnimation(parent: gameBoxModel.animController, curve: Curves.ease));
