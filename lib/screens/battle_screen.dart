import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flame/game.dart';
import '../game/pan_battle_game.dart';

class BattleScreen extends StatefulWidget {
  const BattleScreen({super.key});

  @override
  State<BattleScreen> createState() => _BattleScreenState();
}

class _BattleScreenState extends State<BattleScreen> {
  late PanBattleGame game;

  @override
  void initState() {
    super.initState();
    
    // 画面方向を横向きに固定
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    
    game = PanBattleGame(
      onGameEnd: () {
        // ゲーム終了時にホーム画面に戻る（BGMは継続）
        Navigator.of(context).pop();
      },
    );
    // 戦闘画面でも同じBGMを継続（特別な処理不要）
  }

  @override
  void dispose() {
    // BGMサービスは戦闘画面を出るときも継続
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('パン屋の戦い'),
        backgroundColor: Colors.brown.shade300,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // BGMは継続のまま戻る
            Navigator.pop(context);
          },
        ),
      ),
      body: GameWidget<PanBattleGame>.controlled(
        gameFactory: () => game,
      ),
    );
  }
}
