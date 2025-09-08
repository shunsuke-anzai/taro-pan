class Character {
  final String name;
  final int maxHp;
  final int attackPower;
  final int powerCost;
  final String description;
  int currentHp;

  Character({
    required this.name,
    required this.maxHp,
    required this.attackPower,
    required this.powerCost,
    required this.description,
  }) : currentHp = maxHp;

  bool get isAlive => currentHp > 0;

  void takeDamage(int damage) {
    currentHp = (currentHp - damage).clamp(0, maxHp);
  }

  void heal(int amount) {
    currentHp = (currentHp + amount).clamp(0, maxHp);
  }

  Character copyWith({
    String? name,
    int? maxHp,
    int? attackPower,
    int? powerCost,
    String? description,
    int? currentHp,
  }) {
    return Character(
      name: name ?? this.name,
      maxHp: maxHp ?? this.maxHp,
      attackPower: attackPower ?? this.attackPower,
      powerCost: powerCost ?? this.powerCost,
      description: description ?? this.description,
    )..currentHp = currentHp ?? this.currentHp;
  }
}
