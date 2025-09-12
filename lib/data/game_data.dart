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
        powerCost: 60, // 25 × 3 = 75
        description: 'サクサクの装甲を持つ騎士。高い攻撃力が自慢。',
        imagePath: 'buggeton.png',
        walkAnimationPath: 'assets/animations/walk_buggeton.riv',
        attackAnimationPath: 'assets/animations/attack_buggeton.riv',
      ),
      Character(
        name: 'クレッシェン',
        maxHp: 80,
        attackPower: 45,
        powerCost: 75, // 30 × 3 = 90
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
        powerCost: 90, // 30 × 3 = 90
        description: '素早い動きで敵を翻弄する忍者。',
        imagePath: 'doubletongman.png',
        walkAnimationPath: 'assets/animations/walk_doubletongman.riv',
        attackAnimationPath: 'assets/animations/attack_doubletongman.riv',
      ),
      Character(
        name: 'チョコホ',
        maxHp: 95,
        attackPower: 38,
        powerCost: 51, // 17 × 3 = 51
        description: 'チョコレートの甘い香りを漂わせるパン戦士。',
        imagePath: 'choko.png',
        lockedImagePath: 'kuro_choko.png',
        walkAnimationPath: 'assets/animations/walk_kuro_choko.riv',
        attackAnimationPath: 'assets/animations/attack_kuro_choko.riv',
        isUnlocked: false, // アンロックフラグ
      ),
      Character(
        name: 'クラブン',
        maxHp: 85,
        attackPower: 42,
        powerCost: 57, // 19 × 3 = 57
        description: 'カニのようなハサミで敵を挟むパン戦士。',
        imagePath: 'kani.png',
        lockedImagePath: 'kuro_kani.png',
        walkAnimationPath: 'assets/animations/walk_kuro_kani.riv',
        attackAnimationPath: 'assets/animations/attack_kuro_kani.riv',
        isUnlocked: false, // アンロックフラグ
      ),
      Character(
        name: 'カティ',
        maxHp: 110,
        attackPower: 35,
        powerCost: 48, // 16 × 3 = 48
        description: 'カティな形状で素早い動きをするパン戦士。',
        imagePath: 'kati.png',
        lockedImagePath: 'kuro_kati.png',
        walkAnimationPath: 'assets/animations/walk_kuro_kati.riv',
        attackAnimationPath: 'assets/animations/attack_kuro_kati.riv',
        isUnlocked: false, // アンロックフラグ
      ),
      Character(
        name: 'サンドパン',
        maxHp: 100,
        attackPower: 36,
        powerCost: 54, // 18 × 3 = 54
        description: 'サンドイッチのように層になったパン戦士。',
        imagePath: 'sand.png',
        lockedImagePath: 'kuro_sand.png',
        walkAnimationPath: 'assets/animations/walk_kuro_sand.riv',
        attackAnimationPath: 'assets/animations/attack_kuro_sand.riv',
        isUnlocked: false, // アンロックフラグ
      ),
      Character(
        name: 'ショク',
        maxHp: 120,
        attackPower: 45,
        powerCost: 60, // 20 × 3 = 60
        description: '食べ物の力でパワーアップするパン戦士。',
        imagePath: 'shoku.png',
        lockedImagePath: 'kuro_shoku.png',
        walkAnimationPath: 'assets/animations/walk_kuro_shoku.riv',
        attackAnimationPath: 'assets/animations/attack_kuro_shoku.riv',
        isUnlocked: false, // アンロックフラグ
      ),
    ];
  }
}
