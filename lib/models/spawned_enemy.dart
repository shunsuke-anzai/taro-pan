import 'package:flutter/material.dart';
import 'enemy.dart';

class SpawnedEnemy {
  final Enemy enemy;
  double x;
  final double y;
  final DateTime spawnTime;
  final AnimationController animationController;
  final Animation<double> moveAnimation;
  final Animation<double> scaleAnimation;

  SpawnedEnemy({
    required this.enemy,
    required this.x,
    required this.y,
    required this.spawnTime,
    required this.animationController,
    required this.moveAnimation,
    required this.scaleAnimation,
  });

  void dispose() {
    animationController.dispose();
  }

  void updatePosition(double deltaTime) {
    // 左に向かって移動
    x -= enemy.speed * deltaTime;
  }
}
