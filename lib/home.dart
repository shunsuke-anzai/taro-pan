import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:taro_pan/main.dart';
import 'package:rive/rive.dart' as rive;
import 'package:audioplayers/audioplayers.dart';
import 'battle_screen.dart';
import 'screens/gacha_screen.dart';
import 'services/character_collection_service.dart';
import 'models/gacha_item.dart';
import 'data/gacha_data.dart';
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
                          MaterialPageRoute(builder: (context) => const GachaScreen()),
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

class CharaList extends StatefulWidget {
  const CharaList({super.key});

  @override
  State<CharaList> createState() => _CharaListState();
}

class _CharaListState extends State<CharaList> {
  Set<String> obtainedCharacters = {};

  @override
  void initState() {
    super.initState();
    _loadObtainedCharacters();
  }

  Future<void> _loadObtainedCharacters() async {
    final obtained = await CharacterCollectionService.getObtainedCharacters();
    setState(() {
      obtainedCharacters = obtained;
    });
  }

  final characters = const [
    {"name": "ぷくらん", "image": "assets/images/pukuran.png", "index": 0, "rarity": 3},
    {"name": "バゲットン", "image": "assets/images/bageton.png", "index": 1, "rarity": 4},
    {"name": "クレッシェン", "image": "assets/images/kuresien.png", "index": 2, "rarity": 5},
    {"name": "あんまる", "image": "assets/images/anmaru.png", "index": 3, "rarity": 4},
    {"name": "ダブルトングマン", "image": "assets/images/panda.png", "index": 4, "rarity": 4},
    {"name": "チョコ", "image": "assets/images/choko_mask.png", "index": 5, "rarity": 3},
    {"name": "カニ", "image": "assets/images/kani_mask.png", "index": 6, "rarity": 3},
    {"name": "カティ", "image": "assets/images/kati_mask.png", "index": 7, "rarity": 4},
    {"name": "サンド", "image": "assets/images/sand_mask.png", "index": 8, "rarity": 3},
    {"name": "ショク", "image": "assets/images/shoku_mask.png", "index": 9, "rarity": 4},
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 背景画像
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/charaback.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: GridView.count(
              crossAxisCount: 4,
              mainAxisSpacing: 24,
              crossAxisSpacing: 24,
              childAspectRatio: 1,
              children: characters.map((chara) {
                final characterName = chara["name"] as String;
                final isObtained = _isCharacterObtained(characterName);
                final index = chara["index"] as int;
                return GestureDetector(
                  onTap: isObtained ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CharaList2(initialPage: index),
                      ),
                    );
                  } : null,
                  child: Container(
                    decoration: BoxDecoration(
                      color: _getRarityCardColor(chara["rarity"] as int),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: _getRarityBorderColor(chara["rarity"] as int).withOpacity(0.5),
                          blurRadius: 8,
                          offset: Offset(2, 2),
                        ),
                      ],
                      border: Border.all(
                        color: _getRarityBorderColor(chara["rarity"] as int),
                        width: 2,
                      ),
                    ),
                    child: Stack(
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(6.0),
                                child: Image.asset(
                                  _getCharacterImage(chara["name"] as String, chara["image"] as String),
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.white.withOpacity(0.9),
                                    Colors.white.withOpacity(0.7),
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              child: Text(
                                _getDisplayName(chara["name"] as String),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.black87,
                                  shadows: [
                                    Shadow(
                                      color: Colors.white.withOpacity(0.8),
                                      offset: const Offset(1, 1),
                                      blurRadius: 2,
                                    ),
                                  ],
                                  letterSpacing: 0.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
                        // 右上に星を表示
                        Positioned(
                          top: 8,
                          right: 8,
                          child: _buildStarRating(chara["rarity"] as int),
                        ),
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

  String _getCharacterImage(String characterName, String defaultImage) {
    final newCharacters = ['チョコ', 'カニ', 'カティ', 'サンド', 'ショク'];
    
    if (newCharacters.contains(characterName)) {
      if (obtainedCharacters.contains(characterName)) {
        return defaultImage.replaceAll('_mask.png', '.png');
      } else {
        return defaultImage;
      }
    }
    
    return defaultImage;
  }
  
  String _getDisplayName(String characterName) {
    final newCharacters = ['チョコ', 'カニ', 'カティ', 'サンド', 'ショク'];
    
    if (newCharacters.contains(characterName) && !obtainedCharacters.contains(characterName)) {
      return '???';
    }
    
    return characterName;
  }
  
  Color _getRarityCardColor(int rarity) {
    switch (rarity) {
      case 3:
        return Colors.blue.withOpacity(0.1);
      case 4:
        return Colors.purple.withOpacity(0.1);
      case 5:
        return Colors.orange.withOpacity(0.1);
      default:
        return Colors.white;
    }
  }
  
  Color _getRarityBorderColor(int rarity) {
    switch (rarity) {
      case 3:
        return Colors.blue;
      case 4:
        return Colors.purple;
      case 5:
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
  
  Widget _buildStarRating(int rarity) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(rarity, (index) => 
        const Icon(
          Icons.star,
          color: Colors.amber,
          size: 16,
        )
      ),
    );
  }
  
  String _getDisplayNameDetailed(String characterName) {
    final newCharacters = ['チョコ', 'カニ', 'カティ', 'サンド', 'ショク'];
    
    if (newCharacters.contains(characterName) && !obtainedCharacters.contains(characterName)) {
      return '???';
    }
    
    return characterName;
  }
  
  bool _isCharacterObtained(String characterName) {
    final newCharacters = ['チョコ', 'カニ', 'カティ', 'サンド', 'ショク'];
    
    if (newCharacters.contains(characterName)) {
      return obtainedCharacters.contains(characterName);
    }
    
    // 既存キャラクターは常に取得済み扱い
    return true;
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
  Set<String> obtainedCharacters = {};

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialPage);
    _loadObtainedCharacters();
  }

  Future<void> _loadObtainedCharacters() async {
    final obtained = await CharacterCollectionService.getObtainedCharacters();
    setState(() {
      obtainedCharacters = obtained;
    });
  }

  final characters = [
    {"name": "ぷくらん", 
    "image": "assets/images/pukuran.png",
    "description": "HP: 100\n攻撃力: 20\n消費パワー: 10\n基本的なパン戦士。バランスの取れた能力を持つ。",
    "rarity": 3
    },
    {"name": "バゲットン", 
    "image": "assets/images/bageton.png",
    "description": "HP: 120\n攻撃力: 25\n消費パワー: 12\n素早い動きで相手を翻弄するパン戦士。",
    "rarity": 4
    },
    {"name": "クレッシェン", 
    "image": "assets/images/kuresien.png",
    "description": "HP: 110\n攻撃力: 22\n消費パワー: 11\n特殊な技を持つパン戦士。",
    "rarity": 5
    },
    {"name": "あんまる", 
    "image": "assets/images/anmaru.png",
    "description": "HP: 130\n攻撃力: 30\n消費パワー: 15\n防御力が高く、耐久性に優れたパン戦士。",
    "rarity": 4
    },
    {"name": "ダブルトングマン", 
    "image": "assets/images/panda.png",
    "description": "HP: 140\n攻撃力: 35\n消費パワー: 20\n二つのトングを使いこなすパン戦士。",
    "rarity": 4
    },
    {"name": "チョコ", 
    "image": "assets/images/choko.png",
    "description": "HP: 110\n攻撃力: 28\n消費パワー: 50\n甘い香りで敵を魅了するチョコレート戦士。",
    "rarity": 3
    },
    {"name": "カニ", 
    "image": "assets/images/kani.png",
    "description": "HP: 130\n攻撃力: 32\n消費パワー: 70\nハサミで敵を挟み撃ちする甲殻類の戦士。",
    "rarity": 3
    },
    {"name": "カティ", 
    "image": "assets/images/kati.png",
    "description": "HP: 95\n攻撃力: 38\n消費パワー: 80\n鋭い爪を持つ俊敏な猫の戦士。",
    "rarity": 4
    },
    {"name": "サンド", 
    "image": "assets/images/sand.png",
    "description": "HP: 140\n攻撃力: 22\n消費パワー: 55\n砂を操る大地の守護者。高い防御力を誇る。",
    "rarity": 3
    },
    {"name": "ショク", 
    "image": "assets/images/shoku.png",
    "description": "HP: 105\n攻撃力: 40\n消費パワー: 85\n植物の力を借りて戦う自然の戦士。",
    "rarity": 4
    },
  ];


  void _previousPage() {
    final currentPage = _pageController.page!.round();
    if (currentPage > 0) {
      final targetPage = currentPage - 1;
      final targetCharacterName = characters[targetPage]["name"] as String;
      
      if (_isCharacterObtained(targetCharacterName)) {
        _pageController.previousPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  void _nextPage() {
    final currentPage = _pageController.page!.round();
    if (currentPage < characters.length - 1) {
      final targetPage = currentPage + 1;
      final targetCharacterName = characters[targetPage]["name"] as String;
      
      if (_isCharacterObtained(targetCharacterName)) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }
  
  String _getDisplayNameDetailed(String characterName) {
    final newCharacters = ['チョコ', 'カニ', 'カティ', 'サンド', 'ショク'];
    
    if (newCharacters.contains(characterName) && !obtainedCharacters.contains(characterName)) {
      return '???';
    }
    
    return characterName;
  }
  
  bool _isCharacterObtained(String characterName) {
    final newCharacters = ['チョコ', 'カニ', 'カティ', 'サンド', 'ショク'];
    
    if (newCharacters.contains(characterName)) {
      return obtainedCharacters.contains(characterName);
    }
    
    // 既存キャラクターは常に取得済み扱い
    return true;
  }

  Color _getRarityCardColorDetailed(int rarity) {
    switch (rarity) {
      case 3:
        return Colors.blue.withOpacity(0.1);
      case 4:
        return Colors.purple.withOpacity(0.1);
      case 5:
        return Colors.orange.withOpacity(0.1);
      default:
        return Colors.white;
    }
  }
  
  Color _getRarityBorderColorDetailed(int rarity) {
    switch (rarity) {
      case 3:
        return Colors.blue;
      case 4:
        return Colors.purple;
      case 5:
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
  
  Widget _buildStarRatingDetailed(int rarity) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(rarity, (index) => 
        const Icon(
          Icons.star,
          color: Colors.amber,
          size: 24,
        )
      ),
    );
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
                image: AssetImage('assets/images/charaback.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
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
                  padding: const EdgeInsets.all(20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: _getRarityCardColorDetailed(chara["rarity"] as int),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _getRarityBorderColorDetailed(chara["rarity"] as int),
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _getRarityBorderColorDetailed(chara["rarity"] as int).withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: Padding(
                                padding: const EdgeInsets.all(20),
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
                                  color: Colors.black.withValues(alpha: 0.7),
                                  borderRadius: const BorderRadius.only(
                                    topRight: Radius.circular(17),
                                    bottomRight: Radius.circular(17),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        _getDisplayNameDetailed(chara["name"] as String),
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
                        // 右上に星を表示
                        Positioned(
                          top: 15,
                          right: 15,
                          child: _buildStarRatingDetailed(chara["rarity"] as int),
                        ),
                      ],
                    ),
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
