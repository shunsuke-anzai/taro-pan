import '../models/character.dart';

class GameData {
  static List<Character> getAllCharacters() {
    return [
      Character(
        name: '食パン戦士',
        maxHp: 100,
        attackPower: 20,
        powerCost: 10,
        description: '基本的なパン戦士。バランスの取れた能力を持つ。',
      ),
      Character(
        name: 'クロワッサン騎士',
        maxHp: 150,
        attackPower: 35,
        powerCost: 25,
        description: 'サクサクの装甲を持つ騎士。高い攻撃力が自慢。',
      ),
      Character(
        name: 'メロンパン魔術師',
        maxHp: 80,
        attackPower: 45,
        powerCost: 30,
        description: '甘い魔法を使う魔術師。高火力だが脆い。',
      ),
      Character(
        name: 'バゲット槍兵',
        maxHp: 120,
        attackPower: 25,
        powerCost: 15,
        description: '長いリーチを持つ槍兵。バランスの良い戦士。',
      ),
      Character(
        name: 'ドーナツ忍者',
        maxHp: 90,
        attackPower: 30,
        powerCost: 20,
        description: '素早い動きで敵を翻弄する忍者。',
      ),
    ];
  }
}
