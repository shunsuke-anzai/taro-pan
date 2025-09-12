import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:taro_pan/main.dart';
import 'package:rive/rive.dart' as rive;
import 'package:audioplayers/audioplayers.dart';
import 'battle_screen.dart';
import 'data/game_data.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  late rive.RiveAnimationController _controller;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    
    // 画面方向を横向きに固定
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    
    WidgetsBinding.instance.addObserver(this);
    _controller = rive.SimpleAnimation('Timeline 1');
    _playBGM();
  }
  
  Future<void> _playBGM() async {
    try {
      await _audioPlayer.play(AssetSource('BGM/クリームパンに見えるなぁ.mp3'));
      _audioPlayer.setReleaseMode(ReleaseMode.loop);
    } catch (e) {
      print('BGM再生エラー: $e');
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // アプリがフォアグラウンドに戻った時にアニメーション再生
    if (state == AppLifecycleState.resumed) {
      setState(() {
        _controller = rive.SimpleAnimation('Timeline 1');
      });
      _audioPlayer.resume();
    } else if (state == AppLifecycleState.paused) {
      _audioPlayer.pause();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 背景画像
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/backsky.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: SizedBox(
              width: 1000,
              height: 500,
              child: rive.RiveAnimation.asset(
                'assets/animations/taro-pan.riv',
                controllers: [_controller],
                fit: BoxFit.contain,
              ),
            ),
          ),
          // タイトル画像
          Positioned(
            top: 10,
            left: 0,
            right: 0,
            child: Center(
              child: Image.asset(
                'assets/images/ink.png',
                width: 600,
                height: 200,
                fit: BoxFit.contain,
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 40,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const BattleScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                      ),
                      child: Image.asset(
                        'assets/images/start.png',
                        height: 40,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    height: 40,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const PanBattleApp()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                      ),
                      child: Image.asset(
                        'assets/images/gacha.png',
                        height: 40,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    height: 40,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const CharaList()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                      ),
                      child: Image.asset(
                        'assets/images/chara.png',
                        height: 40,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CharaList extends StatelessWidget {
  const CharaList({super.key});

  @override

  Widget build(BuildContext context) {
    final characters = GameData.getAllCharacters();
    
    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: GridView.count(
              crossAxisCount: 4,
              mainAxisSpacing: 24,
              crossAxisSpacing: 24,
              childAspectRatio: 1,
              children: characters.asMap().entries.map((entry) {
                final index = entry.key;
                final character = entry.value;
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CharaList2(initialPage: index),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Image.asset(
                              'assets/images/${character.displayImagePath}',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          character.isUnlocked ? character.name : "???",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                );
              }).toList(),
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

class CharaList2 extends StatefulWidget {
  final int initialPage;
  const CharaList2({super.key, required this.initialPage});

  @override
  State<CharaList2> createState() => _CharaList2State();
}

class _CharaList2State extends State<CharaList2> {
  late PageController _pageController;
  late List<dynamic> characters;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialPage);
    
    // GameDataからキャラクター情報を取得
    final gameCharacters = GameData.getAllCharacters();
    characters = gameCharacters.map((char) => {
      "name": char.isUnlocked ? char.name : "???",
      "image": "assets/images/${char.displayImagePath}",
      "description": char.isUnlocked 
          ? "HP: ${char.maxHp}\n攻撃力: ${char.attackPower}\n消費パワー: ${char.powerCost ~/ 3}\n${char.description}"
          : "coming soon..."
    }).toList();
    
    // 最後の hatena.png キャラクターを追加
    characters.add({
      "name": "???",
      "image": "assets/images/hatena.png",
      "description": "coming soon..."
    });
  }

  void _previousPage() {
    if (_pageController.page! > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _nextPage() {
    if (_pageController.page! < characters.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: characters.length,
            itemBuilder: (context, index) {
              final chara = characters[index];
              final screenWidth = MediaQuery.of(context).size.width;
              final screenHeight = MediaQuery.of(context).size.height;
              return SizedBox.expand(
                child: Container(
                  width: screenWidth,
                  height: screenHeight,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    image: const DecorationImage(
                      image: AssetImage('assets/images/chara_bg.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Padding(
                          padding: const EdgeInsets.all(0),
                          child: Image.asset(
                            chara["image"] as String,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.5), // 透明度0.5の黒背景
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(20),
                              bottomRight: Radius.circular(20),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  chara["name"] as String,
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  chara["description"] as String,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          // ...existing code...
          Positioned(
            left: 40,
            top: 0,
            bottom: 0,
            child: IconButton(
              icon: Transform.rotate(
                angle: 3.1416, // 左向きに反転
                child: const Icon(Icons.play_arrow, size: 48, color: Colors.white),
              ),
              onPressed: _previousPage,
            ),
          ),
          Positioned(
            right: 40,
            top: 0,
            bottom: 0,
            child: IconButton(
              icon: const Icon(Icons.play_arrow, size: 48, color: Colors.white), // 右向き
              onPressed: _nextPage,
            ),
          ),
          // ...existing code...
                    Positioned(
            left: 16,
            top: 32,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, size: 32, color: Colors.white),
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
