import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/gacha_item.dart';
import '../services/gacha_service.dart';
import '../services/character_collection_service.dart';

class GachaScreen extends StatefulWidget {
  const GachaScreen({super.key});

  @override
  State<GachaScreen> createState() => _GachaScreenState();
}

class _GachaScreenState extends State<GachaScreen> with TickerProviderStateMixin {
  late AnimationController _cardAnimationController;
  late AnimationController _buttonAnimationController;
  late Animation<double> _cardAnimation;
  late Animation<double> _buttonAnimation;
  
  UserProgress userProgress = UserProgress();
  GachaResult? currentResult;
  bool isAnimating = false;
  Set<String> newlyObtainedCharacters = {};
  
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
    
    _cardAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _cardAnimationController,
      curve: Curves.easeInOut,
    ));
    
    _buttonAnimation = Tween<double>(
      begin: 1.0,
      end: 0.8,
    ).animate(CurvedAnimation(
      parent: _buttonAnimationController,
      curve: Curves.elasticIn,
    ));
  }

  @override
  void dispose() {
    _cardAnimationController.dispose();
    _buttonAnimationController.dispose();
    super.dispose();
  }

  void _performSinglePull() async {
    if (isAnimating) {
      return;
    }

    HapticFeedback.mediumImpact();
    setState(() => isAnimating = true);
    
    _buttonAnimationController.forward().then((_) {
      _buttonAnimationController.reverse();
    });

    await Future.delayed(const Duration(milliseconds: 800));

    final result = GachaService.pullSingle();
    _processGachaResult(result);
    
    _cardAnimationController.forward();
    
    await Future.delayed(const Duration(milliseconds: 1200));
    setState(() => isAnimating = false);
  }


  void _processGachaResult(GachaResult result) async {
    // 新キャラ判定：ガチャを引く前に未取得だったキャラを特定
    final newCharactersInThisPull = <String>{};
    
    for (final item in result.items) {
      if (item.type == ItemType.character && item.character != null) {
        final characterName = item.character!.name;
        final wasAlreadyObtained = await CharacterCollectionService.isCharacterObtained(characterName);
        
        if (!wasAlreadyObtained && _isNewCharacter(characterName)) {
          newCharactersInThisPull.add(characterName);
        }
        
        userProgress.unlockCharacter(item.id);
        CharacterCollectionService.markCharacterAsObtained(characterName);
      }
    }
    
    setState(() {
      currentResult = result;
      newlyObtainedCharacters = newCharactersInThisPull;
    });
  }
  
  bool _isNewCharacter(String characterName) {
    final newCharacters = ['チョコ', 'カニ', 'カティ', 'サンド', 'ショク'];
    return newCharacters.contains(characterName);
  }

  void _resetResults() {
    setState(() {
      currentResult = null;
      _cardAnimationController.reset();
    });
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
      body: Container(
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
                    child: currentResult == null 
                        ? _buildGachaStandby()
                        : _buildGachaResult(),
                  ),
                  
                  // ボタンエリア
                  _buildButtonArea(),
                ],
              ),
            ),
          ],
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
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildGachaStandby() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
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
            child: const Icon(
              Icons.auto_awesome,
              size: 80,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            '運命のパンを引き当てよう！',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGachaResult() {
    if (currentResult == null) return const SizedBox();

    return AnimatedBuilder(
      animation: _cardAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _cardAnimation.value,
          child: Opacity(
            opacity: _cardAnimation.value,
            child: _buildSinglePullResult(),
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
              children: [
                Text(
                  item.rarity.displayName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
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
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    item.description,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ),
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


  Widget _buildButtonArea() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          if (currentResult != null) ...[
            ElevatedButton(
              onPressed: _resetResults,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[600],
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Text(
                'もう一度',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
            const SizedBox(height: 12),
          ],
          
          AnimatedBuilder(
            animation: _buttonAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: isAnimating ? _buttonAnimation.value : 1.0,
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: !isAnimating ? _performSinglePull : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      minimumSize: const Size(0, 60),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text(
                      'ガチャを引く',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}