import '../models/character.dart';

class GameData {
  static List<Character> getAllCharacters() {
    return [
      Character(
        name: 'ぷくらん',
        maxHp: 100,
        attackPower: 20,
        powerCost: 30, // 10 × 3 = 30
        description: '基本的なパン戦士。バランスの取れた能力を持つ。',
        imagePath: 'pukuran.png',
      ),
      Character(
        name: 'バゲットン',
        maxHp: 150,
        attackPower: 35,
        powerCost: 75, // 25 × 3 = 75
        description: 'サクサクの装甲を持つ騎士。高い攻撃力が自慢。',
        imagePath: 'buggeton.png',
      ),
      Character(
        name: 'クレッシェン',
        maxHp: 80,
        attackPower: 45,
        powerCost: 90, // 30 × 3 = 90
        description: '甘い魔法を使う魔術師。高火力だが脆い。',
        imagePath: 'kuresshen.png',
      ),
      Character(
        name: 'あんまる',
        maxHp: 120,
        attackPower: 25,
        powerCost: 45, // 15 × 3 = 45
        description: '長いリーチを持つ槍兵。バランスの良い戦士。',
        imagePath: 'anmaru.png',
      ),
      Character(
        name: 'ダブルトングマン',
        maxHp: 90,
        attackPower: 30,
        powerCost: 60, // 20 × 3 = 60
        description: '素早い動きで敵を翻弄する忍者。',
        imagePath: 'doubletongman.png',
      ),
      Character(
        name: 'チョコ',
        maxHp: 110,
        attackPower: 28,
        powerCost: 50,
        description: '甘い香りで敵を魅了するチョコレート戦士。',
        imagePath: 'choko.png',
      ),
      Character(
        name: 'カニ',
        maxHp: 130,
        attackPower: 32,
        powerCost: 70,
        description: 'ハサミで敵を挟み撃ちする甲殻類の戦士。',
        imagePath: 'kani.png',
      ),
      Character(
        name: 'カティ',
        maxHp: 95,
        attackPower: 38,
        powerCost: 80,
        description: '鋭い爪を持つ俊敏な猫の戦士。',
        imagePath: 'kati.png',
      ),
      Character(
        name: 'サンド',
        maxHp: 140,
        attackPower: 22,
        powerCost: 55,
        description: '砂を操る大地の守護者。高い防御力を誇る。',
        imagePath: 'sand.png',
      ),
      Character(
        name: 'ショク',
        maxHp: 105,
        attackPower: 40,
        powerCost: 85,
        description: '植物の力を借りて戦う自然の戦士。',
        imagePath: 'shoku.png',
      ),
    ];
  }
}
