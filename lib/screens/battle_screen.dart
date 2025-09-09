import 'dart:async';
import 'package:flutter/material.dart';
import '../models/character.dart';
import '../models/deployed_character.dart';
import '../models/enemy.dart';
import '../models/spawned_enemy.dart';
import '../data/game_data.dart';
import '../data/enemy_data.dart';
import '../widgets/character_detail_dialog.dart';

class BattleScreen extends StatefulWidget {
  const BattleScreen({Key? key}) : super(key: key);

  @override
  State<BattleScreen> createState() => _BattleScreenState();
}

class _BattleScreenState extends State<BattleScreen> with TickerProviderStateMixin {
  static const int maxYeastPower = 100;
  static const int yeastRegenRate = 2; // パワー回復量（秒間）
  
  int currentYeastPower = 0;
  Timer? _yeastTimer;
  Timer? _enemySpawnTimer;
  List<Character> availableCharacters = [];
  List<DeployedCharacter> deployedCharacters = [];
  List<SpawnedEnemy> spawnedEnemies = [];
  
  late AnimationController _ovenAnimationController;
  late Animation<double> _ovenAnimation;

  @override
  void initState() {
    super.initState();
    availableCharacters = GameData.getAllCharacters();
    _startYeastGeneration();
    _startEnemySpawning();
    
    // パン窯のアニメーションコントローラー
    _ovenAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _ovenAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _ovenAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _yeastTimer?.cancel();
    _enemySpawnTimer?.cancel();
    _ovenAnimationController.dispose();
    for (var deployedChar in deployedCharacters) {
      deployedChar.dispose();
    }
    for (var spawnedEnemy in spawnedEnemies) {
      spawnedEnemy.dispose();
    }
    super.dispose();
  }

  void _startYeastGeneration() {
    _yeastTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (currentYeastPower < maxYeastPower) {
        setState(() {
          currentYeastPower = (currentYeastPower + yeastRegenRate).clamp(0, maxYeastPower);
        });
      }
    });
  }

  void _deployCharacter(Character character) {
    if (currentYeastPower >= character.powerCost) {
      setState(() {
        currentYeastPower -= character.powerCost;
      });
      
      // パン窯のアニメーション開始（より強く震える）
      _ovenAnimationController.forward().then((_) {
        _ovenAnimationController.reverse();
      });
      
      // 煙の効果を追加（今後実装予定）
      _showBakeEffect();
      
      // キャラクターの出現アニメーション
      _createDeployedCharacter(character);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${character.name}がパン窯から出現しました！'),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  void _createDeployedCharacter(Character character) {
    final animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // スライドアニメーション（パン窯の出口から右に移動）
    final slideAnimation = Tween<double>(
      begin: 170.0, // パン窯の出口位置（大きくなった画像の右端）
      end: 250.0 + (deployedCharacters.length * 90.0), // 配置位置（間隔を広げる）
    ).animate(CurvedAnimation(
      parent: animationController,
      curve: Curves.easeOutBack,
    ));

    // スケールアニメーション（パン窯から「ポップ」と出現）
    final scaleAnimation = Tween<double>(
      begin: 0.3, // 小さく始まる
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: animationController,
      curve: Curves.elasticOut,
    ));

    // Y座標のバウンスアニメーション（出現時に少し跳ねる）
    final bounceAnimation = Tween<double>(
      begin: 0.0,
      end: 10.0,
    ).animate(CurvedAnimation(
      parent: animationController,
      curve: Curves.bounceOut,
    ));

    final deployedChar = DeployedCharacter(
      character: character,
      x: 170.0, // 初期位置（大きくなったパン窯の出口）
      y: 200.0, // Y座標を調整
      deployTime: DateTime.now(),
      animationController: animationController,
      slideAnimation: slideAnimation,
      scaleAnimation: scaleAnimation,
      bounceAnimation: bounceAnimation,
    );

    setState(() {
      deployedCharacters.add(deployedChar);
    });

    // アニメーション開始
    animationController.forward();
  }

  bool _canDeployCharacter(Character character) {
    return currentYeastPower >= character.powerCost;
  }

  void _showCharacterDetail(Character character) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CharacterDetailDialog(character: character);
      },
    );
  }

  void _startEnemySpawning() {
    _enemySpawnTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _spawnEnemy();
    });
  }

  void _spawnEnemy() {
    final enemy = EnemyData.getRandomEnemy();
    final animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // 敵城の位置から左に移動するアニメーション
    final moveAnimation = Tween<double>(
      begin: 0.0, // 城からの相対位置
      end: -500.0, // 左に移動する距離
    ).animate(CurvedAnimation(
      parent: animationController,
      curve: Curves.linear,
    ));

    // 出現時のスケールアニメーション
    final scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: animationController,
      curve: Curves.easeOut,
    ));

    final spawnedEnemy = SpawnedEnemy(
      enemy: enemy,
      x: MediaQuery.of(context).size.width - 200, // 城の左側から出現
      y: 200.0 + (spawnedEnemies.length % 3) * 60, // Y座標をずらす
      spawnTime: DateTime.now(),
      animationController: animationController,
      moveAnimation: moveAnimation,
      scaleAnimation: scaleAnimation,
    );

    setState(() {
      spawnedEnemies.add(spawnedEnemy);
    });

    // 移動アニメーション開始
    animationController.forward();

    // 一定時間後に敵を削除（画面外に出た場合）
    Timer(const Duration(seconds: 20), () {
      if (spawnedEnemies.contains(spawnedEnemy)) {
        setState(() {
          spawnedEnemies.remove(spawnedEnemy);
        });
        spawnedEnemy.dispose();
      }
    });
  }

  void _showBakeEffect() {
    // パンが焼けるときの効果音や視覚効果を追加
    // 現在は簡単な振動効果のみ実装
    // 将来的には煙のパーティクルエフェクトなどを追加予定
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightGreen[50],
      body: Column(
        children: [
          // イーストパワー表示部分
          _buildYeastPowerBar(),
          
          // 戦闘エリア
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.blue[100]!,
                    Colors.green[100]!,
                  ],
                ),
              ),
              child: Stack(
                children: [
                  // パン窯
                  Positioned(
                    left: 20,
                    top: 120,
                    child: _buildOven(),
                  ),

                  // 敵の城
                  Positioned(
                    right: 20,
                    top: 100,
                    child: _buildEnemyCastle(),
                  ),
                  
                  // 配置されたキャラクター
                  ...deployedCharacters.map((deployedChar) => 
                    _buildDeployedCharacter(deployedChar)
                  ).toList(),

                  // スポーンされた敵
                  ...spawnedEnemies.map((spawnedEnemy) => 
                    _buildSpawnedEnemy(spawnedEnemy)
                  ).toList(),
                  
                  // 戦闘エリアのラベル（上部に表示）
                  const Positioned(
                    top: 20,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Text(
                        '戦闘エリア',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // キャラクター選択部分
          _buildCharacterSelection(),
        ],
      ),
    );
  }

  Widget _buildYeastPowerBar() {
    double powerPercentage = currentYeastPower / maxYeastPower;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.brown[100],
        border: Border(
          bottom: BorderSide(color: Colors.brown[300]!, width: 2),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'イーストパワー',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown,
                ),
              ),
              Text(
                '$currentYeastPower / $maxYeastPower',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            height: 20,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.brown[600]!, width: 2),
            ),
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.brown[200],
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: powerPercentage,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      gradient: LinearGradient(
                        colors: [
                          Colors.yellow[400]!,
                          Colors.orange[400]!,
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCharacterSelection() {
    return Container(
      height: 120,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.brown[200],
        border: Border(
          top: BorderSide(color: Colors.brown[400]!, width: 2),
        ),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: availableCharacters.length,
        itemBuilder: (context, index) {
          final character = availableCharacters[index];
          final canDeploy = _canDeployCharacter(character);
          
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: _buildCharacterButton(character, canDeploy),
          );
        },
      ),
    );
  }

  Widget _buildCharacterButton(Character character, bool canDeploy) {
    return GestureDetector(
      onTap: canDeploy ? () => _deployCharacter(character) : null,
      onLongPress: () => _showCharacterDetail(character),
      child: Opacity(
        opacity: canDeploy ? 1.0 : 0.5,
        child: Container(
          width: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: canDeploy ? Colors.white : Colors.grey[300],
            border: Border.all(
              color: canDeploy ? Colors.brown[600]! : Colors.grey[400]!,
              width: 2,
            ),
            boxShadow: canDeploy ? [
              BoxShadow(
                color: Colors.brown.withOpacity(0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ] : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // キャラクターアイコン（今後画像に置き換え可能）
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: canDeploy ? Colors.orange[300] : Colors.grey[400],
                ),
                child: Icon(
                  Icons.restaurant,
                  color: canDeploy ? Colors.white : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              
              // キャラクター名
              Text(
                character.name,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: canDeploy ? Colors.brown[800] : Colors.grey[600],
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              // パワーコスト表示
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: canDeploy ? Colors.yellow[400] : Colors.grey[400],
                ),
                child: Text(
                  '${character.powerCost}',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: canDeploy ? Colors.brown[800] : Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOven() {
    return AnimatedBuilder(
      animation: _ovenAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _ovenAnimation.value,
          child: Container(
            width: 150,
            height: 180,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(3, 6),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                'lib/img/kama.png',
                width: 150,
                height: 180,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  // 画像が見つからない場合のフォールバック
                  return Container(
                    width: 150,
                    height: 180,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.brown[400]!,
                          Colors.brown[700]!,
                        ],
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 80,
                          height: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.black87,
                            border: Border.all(color: Colors.brown[300]!, width: 3),
                          ),
                          child: const Icon(
                            Icons.local_fire_department,
                            color: Colors.orange,
                            size: 36,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'パン窯',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDeployedCharacter(DeployedCharacter deployedChar) {
    return AnimatedBuilder(
      animation: deployedChar.animationController,
      builder: (context, child) {
        final bounceOffset = deployedChar.bounceAnimation?.value ?? 0.0;
        return Positioned(
          left: deployedChar.slideAnimation.value,
          top: deployedChar.y - bounceOffset,
          child: Transform.scale(
            scale: deployedChar.scaleAnimation.value,
            child: Container(
              width: 60,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
                border: Border.all(color: Colors.brown[600]!, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // キャラクターアイコン
                  Container(
                    width: 35,
                    height: 35,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.orange[300],
                    ),
                    child: const Icon(
                      Icons.restaurant,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(height: 4),
                  
                  // キャラクター名
                  Text(
                    deployedChar.character.name,
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      color: Colors.brown[800],
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  // HP表示
                  Container(
                    width: 45,
                    height: 6,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      color: Colors.grey[300],
                    ),
                    child: FractionallySizedBox(
                      widthFactor: deployedChar.character.currentHp / deployedChar.character.maxHp,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3),
                          color: Colors.red[400],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEnemyCastle() {
    return Container(
      width: 120,
      height: 150,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(-2, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(
          'lib/img/enemyCastle.png',
          width: 120,
          height: 150,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            // 画像が見つからない場合のフォールバック
            return Container(
              width: 120,
              height: 150,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.red[800]!,
                    Colors.red[900]!,
                  ],
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.castle,
                    color: Colors.white,
                    size: 40,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '敵の城',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSpawnedEnemy(SpawnedEnemy spawnedEnemy) {
    return AnimatedBuilder(
      animation: spawnedEnemy.animationController,
      builder: (context, child) {
        return Positioned(
          left: spawnedEnemy.x + spawnedEnemy.moveAnimation.value,
          top: spawnedEnemy.y,
          child: Transform.scale(
            scale: spawnedEnemy.scaleAnimation.value * spawnedEnemy.enemy.sizeMultiplier,
            child: Container(
              width: 50,
              height: 60,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  spawnedEnemy.enemy.imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    // 画像が見つからない場合のフォールバック
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.red[400],
                        border: Border.all(color: Colors.red[800]!, width: 2),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 20,
                          ),
                          Text(
                            spawnedEnemy.enemy.size.name[0].toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
