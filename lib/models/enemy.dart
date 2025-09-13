

enum EnemySize { small, middle, big }

class Enemy {
  final String name;
  final int maxHp;
  final int attackPower;
  final double speed; // 移動速度（pixel/秒）
  final EnemySize size;
  final String imagePath;
  int currentHp;

  Enemy({
    required this.name,
    required this.maxHp,
    required this.attackPower,
    required this.speed,
    required this.size,
    required this.imagePath,
  }) : currentHp = maxHp;

  bool get isAlive => currentHp > 0;

  void takeDamage(int damage) {
    currentHp = (currentHp - damage).clamp(0, maxHp);
  }

  double get sizeMultiplier {
    switch (size) {
      case EnemySize.small:
        return 0.6;
      case EnemySize.middle:
        return 1.0;
      case EnemySize.big:
        return 1.8;
    }
  }
}
