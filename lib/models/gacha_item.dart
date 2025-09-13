import 'character.dart';

enum ItemType {
  character,
  currency,
  material,
}

enum Rarity {
  star1,
  star2,
  star3,
  star4,
  star5,
}

extension RarityExtension on Rarity {
  int get stars {
    switch (this) {
      case Rarity.star1:
        return 1;
      case Rarity.star2:
        return 2;
      case Rarity.star3:
        return 3;
      case Rarity.star4:
        return 4;
      case Rarity.star5:
        return 5;
    }
  }

  String get displayName {
    return '★${stars}';
  }

  double get dropRate {
    switch (this) {
      case Rarity.star1:
        return 0.0; // 存在しないため0%
      case Rarity.star2:
        return 0.0; // 存在しないため0%
      case Rarity.star3:
        return 0.85; // 85% - 最も出やすい（基本キャラ）
      case Rarity.star4:
        return 0.13; // 13% - レア（強いキャラ）
      case Rarity.star5:
        return 0.02; // 2% - 超レア（最強キャラ）
    }
  }
}

class GachaItem {
  final String id;
  final String name;
  final String description;
  final String imagePath;
  final Rarity rarity;
  final ItemType type;
  final Character? character;
  final int? amount;

  const GachaItem({
    required this.id,
    required this.name,
    required this.description,
    required this.imagePath,
    required this.rarity,
    required this.type,
    this.character,
    this.amount,
  });

  GachaItem copyWith({
    String? id,
    String? name,
    String? description,
    String? imagePath,
    Rarity? rarity,
    ItemType? type,
    Character? character,
    int? amount,
  }) {
    return GachaItem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imagePath: imagePath ?? this.imagePath,
      rarity: rarity ?? this.rarity,
      type: type ?? this.type,
      character: character ?? this.character,
      amount: amount ?? this.amount,
    );
  }
}

class GachaResult {
  final List<GachaItem> items;
  final bool isMultiPull;
  final DateTime timestamp;

  const GachaResult({
    required this.items,
    required this.isMultiPull,
    required this.timestamp,
  });

  bool get hasRareItem {
    return items.any((item) => item.rarity == Rarity.star4 || item.rarity == Rarity.star5);
  }

  List<GachaItem> get rareItems {
    return items.where((item) => item.rarity == Rarity.star4 || item.rarity == Rarity.star5).toList();
  }
}