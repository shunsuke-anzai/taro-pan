import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'game/pan_battle_game.dart';
//import 'package:taro_pan/home.dart';
import 'package:flutter/services.dart';
import 'splash.dart';
// ...existing code...

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  runApp(const MaterialApp(home: SplashScreen()));
}

class PanBattleApp extends StatelessWidget {
  const PanBattleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'パン屋の戦い',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.brown,
        ),
        // visualDensity: VisualDensity.adaptivePlatformDensity, // 削除
      ),
      home: GameWidget<PanBattleGame>.controlled(
        gameFactory: PanBattleGame.new,
      ),
    );
  }
}