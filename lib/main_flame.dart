import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'game/pan_battle_game.dart';

void main() {
  runApp(const PanBattleApp());
}

class PanBattleApp extends StatelessWidget {
  const PanBattleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'パン屋の戦い',
      theme: ThemeData(
        primarySwatch: Colors.brown,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: GameWidget<PanBattleGame>.controlled(
        gameFactory: PanBattleGame.new,
      ),
    );
  }
}
