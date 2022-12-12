import 'package:flutter/material.dart';
import 'package:memory/constants.dart';

class GameBoxModel {
  IconData icon;
  bool open;
  bool enabled;
  bool hint;
  GameBoxAnimStatus animStatus;
  AnimationController animController;

  GameBoxModel(
      {required this.icon,
      this.open = false,
      this.animStatus = GameBoxAnimStatus.initial,
      required this.animController,
      this.hint = false,
      this.enabled = true});
}
