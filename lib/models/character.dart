class Character {
  final String name;
  final int maxHp;
  final int attackPower;
  final int powerCost;
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

  void takeDamage(int damage) {
    currentHp = (currentHp - damage).clamp(0, maxHp);
  }

  void heal(int amount) {
    currentHp = (currentHp + amount).clamp(0, maxHp);
  }

  String get displayImagePath => isUnlocked ? imagePath : (lockedImagePath ?? imagePath);

  Character copyWith({
    String? name,
    int? maxHp,
    int? attackPower,
    int? powerCost,
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
