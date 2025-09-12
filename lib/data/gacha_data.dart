import '../models/gacha_item.dart';
import '../models/character.dart';
import 'game_data.dart';

class GachaData {
  static List<GachaItem> getAllGachaItems() {
    final characters = GameData.getAllCharacters();
    
    return [
      // ★5キャラクター
      GachaItem(
        id: 'char_5_kuresien',
        name: 'クレッシェン',
        description: '甘い魔法を使う魔術師。高火力だが脆い。',
        imagePath: 'assets/images/kuresien.png',
        rarity: Rarity.star5,
        type: ItemType.character,
        character: characters[2], // クレッシェン
      ),
      
      // ★4キャラクター
      GachaItem(
        id: 'char_4_bageton',
        name: 'バゲットン',
        description: 'サクサクの装甲を持つ騎士。高い攻撃力が自慢。',
        imagePath: 'assets/images/bageton.png',
        rarity: Rarity.star4,
        type: ItemType.character,
        character: characters[1], // バゲットン
      ),
      GachaItem(
        id: 'char_4_anmaru',
        name: 'あんまる',
        description: '長いリーチを持つ槍兵。バランスの良い戦士。',
        imagePath: 'assets/images/anmaru.png',
        rarity: Rarity.star4,
        type: ItemType.character,
        character: characters[3], // あんまる
      ),
      GachaItem(
        id: 'char_4_doubletongman',
        name: 'ダブルトングマン',
        description: '素早い動きで敵を翻弄する忍者。',
        imagePath: 'assets/images/panda.png',
        rarity: Rarity.star4,
        type: ItemType.character,
        character: characters[4], // ダブルトングマン
      ),
      
      // ★3キャラクター
      GachaItem(
        id: 'char_3_pukuran',
        name: 'ぷくらん',
        description: '基本的なパン戦士。バランスの取れた能力を持つ。',
        imagePath: 'assets/images/pukuran.png',
        rarity: Rarity.star3,
        type: ItemType.character,
        character: characters[0], // ぷくらん
      ),
      GachaItem(
        id: 'char_3_choko',
        name: 'チョコ',
        description: '甘い香りで敵を魅了するチョコレート戦士。',
        imagePath: 'assets/images/choko.png',
        rarity: Rarity.star3,
        type: ItemType.character,
        character: characters[5], // チョコ
      ),
      GachaItem(
        id: 'char_3_kani',
        name: 'カニ',
        description: 'ハサミで敵を挟み撃ちする甲殻類の戦士。',
        imagePath: 'assets/images/kani.png',
        rarity: Rarity.star3,
        type: ItemType.character,
        character: characters[6], // カニ
      ),
      GachaItem(
        id: 'char_4_kati',
        name: 'カティ',
        description: '鋭い爪を持つ俊敏な猫の戦士。',
        imagePath: 'assets/images/kati.png',
        rarity: Rarity.star4,
        type: ItemType.character,
        character: characters[7], // カティ
      ),
      GachaItem(
        id: 'char_3_sand',
        name: 'サンド',
        description: '砂を操る大地の守護者。高い防御力を誇る。',
        imagePath: 'assets/images/sand.png',
        rarity: Rarity.star3,
        type: ItemType.character,
        character: characters[8], // サンド
      ),
      GachaItem(
        id: 'char_4_shoku',
        name: 'ショク',
        description: '植物の力を借りて戦う自然の戦士。',
        imagePath: 'assets/images/shoku.png',
        rarity: Rarity.star4,
        type: ItemType.character,
        character: characters[9], // ショク
      ),
    ];
  }

  static List<GachaItem> getItemsByRarity(Rarity rarity) {
    return getAllGachaItems().where((item) => item.rarity == rarity).toList();
  }

  static List<double> getRarityWeights() {
    return [
      Rarity.star1.dropRate,
      Rarity.star2.dropRate,
      Rarity.star3.dropRate,
      Rarity.star4.dropRate,
      Rarity.star5.dropRate,
    ];
  }
}