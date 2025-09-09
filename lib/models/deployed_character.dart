import 'package:flutter/material.dart';
import 'character.dart';

class DeployedCharacter {
  final Character character;
  final double x;
  final double y;
  final DateTime deployTime;
  final AnimationController animationController;
  final Animation<double> slideAnimation;
  final Animation<double> scaleAnimation;
  final Animation<double>? bounceAnimation;

  DeployedCharacter({
    required this.character,
    required this.x,
    required this.y,
    required this.deployTime,
    required this.animationController,
    required this.slideAnimation,
    required this.scaleAnimation,
    this.bounceAnimation,
  });

  void dispose() {
    animationController.dispose();
  }
}
