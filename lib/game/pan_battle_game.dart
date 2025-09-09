import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import '../models/character.dart';
import '../models/enemy.dart';
import '../data/game_data.dart';
import '../data/enemy_data.dart';

class PanBattleGame extends FlameGame with TapDetector, HasGameRef {
  late double gameWidth;
  late double gameHeight;
  
  // ゲーム状態
  int yeastPower = 0;
  int maxYeastPower = 100;
  int yeastRegenRate = 2;
  
  // タイマー
  double yeastTimerCounter = 0;
  double enemySpawnTimerCounter = 0;
  
  // UI コンポーネント
  late TextComponent yeastPowerText;
  
  @override
  Future<void> onLoad() async {
    gameWidth = size.x;
    gameHeight = size.y;
    
    // 背景設定
    add(RectangleComponent(
      size: size,
      paint: Paint()..color = Colors.lightGreen.shade50,
    ));
    
    // パン窯を追加
    await _addOven();
    
    // 敵の城を追加
    await _addEnemyCastle();
    
    // UIを追加
    await _addUI();
  }
  
  Future<void> _addOven() async {
    final oven = SpriteComponent(
      sprite: await Sprite.load('kama.png'),
      size: Vector2(150, 180),
      position: Vector2(20, 120),
    );
    add(oven);
  }
  
  Future<void> _addEnemyCastle() async {
    final castle = SpriteComponent(
      sprite: await Sprite.load('enemyCastle.png'),
      size: Vector2(120, 150),
      position: Vector2(gameWidth - 140, 100),
    );
    add(castle);
  }
  
  Future<void> _addUI() async {
    // イーストパワー表示
    yeastPowerText = TextComponent(
      text: 'イーストパワー: $yeastPower / $maxYeastPower',
      position: Vector2(20, 20),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.brown,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    add(yeastPowerText);
    
    // キャラクター選択ボタンを追加
    await _addCharacterButtons();
  }
  
  Future<void> _addCharacterButtons() async {
    final characters = GameData.getAllCharacters();
    
    for (int i = 0; i < characters.length; i++) {
      final button = CharacterButton(
        character: characters[i],
        position: Vector2(20 + i * 110.0, gameHeight - 120),
        onTap: () => _deployCharacter(characters[i]),
        game: this,
      );
      add(button);
    }
  }
  
  @override
  void update(double dt) {
    super.update(dt);
    
    // イーストパワー回復
    yeastTimerCounter += dt;
    if (yeastTimerCounter >= 1.0) {
      yeastTimerCounter = 0;
      if (yeastPower < maxYeastPower) {
        yeastPower += yeastRegenRate;
        if (yeastPower > maxYeastPower) yeastPower = maxYeastPower;
        _updateYeastPowerDisplay();
      }
    }
    
    // 敵スポーン
    enemySpawnTimerCounter += dt;
    if (enemySpawnTimerCounter >= 5.0) {
      enemySpawnTimerCounter = 0;
      _spawnEnemy();
    }
  }
  
  void _updateYeastPowerDisplay() {
    yeastPowerText.text = 'イーストパワー: $yeastPower / $maxYeastPower';
  }
  
  void _deployCharacter(Character character) {
    if (yeastPower >= character.powerCost) {
      yeastPower -= character.powerCost;
      _updateYeastPowerDisplay();
      
      // キャラクターを配置
      final deployedChar = DeployedCharacterComponent(
        character: character,
        position: Vector2(170, 200 + (children.whereType<DeployedCharacterComponent>().length * 70)),
      );
      add(deployedChar);
    }
  }
  
  void _spawnEnemy() {
    final enemy = EnemyData.getRandomEnemy();
    final spawnedEnemy = SpawnedEnemyComponent(
      enemy: enemy,
      position: Vector2(gameWidth - 200, 200 + (children.whereType<SpawnedEnemyComponent>().length % 3 * 60)),
    );
    add(spawnedEnemy);
  }
}

// キャラクターボタンコンポーネント
class CharacterButton extends RectangleComponent with TapCallbacks {
  final Character character;
  final VoidCallback onTap;
  final PanBattleGame game;
  late TextComponent nameText;
  late TextComponent costText;
  
  CharacterButton({
    required this.character,
    required Vector2 position,
    required this.onTap,
    required this.game,
  }) : super(
    size: Vector2(100, 100),
    position: position,
  );
  
  @override
  Future<void> onLoad() async {
    // ボタンの背景
    paint = Paint()..color = game.yeastPower >= character.powerCost 
        ? Colors.white 
        : Colors.grey.shade300;
    
    // キャラクター名
    nameText = TextComponent(
      text: character.name,
      position: Vector2(size.x / 2, 20),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: TextStyle(
          color: Colors.brown.shade800,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    add(nameText);
    
    // パワーコスト
    costText = TextComponent(
      text: character.powerCost.toString(),
      position: Vector2(size.x / 2, 80),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: TextStyle(
          color: Colors.brown.shade800,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    add(costText);
  }
  
  @override
  void update(double dt) {
    super.update(dt);
    // ボタンの有効/無効状態を更新
    paint = Paint()..color = game.yeastPower >= character.powerCost 
        ? Colors.white 
        : Colors.grey.shade300;
  }
  
  @override
  bool onTapDown(TapDownEvent event) {
    if (game.yeastPower >= character.powerCost) {
      onTap();
      return true;
    }
    return false;
  }
}

// 配置されたキャラクターコンポーネント
class DeployedCharacterComponent extends RectangleComponent {
  final Character character;
  double speed = 30.0; // 移動速度
  bool isInBattle = false;
  double lastAttackTime = 0;
  
  DeployedCharacterComponent({
    required this.character,
    required Vector2 position,
  }) : super(
    size: Vector2(60, 80),
    position: position,
  );
  
  @override
  Future<void> onLoad() async {
    paint = Paint()..color = Colors.orange.shade300;
    
    // キャラクター名を表示
    final nameText = TextComponent(
      text: character.name,
      position: Vector2(size.x / 2, size.y - 10),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 8,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    add(nameText);
  }
  
  @override
  void update(double dt) {
    super.update(dt);
    
    if (!isInBattle) {
      // 右に移動
      position.x += speed * dt;
      
      // 画面外に出たら削除
      if (position.x > (parent as PanBattleGame).gameWidth) {
        removeFromParent();
      }
    }
    
    // 敵との衝突判定
    _checkCollisions();
  }
  
  void _checkCollisions() {
    final enemies = parent!.children.whereType<SpawnedEnemyComponent>();
    for (final enemy in enemies) {
      if (!enemy.isInBattle && !isInBattle) {
        final distance = position.distanceTo(enemy.position);
        if (distance < 50) {
          // 戦闘開始
          isInBattle = true;
          enemy.isInBattle = true;
          break;
        }
      }
    }
    
    // 戦闘処理
    if (isInBattle) {
      _processBattle();
    }
  }
  
  void _processBattle() {
    final enemies = parent!.children.whereType<SpawnedEnemyComponent>()
        .where((e) => e.isInBattle && position.distanceTo(e.position) < 100);
    
    for (final enemy in enemies) {
      final currentTime = DateTime.now().millisecondsSinceEpoch / 1000.0;
      
      // 1.5秒間隔で攻撃
      if (currentTime - lastAttackTime > 1.5) {
        lastAttackTime = currentTime;
        enemy.enemy.takeDamage(character.attackPower);
        
        if (!enemy.enemy.isAlive) {
          enemy.die();
          isInBattle = false;
        }
      }
    }
  }
}

// スポーンされた敵コンポーネント
class SpawnedEnemyComponent extends RectangleComponent {
  final Enemy enemy;
  double speed = 50.0; // 移動速度
  bool isInBattle = false;
  double lastAttackTime = 0;
  
  SpawnedEnemyComponent({
    required this.enemy,
    required Vector2 position,
  }) : super(
    size: Vector2(50, 60),
    position: position,
  );
  
  @override
  Future<void> onLoad() async {
    paint = Paint()..color = Colors.red.shade400;
    
    // 敵名を表示
    final nameText = TextComponent(
      text: enemy.name,
      position: Vector2(size.x / 2, size.y - 10),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 8,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    add(nameText);
  }
  
  @override
  void update(double dt) {
    super.update(dt);
    
    if (!isInBattle) {
      // 左に移動
      position.x -= speed * dt;
      
      // 画面外に出たら削除
      if (position.x < -size.x) {
        removeFromParent();
      }
    }
    
    // 戦闘処理
    if (isInBattle) {
      _processBattle();
    }
  }
  
  void _processBattle() {
    final allies = parent!.children.whereType<DeployedCharacterComponent>()
        .where((a) => a.isInBattle && position.distanceTo(a.position) < 100);
    
    for (final ally in allies) {
      final currentTime = DateTime.now().millisecondsSinceEpoch / 1000.0;
      
      // 2秒間隔で攻撃
      if (currentTime - lastAttackTime > 2.0) {
        lastAttackTime = currentTime;
        ally.character.takeDamage(enemy.attackPower);
        
        if (!ally.character.isAlive) {
          ally.removeFromParent();
          isInBattle = false;
        }
      }
    }
  }
  
  void die() {
    // 死亡エフェクト（簡単な実装）
    add(ScaleEffect.to(
      Vector2.zero(),
      LinearEffectController(0.5),
      onComplete: () => removeFromParent(),
    ));
  }
}
