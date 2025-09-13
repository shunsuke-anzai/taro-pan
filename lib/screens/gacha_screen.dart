import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/gacha_item.dart';
import '../services/gacha_service.dart';
import '../services/character_collection_service.dart';
import '../services/character_level_service.dart';
import '../widgets/character_level_widget.dart';

class GachaScreen extends StatefulWidget {
  const GachaScreen({super.key});

  @override
  State<GachaScreen> createState() => _GachaScreenState();
}

class _GachaScreenState extends State<GachaScreen> with TickerProviderStateMixin {
  late AnimationController _cardAnimationController;
  late AnimationController _buttonAnimationController;
  late AnimationController _sparkleAnimationController;
  late Animation<double> _cardAnimation;
  late Animation<double> _sparkleAnimation;
  
  UserProgress userProgress = UserProgress();
  GachaResult? currentResult;
  bool isAnimating = false;
  bool showRetryButton = false;
  Set<String> newlyObtainedCharacters = {};
  bool showLevelUpEffect = false;
  int levelUpNewLevel = 1;
  String levelUpCharacterName = '';
  
  @override
  void initState() {
    super.initState();
    
    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _buttonAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _sparkleAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _cardAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _cardAnimationController,
      curve: Curves.easeInOut,
    ));
    
    _sparkleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.3,
    ).animate(CurvedAnimation(
      parent: _sparkleAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _cardAnimationController.dispose();
    _buttonAnimationController.dispose();
    _sparkleAnimationController.dispose();
    super.dispose();
  }

  void _performSinglePull() async {
    if (isAnimating) {
      return;
    }

    HapticFeedback.mediumImpact();
    setState(() => isAnimating = true);
    
    // キラキラアニメーションを開始（ガチャを引いている間）
    _sparkleAnimationController.repeat(reverse: true);
    
    _buttonAnimationController.forward().then((_) {
      _buttonAnimationController.reverse();
    });

    // 演出のための長いディレイ（ため）
    await Future.delayed(const Duration(milliseconds: 2000));

    final result = GachaService.pullSingle();
    _processGachaResult(result);
    
    // キラキラアニメーションを停止
    _sparkleAnimationController.stop();
    _sparkleAnimationController.reset();
    
    _cardAnimationController.forward();
    
    await Future.delayed(const Duration(milliseconds: 1200));
    setState(() => isAnimating = false);
    
    // キャラ表示から2秒後に「もう一度」ボタンを表示
    await Future.delayed(const Duration(seconds: 2));
    setState(() => showRetryButton = true);
  }


  void _processGachaResult(GachaResult result) async {
    // 新キャラ判定：ガチャを引く前に未取得だったキャラを特定
    final newCharactersInThisPull = <String>{};
    bool leveledUp = false;
    String levelUpCharacter = '';
    int newLevel = 1;
    
    for (final item in result.items) {
      if (item.type == ItemType.character && item.character != null) {
        final characterName = item.character!.name;
        final wasAlreadyObtained = await CharacterCollectionService.isCharacterObtained(characterName);
        
        if (!wasAlreadyObtained && _isNewCharacter(characterName)) {
          newCharactersInThisPull.add(characterName);
        }
        
        userProgress.unlockCharacter(item.id);
        
        // レベルアップ判定を含むキャラクター処理
        if (!wasAlreadyObtained) {
          await CharacterCollectionService.markCharacterAsObtained(characterName);
        } else {
          // 既存キャラの場合、レベルアップ判定
          final didLevelUp = await CharacterLevelService.addCard(characterName);
          if (didLevelUp) {
            leveledUp = true;
            levelUpCharacter = characterName;
            newLevel = await CharacterLevelService.getCharacterLevel(characterName);
          }
        }
      }
    }
    
    setState(() {
      currentResult = result;
      newlyObtainedCharacters = newCharactersInThisPull;
      showLevelUpEffect = leveledUp;
      levelUpCharacterName = levelUpCharacter;
      levelUpNewLevel = newLevel;
    });
  }
  
  bool _isNewCharacter(String characterName) {
    final newCharacters = ['チョコ', 'カニ', 'カティ', 'サンド', 'ショク'];
    return newCharacters.contains(characterName);
  }

  void _resetResults() {
    setState(() {
      currentResult = null;
      showRetryButton = false;
      showLevelUpEffect = false;
      _cardAnimationController.reset();
      _sparkleAnimationController.reset();
    });
  }

  void _showProbabilityDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.black.withOpacity(0.9),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '排出確率',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                _buildProbabilityRow('★★★★★', Rarity.star5, '2.0%'),
                _buildProbabilityRow('★★★★☆', Rarity.star4, '13.0%'),
                _buildProbabilityRow('★★★☆☆', Rarity.star3, '85.0%'),
                const SizedBox(height: 20),
                const Text(
                  '※ 各レアリティ内でキャラクターは等確率',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 15),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('閉じる'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProbabilityRow(String stars, Rarity rarity, String percentage) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            stars,
            style: TextStyle(
              color: _getRarityColor(rarity),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            percentage,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Color _getRarityColor(Rarity rarity) {
    switch (rarity) {
      case Rarity.star1:
        return Colors.grey;
      case Rarity.star2:
        return Colors.green;
      case Rarity.star3:
        return Colors.blue;
      case Rarity.star4:
        return Colors.purple;
      case Rarity.star5:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: !isAnimating ? _performSinglePull : null,
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF2E1065),
                Color(0xFF1E1B4B),
                Color(0xFF0F0A2E),
              ],
            ),
          ),
          child: Stack(
            children: [
              // 背景の星
              ..._buildBackgroundStars(),
              
              // メインコンテンツ
              SafeArea(
                child: Column(
                  children: [
                    // ヘッダー
                    _buildHeader(),
                    
                    // ガチャ結果エリア
                    Expanded(
                      child: Stack(
                        children: [
                          currentResult == null 
                              ? _buildGachaStandby()
                              : Positioned.fill(
                                  child: Center(
                                    child: _buildGachaResult(),
                                  ),
                                ),
                          
                          // レベルアップエフェクト
                          if (showLevelUpEffect)
                            Center(
                              child: LevelUpEffectWidget(
                                newLevel: levelUpNewLevel,
                                onAnimationComplete: () {
                                  setState(() {
                                    showLevelUpEffect = false;
                                  });
                                },
                              ),
                            ),
                          
                          // 右下の「もう一度」ボタン
                          if (currentResult != null && showRetryButton)
                            Positioned(
                              bottom: 20,
                              right: 20,
                              child: FloatingActionButton.extended(
                                onPressed: _resetResults,
                                backgroundColor: Colors.grey[600],
                                label: const Text(
                                  'もう一度',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                icon: const Icon(
                                  Icons.refresh,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildBackgroundStars() {
    return List.generate(20, (index) {
      return Positioned(
        left: (index * 37.0) % MediaQuery.of(context).size.width,
        top: (index * 43.0) % MediaQuery.of(context).size.height,
        child: Icon(
          Icons.star,
          color: Colors.white.withOpacity(0.1),
          size: 20,
        ),
      );
    });
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
              size: 28,
            ),
          ),
          Text(
            'ガチャ',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            onPressed: _showProbabilityDialog,
            icon: const Icon(
              Icons.info_outline,
              color: Colors.white,
              size: 24,
            ),
            tooltip: '確率表示',
          ),
        ],
      ),
    );
  }

  Widget _buildGachaStandby() {
    return SingleChildScrollView(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 50),
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.white.withOpacity(0.3),
                    Colors.transparent,
                  ],
                ),
              ),
              child: AnimatedBuilder(
                animation: _sparkleAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: isAnimating ? _sparkleAnimation.value : 1.0,
                    child: const Icon(
                      Icons.auto_awesome,
                      size: 80,
                      color: Colors.white,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 32),
            Text(
              isAnimating ? 'ガチャを引いています...' : '運命のパンを引き当てよう！',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            if (isAnimating)
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              )
            else
              const Text(
                '画面をタップしてガチャを引く',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildGachaResult() {
    if (currentResult == null) return const SizedBox();

    return AnimatedBuilder(
      animation: _cardAnimation,
      builder: (context, child) {
        return Center(
          child: Transform.scale(
            scale: _cardAnimation.value,
            child: Opacity(
              opacity: _cardAnimation.value,
              child: _buildSinglePullResult(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSinglePullResult() {
    final item = currentResult!.items.first;
    return Center(
      child: Container(
        width: 250,
        height: 350,
        margin: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              _getRarityColor(item.rarity).withOpacity(0.8),
              _getRarityColor(item.rarity).withOpacity(0.6),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: _getRarityColor(item.rarity).withOpacity(0.5),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  item.rarity.displayName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.2),
                  ),
                  child: item.imagePath.isNotEmpty
                      ? Image.asset(item.imagePath, fit: BoxFit.contain)
                      : const Icon(Icons.help, size: 60, color: Colors.white),
                ),
                const SizedBox(height: 16),
                Text(
                  item.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                // キャラクターの場合はレベル情報を表示
                if (item.character != null) ...[
                  Center(
                    child: CharacterLevelWidget(
                      characterName: item.character!.name,
                      isCompact: true,
                      width: 120,
                      height: 24,
                      animateProgress: true, // アニメーション有効
                    ),
                  ),
                  const SizedBox(height: 16), // スペースを少し増加
                ],
              ],
            ),
            // New ラベル
            if (item.character != null && newlyObtainedCharacters.contains(item.character!.name))
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withOpacity(0.5),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Text(
                    'NEW',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}