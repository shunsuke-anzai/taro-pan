import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'game/pan_battle_game.dart';

class BattleScreen extends StatelessWidget {
  const BattleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('パン屋の戦い'),
        backgroundColor: Colors.brown.shade300,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: GameWidget<PanBattleGame>.controlled(
        gameFactory: PanBattleGame.new,
      ),
    );
  }
}
