import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'game/pan_battle_game.dart';

class BattleScreen extends StatelessWidget {
  const BattleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameWidget<PanBattleGame>.controlled(
        gameFactory: () => PanBattleGame(
          onGameEnd: () {
            Navigator.pop(context);
          },
        ),
      ),
    );
  }
}
