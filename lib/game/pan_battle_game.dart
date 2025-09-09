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
  final VoidCallback? onGameEnd;
  
  PanBattleGame({this.onGameEnd});
  
  // ゲーム状態
  int yeastPower = 0;
  int maxYeastPower = 100;
  int yeastRegenRate = 10; // 2 × 5 = 10（5倍速）
  
  // 城のHP
  int playerCastleHp = 1000;
  int maxPlayerCastleHp = 1000;
  int enemyCastleHp = 1000;
  int maxEnemyCastleHp = 1000;
  
  // ゲーム終了状態
  bool isGameOver = false;
  bool isPlayerWin = false;
  
  // タイマー
  double yeastTimerCounter = 0;
  double enemySpawnTimerCounter = 0;
  
  // UI コンポーネント
  late TextComponent yeastPowerText;
  late TextComponent playerCastleHpText;
  late TextComponent enemyCastleHpText;
  
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
    
    // 初期HPバーを設定
    _updateCastleHpDisplay();
  }
  
  late CastleComponent playerCastle;
  
  Future<void> _addOven() async {
    playerCastle = CastleComponent(
      spritePath: 'kama.png',
      castleSize: Vector2(180, 220),
      castlePosition: Vector2(20, 100),
      isPlayerCastle: true,
    );
    add(playerCastle);
  }
  
  late CastleComponent enemyCastle;
  
  Future<void> _addEnemyCastle() async {
    enemyCastle = CastleComponent(
      spritePath: 'enemyCastle.png',
      castleSize: Vector2(200, 250),
      castlePosition: Vector2(gameWidth - 220, 50),
      isPlayerCastle: false,
    );
    add(enemyCastle);
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
    
    // プレイヤー城のHP表示
    playerCastleHpText = TextComponent(
      text: 'パン窯HP: $playerCastleHp / $maxPlayerCastleHp',
      position: Vector2(20, 50),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.blue,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    add(playerCastleHpText);
    
    // 敵城のHP表示
    enemyCastleHpText = TextComponent(
      text: '敵城HP: $enemyCastleHp / $maxEnemyCastleHp',
      position: Vector2(gameWidth - 250, 20),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.red,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    add(enemyCastleHpText);
    
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
    
    // ゲームオーバー時は処理を停止
    if (isGameOver) return;
    
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
  
  void _updateCastleHpDisplay() {
    playerCastleHpText.text = 'パン窯HP: $playerCastleHp / $maxPlayerCastleHp';
    enemyCastleHpText.text = '敵城HP: $enemyCastleHp / $maxEnemyCastleHp';
    
    // HPバーを更新
    playerCastle.updateHpBar(playerCastleHp, maxPlayerCastleHp);
    enemyCastle.updateHpBar(enemyCastleHp, maxEnemyCastleHp);
    
    // 勝敗判定
    _checkGameOver();
  }
  
  void _checkGameOver() {
    if (isGameOver) return;
    
    if (enemyCastleHp <= 0) {
      // プレイヤー勝利
      isGameOver = true;
      isPlayerWin = true;
      _showGameOverScreen();
    } else if (playerCastleHp <= 0) {
      // プレイヤー敗北
      isGameOver = true;
      isPlayerWin = false;
      _showGameOverScreen();
    }
  }
  
  void _showGameOverScreen() {
    // 薄いグレーのオーバーレイ
    final overlay = RectangleComponent(
      size: size,
      paint: Paint()..color = Colors.black.withOpacity(0.7),
    );
    add(overlay);
    
    // 勝利/敗北メッセージ
    final messageText = TextComponent(
      text: isPlayerWin ? '勝利！' : '敗北...',
      position: Vector2(size.x / 2, size.y / 2 - 50),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: TextStyle(
          color: isPlayerWin ? Colors.yellow : Colors.red,
          fontSize: 48,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    add(messageText);
    
    // ホームへ戻るボタン
    final homeButton = RectangleComponent(
      size: Vector2(200, 60),
      position: Vector2(size.x / 2 - 100, size.y / 2 + 20),
      paint: Paint()..color = Colors.brown,
    );
    add(homeButton);
    
    final homeButtonText = TextComponent(
      text: 'ホームへ戻る',
      position: Vector2(size.x / 2, size.y / 2 + 50),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    add(homeButtonText);
  }
  
  void _deployCharacter(Character character) {
    if (yeastPower >= character.powerCost) {
      yeastPower -= character.powerCost;
      _updateYeastPowerDisplay();
      
      // キャラクターを配置 - 全て同じY座標（横列）
      final deployedChar = DeployedCharacterComponent(
        character: character,
        position: Vector2(170, 250), // 固定Y座標
      );
      add(deployedChar);
    }
  }
  
  void _spawnEnemy() {
    final enemy = EnemyData.getRandomEnemy();
    final spawnedEnemy = SpawnedEnemyComponent(
      enemy: enemy,
      position: Vector2(gameWidth - 200, 250), // キャラクターと同じY座標
    );
    add(spawnedEnemy);
  }
  
  @override
  bool onTapDown(TapDownInfo info) {
    if (isGameOver) {
      // ホームボタンの領域をチェック（画面中央のボタン）
      final buttonArea = Rect.fromCenter(
        center: Offset(size.x / 2, size.y / 2 + 50),
        width: 200,
        height: 60,
      );
      
      if (buttonArea.contains(info.eventPosition.global.toOffset())) {
        // ホーム画面に戻る
        onGameEnd?.call();
        return true;
      }
    }
    return false;
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
    
    // キャラクター画像
    final characterSprite = SpriteComponent(
      sprite: await Sprite.load(character.imagePath),
      size: Vector2(50, 50),
      position: Vector2(size.x / 2, 45),
      anchor: Anchor.center,
    );
    add(characterSprite);
    
    // キャラクター名
    nameText = TextComponent(
      text: character.name,
      position: Vector2(size.x / 2, 15),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: TextStyle(
          color: Colors.brown.shade800,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    add(nameText);
    
    // パワーコスト
    costText = TextComponent(
      text: character.powerCost.toString(),
      position: Vector2(size.x / 2, 85),
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
class DeployedCharacterComponent extends SpriteComponent {
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
    // キャラクター画像を設定
    sprite = await Sprite.load(character.imagePath);
  }
  
  @override
  void update(double dt) {
    super.update(dt);
    
    if (!isInBattle) {
      // 右に移動（城の前で止まる）
      final castleX = (parent as PanBattleGame).gameWidth - 220; // 城の位置
      if (position.x < castleX - 50) { // 城の50px手前で止まる
        position.x += speed * dt;
      } else {
        // 城に到達したら攻撃開始
        isInBattle = true;
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
    
    final currentTime = DateTime.now().millisecondsSinceEpoch / 1000.0;
    
    if (enemies.isNotEmpty) {
      // 敵がいる場合は敵を攻撃
      for (final enemy in enemies) {
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
    } else {
      // 敵がいない場合は城を攻撃
      if (currentTime - lastAttackTime > 1.5) {
        lastAttackTime = currentTime;
        final game = parent as PanBattleGame;
        game.enemyCastleHp -= character.attackPower;
        if (game.enemyCastleHp < 0) game.enemyCastleHp = 0;
        game._updateCastleHpDisplay();
      }
    }
  }
}

// スポーンされた敵コンポーネント
class SpawnedEnemyComponent extends SpriteComponent {
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
    // 敵キャラクター画像を設定
    sprite = await Sprite.load(enemy.imagePath);
  }
  
  @override
  void update(double dt) {
    super.update(dt);
    
    if (!isInBattle) {
      // 左に移動（パン窯の前で止まる）
      final ovenX = 20 + 180; // パン窯の右端位置（新しいサイズに合わせて調整）
      if (position.x > ovenX + 50) { // パン窯の50px右で止まる
        position.x -= speed * dt;
      } else {
        // パン窯に到達したら攻撃開始
        isInBattle = true;
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
    
    final currentTime = DateTime.now().millisecondsSinceEpoch / 1000.0;
    
    if (allies.isNotEmpty) {
      // 味方がいる場合は味方を攻撃
      for (final ally in allies) {
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
    } else {
      // 味方がいない場合はパン窯を攻撃
      if (currentTime - lastAttackTime > 2.0) {
        lastAttackTime = currentTime;
        final game = parent as PanBattleGame;
        game.playerCastleHp -= enemy.attackPower;
        if (game.playerCastleHp < 0) game.playerCastleHp = 0;
        game._updateCastleHpDisplay();
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

// 城コンポーネント（HPバー付き）
class CastleComponent extends Component {
  final String spritePath;
  final Vector2 castleSize;
  final Vector2 castlePosition;
  final bool isPlayerCastle;
  late SpriteComponent castle;
  late RectangleComponent hpBarBackground;
  late RectangleComponent hpBarForeground;
  
  CastleComponent({
    required this.spritePath,
    required this.castleSize,
    required this.castlePosition,
    required this.isPlayerCastle,
  });
  
  @override
  Future<void> onLoad() async {
    // 城のスプライト
    castle = SpriteComponent(
      sprite: await Sprite.load(spritePath),
      size: castleSize,
      position: castlePosition,
    );
    add(castle);
    
    // HPバーの背景
    hpBarBackground = RectangleComponent(
      size: Vector2(castleSize.x * 0.8, 10),
      position: Vector2(
        castlePosition.x + castleSize.x * 0.1,
        castlePosition.y - 18,
      ),
      paint: Paint()..color = Colors.black,
    );
    add(hpBarBackground);
    
    // HPバーの前景
    hpBarForeground = RectangleComponent(
      size: Vector2(castleSize.x * 0.8, 8),
      position: Vector2(
        castlePosition.x + castleSize.x * 0.1 + 1,
        castlePosition.y - 17,
      ),
      paint: Paint()..color = Colors.green,
    );
    add(hpBarForeground);
  }
  
  void updateHpBar(int currentHp, int maxHp) {
    final hpRatio = currentHp / maxHp;
    
    // HPバーの幅を更新（内側のパディングを考慮）
    hpBarForeground.size.x = (castleSize.x * 0.8 - 2) * hpRatio;
    
    // HPに応じて色を変更
    Color barColor;
    if (hpRatio > 0.6) {
      barColor = Colors.green;
    } else if (hpRatio > 0.3) {
      barColor = Colors.orange;
    } else {
      barColor = Colors.red;
    }
    hpBarForeground.paint.color = barColor;
  }
}
