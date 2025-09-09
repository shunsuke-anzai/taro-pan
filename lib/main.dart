import 'package:flutter/material.dart';
import 'home.dart';

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
      home: const HomeScreen(),
    );
  }
}
