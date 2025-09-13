import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rive/rive.dart' as rive;
import 'battle_screen.dart';
import 'screens/gacha_screen.dart';
import 'services/character_collection_service.dart';
import 'services/bgm_service.dart';
import 'services/se_service.dart';
import 'data/game_data.dart';
import 'widgets/character_level_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late rive.RiveAnimationController _controller;
  bool _bgmStarted = false;

  @override
  void initState() {
    super.initState();
    
    // 画面方向を横向きに固定
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    
    _controller = rive.SimpleAnimation('Timeline 1');
    _controller.isActiveChanged.addListener(_onIntroActiveChanged);
    
    // BGMは最初のユーザーインタラクション時に開始
  }
  
  void _onIntroActiveChanged() {
    if (!_controller.isActive) {
      // イントロアニメーション終了時の処理（BGM開始は削除）
    }
  }

  Future<void> _playBGM() async {
    if (!_bgmStarted) {
      print('ホーム画面でBGM再生を開始します');
      await BGMService().playBGM();
      _bgmStarted = true;
    }
  }

  @override
  void dispose() {
    _controller.isActiveChanged.removeListener(_onIntroActiveChanged);
    super.dispose();
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
                        SEService.playButtonSE();
                        _playBGM(); // BGM開始
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
                        SEService.playButtonSE();
                        _playBGM(); // BGM開始
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
                        SEService.playButtonSE();
                        _playBGM(); // BGM開始
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

  @override
  Widget build(BuildContext context) {
    final characters = GameData.getAllCharacters();
    
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
              crossAxisCount: 3,
              mainAxisSpacing: 24,
              crossAxisSpacing: 24,
              childAspectRatio: 1,
              children: characters.asMap().entries.map((entry) {
                final index = entry.key;
                final character = entry.value;
                return GestureDetector(
                  onTap: _isCharacterObtained(character.name) ? () {
                    SEService.playButtonSE();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CharaList2(initialPage: index),
                      ),
                    );
                  } : null,
                  child: Container(
                    decoration: BoxDecoration(
                      color: _getRarityCardColor(character.rarity),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: _getRarityBorderColor(character.rarity).withOpacity(0.5),
                          blurRadius: 8,
                          offset: Offset(2, 2),
                        ),
                      ],
                      border: Border.all(
                        color: _getRarityBorderColor(character.rarity),
                        width: 2,
                      ),
                    ),
                    child: Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                flex: 4, // 画像領域を少し大きく
                                child: Center(
                                  child: Image.asset(
                                    'assets/images/${_getCharacterDisplayImage(character)}',
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4), // スペース調整
                              Flexible(
                                flex: 1,
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), // パディング調整
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
                                      color: Colors.black,
                                      width: 2,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      _isCharacterObtained(character.name) ? character.name : "???",
                                      style: TextStyle(
                                        fontSize: 10, // フォントサイズ縮小
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
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // 右上に星を表示
                        Positioned(
                          top: 8,
                          right: 8,
                          child: _buildStarRating(character.rarity),
                        ),
                        // 左下にレベル表示（解放済みキャラのみ）
                        if (_isCharacterObtained(character.name))
                          Positioned(
                            bottom: 32, // 少し上に調整
                            left: 4,
                            child: CharacterLevelWidget(
                              characterName: character.name,
                              isCompact: true,
                              width: 70, // 新しいウィジェットサイズに合わせて調整
                              height: 26,
                            ),
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

  String _getCharacterDisplayImage(character) {
    if (_isCharacterObtained(character.name)) {
      return character.imagePath;
    } else {
      return character.lockedImagePath ?? character.imagePath;
    }
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



  void _previousPage() {
    final characters = GameData.getAllCharacters();
    final currentPage = _pageController.page!.round();
    
    // 現在のページより前の解放済みキャラクターを探す
    for (int i = currentPage - 1; i >= 0; i--) {
      if (_isCharacterObtained(characters[i].name)) {
        _pageController.animateToPage(
          i,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        break;
      }
    }
  }

  void _nextPage() {
    final characters = GameData.getAllCharacters();
    final currentPage = _pageController.page!.round();
    
    // 現在のページより後の解放済みキャラクターを探す
    for (int i = currentPage + 1; i < characters.length; i++) {
      if (_isCharacterObtained(characters[i].name)) {
        _pageController.animateToPage(
          i,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        break;
      }
    }
  }
  
  
  bool _isCharacterObtained(String characterName) {
    final newCharacters = ['チョコ', 'カニ', 'カティ', 'サンド', 'ショク'];
    
    if (newCharacters.contains(characterName)) {
      return obtainedCharacters.contains(characterName);
    }
    
    // 既存キャラクターは常に取得済み扱い
    return true;
  }

  String _getCharacterDisplayImage(character) {
    if (_isCharacterObtained(character.name)) {
      return character.imagePath;
    } else {
      return character.lockedImagePath ?? character.imagePath;
    }
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
    final characters = GameData.getAllCharacters();
    
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
              final character = characters[index];
              final screenWidth = MediaQuery.of(context).size.width;
              final screenHeight = MediaQuery.of(context).size.height;
              final description = 'HP: ${character.maxHp}\n攻撃力: ${character.attackPower}\n消費パワー: ${character.powerCost}\n${character.description}';
              
              return SizedBox.expand(
                child: Container(
                  width: screenWidth,
                  height: screenHeight,
                  padding: const EdgeInsets.all(20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: _getRarityCardColorDetailed(character.rarity),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _getRarityBorderColorDetailed(character.rarity),
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _getRarityBorderColorDetailed(character.rarity).withOpacity(0.3),
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
                                  'assets/images/${_getCharacterDisplayImage(character)}',
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2, // 右側を広くして説明文のスペースを確保
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.7),
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
                                    mainAxisSize: MainAxisSize.min, // 最小サイズに調整
                                    children: [
                                      Text(
                                        _isCharacterObtained(character.name) ? character.name : "???",
                                        style: const TextStyle(
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      // 解放済みキャラクターにレベル情報を表示
                                      if (_isCharacterObtained(character.name)) ...[
                                        CharacterLevelWidget(
                                          characterName: character.name,
                                          showProgressBar: true,
                                          width: 200,
                                          height: 70, // 高さを少し縮小
                                        ),
                                        const SizedBox(height: 15),
                                      ],
                                      Expanded( // Flexibleの代わりにExpandedを使用
                                        child: Text(
                                          _isCharacterObtained(character.name) ? description : "???",
                                          style: const TextStyle(
                                            fontSize: 16, // フォントサイズをさらに調整
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                          maxLines: 6, // 最大行数を増加
                                          overflow: TextOverflow.ellipsis,
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
                          child: _buildStarRatingDetailed(character.rarity),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
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
          // 左上に戻るボタン
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
