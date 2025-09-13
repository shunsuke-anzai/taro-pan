class Character {
  final String name;
  final int maxHp;
  final int attackPower;
  final int powerCost;
  int level; // キャラクターレベル
  final String description;
  final String imagePath;
  final String? lockedImagePath;
  final String walkAnimationPath; // 横移動アニメーション
  final String attackAnimationPath; // 攻撃アニメーション
  final bool isAreaAttack; // 範囲攻撃かどうか
  final double attackRange; // 攻撃範囲（範囲攻撃の場合のみ使用）
  final bool isUnlocked; // アンロックフラグ
  final int rarity; // レアリティ（星の数）
  int currentHp;

  Character({
    required this.name,
    required this.maxHp,
    required this.attackPower,
    required this.powerCost,
    this.level = 1, // デフォルトはレベル1
    required this.description,
    required this.imagePath,
    this.lockedImagePath,
    required this.walkAnimationPath,
    required this.attackAnimationPath,
    this.isAreaAttack = false, // デフォルトは単体攻撃
    this.attackRange = 50.0, // デフォルト攻撃範囲
    this.isUnlocked = true, // デフォルトはアンロック済み
    this.rarity = 3, // デフォルトは星3
  }) : currentHp = maxHp;

  bool get isAlive => currentHp > 0;

  // レベルに応じた実際のステータス値を計算（5%ずつ増加）
  int get actualMaxHp => (maxHp * (1.0 + (level - 1) * 0.05)).round();
  int get actualAttackPower => (attackPower * (1.0 + (level - 1) * 0.05)).round();

  void takeDamage(int damage) {
    currentHp = (currentHp - damage).clamp(0, actualMaxHp);
  }

  void heal(int amount) {
    currentHp = (currentHp + amount).clamp(0, actualMaxHp);
  }

  String get displayImagePath => isUnlocked ? imagePath : (lockedImagePath ?? imagePath);

  Character copyWith({
    String? name,
    int? maxHp,
    int? attackPower,
    int? powerCost,
    int? level,
    String? description,
    String? imagePath,
    String? lockedImagePath,
    String? walkAnimationPath,
    String? attackAnimationPath,
    bool? isAreaAttack,
    double? attackRange,
    bool? isUnlocked,
    int? rarity,
    int? currentHp,
  }) {
    return Character(
      name: name ?? this.name,
      maxHp: maxHp ?? this.maxHp,
      attackPower: attackPower ?? this.attackPower,
      powerCost: powerCost ?? this.powerCost,
      level: level ?? this.level,
      description: description ?? this.description,
      imagePath: imagePath ?? this.imagePath,
      lockedImagePath: lockedImagePath ?? this.lockedImagePath,
      walkAnimationPath: walkAnimationPath ?? this.walkAnimationPath,
      attackAnimationPath: attackAnimationPath ?? this.attackAnimationPath,
      isAreaAttack: isAreaAttack ?? this.isAreaAttack,
      attackRange: attackRange ?? this.attackRange,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      rarity: rarity ?? this.rarity,
    )..currentHp = currentHp ?? this.currentHp;
  }
}
