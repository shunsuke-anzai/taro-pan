import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'game/pan_battle_game.dart';

class BattleScreen extends StatelessWidget {
  const BattleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ゲーム本体
          GameWidget<PanBattleGame>.controlled(
            gameFactory: () => PanBattleGame(
              onGameEnd: () {
                Navigator.pop(context);
              },
            ),
          ),
          // 左上に戻るボタン
          Positioned(
            left: 16,
            top: 32,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, size: 32, color: Colors.black),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}
