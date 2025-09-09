import '../models/enemy.dart';

class EnemyData {
  static List<Enemy> getAllEnemies() {
    return [
      Enemy(
        name: '小麦パン兵',
        maxHp: 50,
        attackPower: 10,
        speed: 30.0, // ゆっくり
        size: EnemySize.small,
        imagePath: 'enemySmall.png',
      ),
      Enemy(
        name: 'ライ麦戦士',
        maxHp: 120,
        attackPower: 25,
        speed: 20.0, // 普通
        size: EnemySize.middle,
        imagePath: 'enemyMiddle.png',
      ),
      Enemy(
        name: '全粒粉巨人',
        maxHp: 300,
        attackPower: 50,
        speed: 15.0, // 遅い
        size: EnemySize.big,
        imagePath: 'enemyBig.png',
      ),
    ];
  }

  static Enemy getRandomEnemy() {
    final enemies = getAllEnemies();
    final random = DateTime.now().millisecondsSinceEpoch % enemies.length;
    return enemies[random];
  }
}
