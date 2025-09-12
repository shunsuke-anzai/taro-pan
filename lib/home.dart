import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:taro_pan/main.dart';
import 'package:rive/rive.dart' as rive;
import 'battle_screen.dart';
import 'screens/gacha_screen.dart';
import 'services/character_collection_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  late rive.RiveAnimationController _controller;

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
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // アプリがフォアグラウンドに戻った時にアニメーション再生
    if (state == AppLifecycleState.resumed) {
      setState(() {
        _controller = rive.SimpleAnimation('Timeline 1');
      });
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
    {"name": "ぷくらん", "image": "assets/images/pukuran.png", "index": 0},
    {"name": "バゲットン", "image": "assets/images/bageton.png", "index": 1},
    {"name": "クレッシェン", "image": "assets/images/kuresien.png", "index": 2},
    {"name": "あんまる", "image": "assets/images/anmaru.png", "index": 3},
    {"name": "ダブルトングマン", "image": "assets/images/panda.png", "index": 4},
    {"name": "チョコ", "image": "assets/images/choko_mask.png", "index": 5},
    {"name": "カニ", "image": "assets/images/kani_mask.png", "index": 6},
    {"name": "カティ", "image": "assets/images/kati_mask.png", "index": 7},
    {"name": "サンド", "image": "assets/images/sand_mask.png", "index": 8},
    {"name": "ショク", "image": "assets/images/shoku_mask.png", "index": 9},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: GridView.count(
              crossAxisCount: 3,
              mainAxisSpacing: 24,
              crossAxisSpacing: 24,
              childAspectRatio: 1,
              children: characters.map((chara) {
                final characterName = chara["name"] as String;
                final isObtained = _isCharacterObtained(characterName);
                
                return GestureDetector(
                  onTap: isObtained ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CharaList2(initialPage: chara["index"] as int),
                      ),
                    );
                  } : null,
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
                            padding: const EdgeInsets.all(6.0),
                            child: Image.asset(
                              _getCharacterImage(chara["name"] as String, chara["image"] as String),
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _getDisplayName(chara["name"] as String),
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
    "description": "HP: 100\n攻撃力: 20\n消費パワー: 10\n基本的なパン戦士。バランスの取れた能力を持つ。"
    },
    {"name": "バゲットン", 
    "image": "assets/images/bageton.png",
    "description": "HP: 120\n攻撃力: 25\n消費パワー: 12\n素早い動きで相手を翻弄するパン戦士。"
    },
    {"name": "クレッシェン", 
    "image": "assets/images/kuresien.png",
    "description": "HP: 110\n攻撃力: 22\n消費パワー: 11\n特殊な技を持つパン戦士。"
    },
    {"name": "あんまる", 
    "image": "assets/images/anmaru.png",
    "description": "HP: 130\n攻撃力: 30\n消費パワー: 15\n防御力が高く、耐久性に優れたパン戦士。"
    },
    {"name": "ダブルトングマン", 
    "image": "assets/images/panda.png",
    "description": "HP: 140\n攻撃力: 35\n消費パワー: 20\n二つのトングを使いこなすパン戦士。"
    },
    {"name": "チョコ", 
    "image": "assets/images/choko.png",
    "description": "HP: 110\n攻撃力: 28\n消費パワー: 50\n甘い香りで敵を魅了するチョコレート戦士。"
    },
    {"name": "カニ", 
    "image": "assets/images/kani.png",
    "description": "HP: 130\n攻撃力: 32\n消費パワー: 70\nハサミで敵を挟み撃ちする甲殻類の戦士。"
    },
    {"name": "カティ", 
    "image": "assets/images/kati.png",
    "description": "HP: 95\n攻撃力: 38\n消費パワー: 80\n鋭い爪を持つ俊敏な猫の戦士。"
    },
    {"name": "サンド", 
    "image": "assets/images/sand.png",
    "description": "HP: 140\n攻撃力: 22\n消費パワー: 55\n砂を操る大地の守護者。高い防御力を誇る。"
    },
    {"name": "ショク", 
    "image": "assets/images/shoku.png",
    "description": "HP: 105\n攻撃力: 40\n消費パワー: 85\n植物の力を借りて戦う自然の戦士。"
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
