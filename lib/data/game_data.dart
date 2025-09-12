import '../models/character.dart';

class GameData {
  static List<Character> getAllCharacters() {
    return [
      Character(
        name: 'ぷくらん',
        maxHp: 500,
        attackPower: 50,
        powerCost: 30, // 10 × 3 = 30
        description: '基本的なパン戦士。バランスの取れた能力を持つ。',
        imagePath: 'pukuran.png',
        walkAnimationPath: 'assets/animations/walk_pukuran.riv',
        attackAnimationPath: 'assets/animations/attack_pukuran.riv',
      ),
      Character(
        name: 'バゲットン',
        maxHp: 150,
        attackPower: 35,
        powerCost: 75, // 25 × 3 = 75
        description: 'サクサクの装甲を持つ騎士。高い攻撃力が自慢。',
        imagePath: 'buggeton.png',
        walkAnimationPath: 'assets/animations/walk_buggeton.riv',
        attackAnimationPath: 'assets/animations/attack_buggeton.riv',
      ),
      Character(
        name: 'クレッシェン',
        maxHp: 80,
        attackPower: 45,
        powerCost: 90, // 30 × 3 = 90
        description: '甘い魔法を使う魔術師。高火力だが脆い。',
        imagePath: 'kuresshen.png',
        walkAnimationPath: 'assets/animations/walk_kuresshen.riv',
        attackAnimationPath: 'assets/animations/attack_kuresshen.riv',
        isAreaAttack: true, // 範囲攻撃
        attackRange: 175.0, // 範囲攻撃の範囲（175px）
      ),
      Character(
        name: 'あんまる',
        maxHp: 120,
        attackPower: 25,
        powerCost: 45, // 15 × 3 = 45
        description: '長いリーチを持つ槍兵。バランスの良い戦士。',
        imagePath: 'anmaru.png',
        walkAnimationPath: 'assets/animations/walk_anmaru.riv',
        attackAnimationPath: 'assets/animations/attack_anmaru.riv',
      ),
      Character(
        name: 'ダブルトングマン',
        maxHp: 90,
        attackPower: 30,
        powerCost: 60, // 20 × 3 = 60
        description: '素早い動きで敵を翻弄する忍者。',
        imagePath: 'doubletongman.png',
        walkAnimationPath: 'assets/animations/walk_doubletongman.riv',
        attackAnimationPath: 'assets/animations/attack_doubletongman.riv',
      ),
    ];
  }
}
