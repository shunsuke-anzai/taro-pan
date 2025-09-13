import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'home.dart';
import 'splash.dart';
import 'services/character_collection_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  
  // 初期キャラクターの設定
  await CharacterCollectionService.initializeDefaultCharacters();
  
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: SplashScreen(),
  ));
}

class PanBattleApp extends StatelessWidget {
  const PanBattleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'パン屋の戦い',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.brown,
        ),
        // visualDensity: VisualDensity.adaptivePlatformDensity, // 削除
      ),
      home: const HomeScreen(),
    );
  }
}