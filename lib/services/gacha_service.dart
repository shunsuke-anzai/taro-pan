import 'dart:math';
import '../models/gacha_item.dart';
import '../data/gacha_data.dart';

class GachaService {
  static final Random _random = Random();
  
  static const int singlePullCost = 100;
  static const int multiPullCost = 900; // 10連は10%オフ

  static GachaResult pullSingle() {
    final item = _pullSingleItem();
    return GachaResult(
      items: [item],
      isMultiPull: false,
      timestamp: DateTime.now(),
    );
  }

  static GachaResult pullMultiple() {
    final items = <GachaItem>[];
    
    // 9回通常抽選
    for (int i = 0; i < 9; i++) {
      items.add(_pullSingleItem());
    }
    
    // 10回目は★3以上確定
    items.add(_pullGuaranteedRareItem());
    
    return GachaResult(
      items: items,
      isMultiPull: true,
      timestamp: DateTime.now(),
    );
  }

  static GachaItem _pullSingleItem() {
    final rarityWeights = GachaData.getRarityWeights();
    final totalWeight = rarityWeights.reduce((a, b) => a + b);
    final randomValue = _random.nextDouble() * totalWeight;
    
    double currentWeight = 0.0;
    for (int i = 0; i < rarityWeights.length; i++) {
      currentWeight += rarityWeights[i];
      if (randomValue <= currentWeight) {
        final rarity = Rarity.values[i];
        return _getRandomItemByRarity(rarity);
      }
    }
    
    // フォールバック（通常は到達しない）
    return _getRandomItemByRarity(Rarity.star3);
  }

  static GachaItem _pullGuaranteedRareItem() {
    // ★3以上確定（★3: 70%, ★4: 25%, ★5: 5%）
    final guaranteedRarities = [Rarity.star3, Rarity.star4, Rarity.star5];
    final guaranteedWeights = [0.70, 0.25, 0.05];
    
    final randomValue = _random.nextDouble();
    double currentWeight = 0.0;
    
    for (int i = 0; i < guaranteedWeights.length; i++) {
      currentWeight += guaranteedWeights[i];
      if (randomValue <= currentWeight) {
        return _getRandomItemByRarity(guaranteedRarities[i]);
      }
    }
    
    // フォールバック
    return _getRandomItemByRarity(Rarity.star3);
  }

  static GachaItem _getRandomItemByRarity(Rarity rarity) {
    final itemsOfRarity = GachaData.getItemsByRarity(rarity);
    if (itemsOfRarity.isEmpty) {
      // フォールバック：他のレアリティから選択
      final allItems = GachaData.getAllGachaItems();
      return allItems[_random.nextInt(allItems.length)];
    }
    
    return itemsOfRarity[_random.nextInt(itemsOfRarity.length)];
  }

  static bool canAffordSinglePull(int currentCoins) {
    return currentCoins >= singlePullCost;
  }

  static bool canAffordMultiPull(int currentCoins) {
    return currentCoins >= multiPullCost;
  }

  static int calculateNewCoinBalance(int currentCoins, bool isMultiPull) {
    final cost = isMultiPull ? multiPullCost : singlePullCost;
    return (currentCoins - cost).clamp(0, double.infinity).toInt();
  }
}

class UserProgress {
  int panCoins;
  List<String> unlockedCharacters;
  Map<String, int> materials;
  
  UserProgress({
    this.panCoins = 1000, // 初期コイン
    List<String>? unlockedCharacters,
    Map<String, int>? materials,
  }) : unlockedCharacters = unlockedCharacters ?? ['char_3_pukuran'], // 初期キャラ
       materials = materials ?? {};

  void addCoins(int amount) {
    panCoins += amount;
  }

  void spendCoins(int amount) {
    panCoins = (panCoins - amount).clamp(0, double.infinity).toInt();
  }

  void unlockCharacter(String characterId) {
    if (!unlockedCharacters.contains(characterId)) {
      unlockedCharacters.add(characterId);
    }
  }

  void addMaterial(String materialId, int amount) {
    materials[materialId] = (materials[materialId] ?? 0) + amount;
  }

  UserProgress copyWith({
    int? panCoins,
    List<String>? unlockedCharacters,
    Map<String, int>? materials,
  }) {
    return UserProgress(
      panCoins: panCoins ?? this.panCoins,
      unlockedCharacters: unlockedCharacters ?? List.from(this.unlockedCharacters),
      materials: materials ?? Map.from(this.materials),
    );
  }
}