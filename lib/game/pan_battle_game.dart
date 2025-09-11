// pan_battle_game.dart

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import 'package:flame_rive/flame_rive.dart';
import '../models/character.dart';
import '../models/enemy.dart';
import '../data/game_data.dart';
import '../data/enemy_data.dart';

class PanBattleGame extends FlameGame with TapDetector, HasGameReference {
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
    // 元の単色背景のコードをコメントアウトまたは削除
    // add(RectangleComponent(
    //   size: size,
    //   paint: Paint()..color = Colors.lightGreen.shade50,
    // ));

    // 新しい背景画像を追加するコード
    final backgroundSprite = await Sprite.load('battle_ground.png');
    final backgroundComponent = SpriteComponent(
      sprite: backgroundSprite,
      size: size,
      // 画像が画面いっぱいに広がるようにサイズを設定
    );
    add(backgroundComponent);
    
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
      castleSize: Vector2(357, 259), // 正方形にして元画像の比率を保持
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
    // イーストパワーの現在値（分子）を大きく表示
    yeastPowerText = TextComponent(
      text: '$yeastPower',
      position: Vector2(20, gameHeight - 100),
      textRenderer: TextPaint(
        style: TextStyle(
          color: Colors.yellow,
          fontSize: 80, // ボタンの縦幅と同じサイズ
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              color: Colors.white,
              offset: Offset(-2, -2),
              blurRadius: 0,
            ),
            Shadow(
              color: Colors.white,
              offset: Offset(2, -2),
              blurRadius: 0,
            ),
            Shadow(
              color: Colors.white,
              offset: Offset(-2, 2),
              blurRadius: 0,
            ),
            Shadow(
              color: Colors.white,
              offset: Offset(2, 2),
              blurRadius: 0,
            ),
          ],
        ),
      ),
    );
    add(yeastPowerText);
    
    // イーストパワーの最大値（分母）を小さく表示
    final maxYeastText = TextComponent(
      text: '/ $maxYeastPower',
      position: Vector2(100, gameHeight - 40),
      textRenderer: TextPaint(
        style: TextStyle(
          color: Colors.yellow,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              color: Colors.white,
              offset: Offset(-1, -1),
              blurRadius: 0,
            ),
            Shadow(
              color: Colors.white,
              offset: Offset(1, -1),
              blurRadius: 0,
            ),
            Shadow(
              color: Colors.white,
              offset: Offset(-1, 1),
              blurRadius: 0,
            ),
            Shadow(
              color: Colors.white,
              offset: Offset(1, 1),
              blurRadius: 0,
            ),
          ],
        ),
      ),
    );
    add(maxYeastText);
    
    // キャラクター選択ボタンを追加
    await _addCharacterButtons();
  }
  
  Future<void> _addCharacterButtons() async {
    final characters = GameData.getAllCharacters();
    
    // ボタンサイズをさらに1.2倍に設定
    final buttonWidth = 122.4;  // 102 * 1.2
    final buttonSpacing = 136.8;  // 114 * 1.2
    
    // 右詰め配置のための開始位置を計算
    final totalWidth = (characters.length - 1) * buttonSpacing + buttonWidth;
    final startX = gameWidth - totalWidth - 20; // 20pxのマージン
    
    for (int i = 0; i < characters.length; i++) {
      final button = CharacterButton(
        character: characters[i],
        position: Vector2(startX + i * buttonSpacing, gameHeight - 100),
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
    
    // イーストパワー回復（1刻みずつ滑らかに）
    yeastTimerCounter += dt;
    if (yeastTimerCounter >= 0.1) { // 0.1秒ごとに1ずつ増加
      yeastTimerCounter = 0;
      if (yeastPower < maxYeastPower) {
        yeastPower += 1; // 1ずつ増加
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
    yeastPowerText.text = '$yeastPower';
  }
  
  void _updateCastleHpDisplay() {
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
      paint: Paint()..color = Colors.black.withValues(alpha: 0.7),
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
        position: Vector2(170, 180), // Y座標を少し低く調整
      );
      add(deployedChar);
    }
  }
  
  void _spawnEnemy() {
    final enemy = EnemyData.getRandomEnemy();
    final spawnedEnemy = SpawnedEnemyComponent(
      enemy: enemy,
      position: Vector2(gameWidth - 200, 180), // キャラクターと同じY座標
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
  late TextComponent costText;
  
  CharacterButton({
    required this.character,
    required Vector2 position,
    required this.onTap,
    required this.game,
  }) : super(
    size: Vector2(122.4, 80), // 横幅をさらに1.2倍に
    position: position,
  );
  
  @override
  Future<void> onLoad() async {
    // 角丸のオレンジ色背景
    paint = Paint()..color = game.yeastPower >= character.powerCost 
        ? Colors.orange 
        : Colors.grey.shade400;
    
    // キャラクター画像（名前を削除してサイズを大きく）
    final characterSprite = SpriteComponent(
      sprite: await Sprite.load(character.imagePath),
      size: Vector2(55, 55), // サイズを大きく
      position: Vector2(size.x / 2, 30), // 位置を調整
      anchor: Anchor.center,
    );
    add(characterSprite);
    
    // キャラクター名
    final nameText = TextComponent(
      text: character.name,
      position: Vector2(size.x / 2, 65), // 位置を下に調整
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: TextStyle(
          color: Colors.brown.shade800,
          fontSize: 10, // 名前なので少し小さく
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    add(nameText);
    
    // パワーコスト（右下に円で囲む）
    costText = TextComponent(
      text: character.powerCost.toString(),
      position: Vector2(size.x - 15, size.y - 15), // 右下
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    add(costText);
  }
  
  @override
  void render(Canvas canvas) {
    // 角丸の背景を描画
    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(8.0));
    
    // 背景色を描画
    final backgroundPaint = Paint()
      ..color = game.yeastPower >= character.powerCost 
          ? Colors.orange 
          : Colors.grey.shade400
      ..style = PaintingStyle.fill;
    canvas.drawRRect(rrect, backgroundPaint);
    
    // 白い枠線を描画（太く）
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;  // 2.0から4.0に太く
    canvas.drawRRect(rrect, borderPaint);
    
    // コスト表示用の円を描画（右下）
    final circlePaint = Paint()
      ..color = Colors.brown.shade700
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(size.x - 15, size.y - 15),
      12,
      circlePaint,
    );
    
    // 円の枠線
    final circleStrokePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(
      Offset(size.x - 15, size.y - 15),
      12,
      circleStrokePaint,
    );
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
class DeployedCharacterComponent extends PositionComponent {
  final Character character;
  double speed = 30.0; // 移動速度
  bool isInBattle = false;
  double lastAttackTime = 0;
  late RiveComponent walkRiveComponent;
  late RiveComponent attackRiveComponent;
  RiveComponent? currentRiveComponent;
  bool isWalking = false;
  bool isAttacking = false;
  
  DeployedCharacterComponent({
    required this.character,
    required Vector2 position,
  }) : super(
    size: Vector2(80, 100),
    position: position,
  );
  
  @override
  Future<void> onLoad() async {
    // 歩行アニメーションを読み込み
    final walkRiveFile = await RiveFile.asset(character.walkAnimationPath);
    final walkArtboard = walkRiveFile.mainArtboard;
    walkArtboard.addController(SimpleAnimation('Timeline 1'));
    walkRiveComponent = RiveComponent(
      artboard: walkArtboard,
      size: Vector2(80, 100),
      anchor: Anchor.bottomCenter,
    );
    
    // 攻撃アニメーションを読み込み
    final attackRiveFile = await RiveFile.asset(character.attackAnimationPath);
    final attackArtboard = attackRiveFile.mainArtboard;
    attackArtboard.addController(SimpleAnimation('Timeline 1'));
    attackRiveComponent = RiveComponent(
      artboard: attackArtboard,
      size: Vector2(80, 100),
      anchor: Anchor.bottomCenter,
    );
    
    // 初期状態では歩行アニメーションを表示
    currentRiveComponent = walkRiveComponent;
    add(currentRiveComponent!);
  }
  
  @override
  void update(double dt) {
    super.update(dt);
    
    if (!isInBattle) {
      bool shouldMove = true;
      
      if (character.name == 'クレッシェン') {
        // クレッシェンの場合：最も近い敵から300px離れた場所で停止
        final enemies = parent!.children.whereType<SpawnedEnemyComponent>();
        if (enemies.isNotEmpty) {
          double closestDistance = double.infinity;
          for (final enemy in enemies) {
            final distance = position.distanceTo(enemy.position);
            if (distance < closestDistance) {
              closestDistance = distance;
            }
          }
          
          // 最も近い敵から300px以内の場合は移動を停止
          if (closestDistance <= 300) {
            shouldMove = false;
            if (!isInBattle) {
              isInBattle = true; // 攻撃開始
            }
          }
        }
      }
      
      if (shouldMove) {
        // 右に移動（城の前で止まる）
        final castleX = (parent as PanBattleGame).gameWidth - 220; // 城の位置
        if (position.x < castleX - 50) { // 城の50px手前で止まる
          position.x += speed * dt;
          if (!isAttacking) {
            _startWalkAnimation();
          }
        } else {
          _stopWalkAnimation();
          if (!isInBattle) {
            // 城に到達したら攻撃開始（次フレームから）
            isInBattle = true;
          }
        }
      } else {
        if (!isAttacking) {
          _stopWalkAnimation();
        }
      }
    }
    
    // 敵との衝突判定
    _checkCollisions();
    
    // 戦闘処理
    if (isInBattle) {
      _processBattle();
    }
  }
  
  void _checkCollisions() {
    final enemies = parent!.children.whereType<SpawnedEnemyComponent>();
    for (final enemy in enemies) {
      // 味方が戦闘中でない場合のみ新しい戦闘を開始
      if (!isInBattle) {
        final distance = position.distanceTo(enemy.position);
        if (distance < 50) {
          // 戦闘開始
          isInBattle = true;
          // 敵が城を攻撃中でも、味方との戦闘を優先させる
          enemy.isInBattle = true;
          break;
        }
      }
    }
  }
  
  void _processBattle() {
    final enemies = parent!.children.whereType<SpawnedEnemyComponent>()
        .where((e) => e.isInBattle && position.distanceTo(e.position) < 100);
    
    final currentTime = DateTime.now().millisecondsSinceEpoch / 1000.0;
    
    if (enemies.isNotEmpty) {
      // 敵がいる場合は敵を攻撃
      if (currentTime - lastAttackTime > 1.5) {
        lastAttackTime = currentTime;
        
        _startAttackAnimation();
        
        if (character.isAreaAttack) {
          // 範囲攻撃の場合：範囲内のすべての敵を攻撃
          final allEnemies = parent!.children.whereType<SpawnedEnemyComponent>()
              .where((e) => position.distanceTo(e.position) < character.attackRange);
          
          bool anyEnemyDied = false;
          for (final enemy in allEnemies) {
            enemy.enemy.takeDamage(character.attackPower);
            if (!enemy.enemy.isAlive) {
              enemy.die();
              anyEnemyDied = true;
            }
          }
          
          if (anyEnemyDied) {
            isInBattle = false;
            lastAttackTime = currentTime;
            return;
          }
        } else {
          // 単体攻撃の場合：従来通り
          for (final enemy in enemies) {
            enemy.enemy.takeDamage(character.attackPower);
            
            if (!enemy.enemy.isAlive) {
              enemy.die();
              isInBattle = false;
              lastAttackTime = currentTime;
              return;
            }
          }
        }
      }
    } else {
      // 敵がいない場合
      final game = parent as PanBattleGame;
      final castleX = game.gameWidth - 220; // 城の位置
      
      if (position.x >= castleX - 50) {
        // 城に接近している場合は城を攻撃
        if (currentTime - lastAttackTime > 1.5) {
          lastAttackTime = currentTime;
          _startAttackAnimation();
          game.enemyCastleHp -= character.attackPower;
          if (game.enemyCastleHp < 0) game.enemyCastleHp = 0;
          game._updateCastleHpDisplay();
        }
      } else {
        // 城から離れている場合は戦闘状態をリセット（他の味方が敵を倒した可能性）
        isInBattle = false;
        lastAttackTime = currentTime;
      }
    }
  }
  
  void _startWalkAnimation() {
    if (!isWalking && !isAttacking) {
      isWalking = true;
      _switchToWalkAnimation();
    }
  }
  
  void _stopWalkAnimation() {
    if (isWalking) {
      isWalking = false;
    }
  }
  
  void _startAttackAnimation() {
    if (!isAttacking) {
      isAttacking = true;
      _switchToAttackAnimation();
      
      // 攻撃アニメーション終了後の処理
      Future.delayed(Duration(milliseconds: 1000), () {
        isAttacking = false;
        // 攻撃終了後は移動中のみ歩行アニメーションに戻す
        if (isWalking && !isInBattle) {
          _switchToWalkAnimation();
        }
      });
    }
  }
  
  void _switchToWalkAnimation() {
    if (currentRiveComponent != walkRiveComponent) {
      currentRiveComponent?.removeFromParent();
      currentRiveComponent = walkRiveComponent;
      add(currentRiveComponent!);
    }
  }
  
  void _switchToAttackAnimation() {
    if (currentRiveComponent != attackRiveComponent) {
      currentRiveComponent?.removeFromParent();
      currentRiveComponent = attackRiveComponent;
      add(currentRiveComponent!);
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
    size: Vector2(60, 75), // 敵のサイズも少し大きく
    position: position,
    anchor: Anchor.bottomCenter, // 敵も下基準に
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
    
    // 味方との衝突判定
    _checkCollisions();
    
    // 戦闘処理
    if (isInBattle) {
      _processBattle();
    }
  }
  
  void _checkCollisions() {
    final allies = parent!.children.whereType<DeployedCharacterComponent>();
    for (final ally in allies) {
      // 敵が戦闘中でない場合のみ新しい戦闘を開始
      if (!isInBattle) {
        final distance = position.distanceTo(ally.position);
        if (distance < 50) {
          // 戦闘開始
          isInBattle = true;
          // 味方が城を攻撃中でも、敵との戦闘を優先させる
          ally.isInBattle = true;
          break;
        }
      }
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
        if (!game.playerCastle.isPlayingDamageAnimation) {
          game.playerCastle.playDamageAnimation(); // ダメージアニメーション再生
        }
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
  RectangleComponent? hpBarBackground;
  RectangleComponent? hpBarForeground;
  RiveComponent? damageAnimation;
  bool isPlayingDamageAnimation = false;
  TimerComponent? damageAnimationTimer;
  
  CastleComponent({
    required this.spritePath,
    required this.castleSize,
    required this.castlePosition,
    required this.isPlayerCastle,
  });
  
  @override
  Future<void> onLoad() async {
    // 城のスプライト（元画像の比率を保持）
    final sprite = await Sprite.load(spritePath);
    castle = SpriteComponent(
      sprite: sprite,
      size: castleSize,
      position: castlePosition,
    );
    castle.scale = Vector2.all(1.0); // スケールを明示的に設定
    add(castle);
    
    // プレイヤーの城の場合のyakigamaアニメーションを準備
    if (isPlayerCastle) {
      final yakigamaFile = await RiveFile.asset('assets/animations/yakigama.riv');
      final yakigamaArtboard = yakigamaFile.mainArtboard;
      yakigamaArtboard.addController(SimpleAnimation('Timeline 1'));
      damageAnimation = RiveComponent(
        artboard: yakigamaArtboard,
        size: castleSize, // 城と同じサイズで比率保持
        position: castlePosition,
        anchor: Anchor.topLeft,
      );
      damageAnimation!.scale = Vector2.all(1.0); // スケールを明示的に設定
    }
    
    // HPバーの背景
    hpBarBackground = RectangleComponent(
      size: Vector2(castleSize.x * 0.8, 10),
      position: Vector2(
        castlePosition.x + castleSize.x * 0.1,
        castlePosition.y - 18,
      ),
      paint: Paint()..color = Colors.black,
    );
    add(hpBarBackground!);
    
    // HPバーの前景
    hpBarForeground = RectangleComponent(
      size: Vector2(castleSize.x * 0.8, 8),
      position: Vector2(
        castlePosition.x + castleSize.x * 0.1 + 1,
        castlePosition.y - 17,
      ),
      paint: Paint()..color = Colors.green,
    );
    add(hpBarForeground!);
  }
  
  void updateHpBar(int currentHp, int maxHp) {
    final hpRatio = currentHp / maxHp;
    if (hpBarForeground == null) return;
    // HPバーの幅を更新（内側のパディングを考慮）
    hpBarForeground!.size.x = (castleSize.x * 0.8 - 2) * hpRatio;
    // HPに応じて色を変更
    Color barColor;
    if (hpRatio > 0.6) {
      barColor = Colors.green;
    } else if (hpRatio > 0.3) {
      barColor = Colors.orange;
    } else {
      barColor = Colors.red;
    }
    hpBarForeground!.paint.color = barColor;
  }
  
  void playDamageAnimation() {
    if (isPlayerCastle && damageAnimation != null && !isPlayingDamageAnimation) {
      isPlayingDamageAnimation = true;
      
      // 既存のタイマーをキャンセル
      if (damageAnimationTimer != null) {
        damageAnimationTimer!.removeFromParent();
        damageAnimationTimer = null;
      }
      
      // スプライトを非表示にしてアニメーションを表示
      if (castle.parent != null) {
        castle.removeFromParent();
      }
      if (damageAnimation!.parent == null) {
        add(damageAnimation!);
      }
      
      // 2秒後にアニメーション終了してスプライトに戻す
      damageAnimationTimer = TimerComponent(
        period: 2.0,
        repeat: false,
        onTick: () {
          _endDamageAnimation();
        },
      );
      add(damageAnimationTimer!);
    }
  }
  
  void _endDamageAnimation() {
    if (isPlayingDamageAnimation) {
      // アニメーションを削除
      if (damageAnimation != null && damageAnimation!.parent != null) {
        damageAnimation!.removeFromParent();
      }
      
      // 城のスプライトを表示
      if (castle.parent == null) {
        add(castle);
      }
      
      // タイマーを削除
      if (damageAnimationTimer != null) {
        damageAnimationTimer!.removeFromParent();
        damageAnimationTimer = null;
      }
      
      // フラグをリセット
      isPlayingDamageAnimation = false;
    }
  }
}