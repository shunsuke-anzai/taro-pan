import 'package:shared_preferences/shared_preferences.dart';

class CharacterLevelService {
  static const String _levelKeyPrefix = 'character_level_';
  static const String _cardCountKeyPrefix = 'character_card_count_';
  
  /// キャラクターのレベルを取得
  static Future<int> getCharacterLevel(String characterName) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('$_levelKeyPrefix$characterName') ?? 1;
  }
  
  /// キャラクターのカード枚数を取得
  static Future<int> getCharacterCardCount(String characterName) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('$_cardCountKeyPrefix$characterName') ?? 0;
  }
  
  /// キャラクターのレベルを設定
  static Future<void> setCharacterLevel(String characterName, int level) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('$_levelKeyPrefix$characterName', level);
  }
  
  /// キャラクターのカード枚数を設定
  static Future<void> setCharacterCardCount(String characterName, int count) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('$_cardCountKeyPrefix$characterName', count);
  }
  
  /// カードを1枚追加し、レベルアップ判定を行う
  static Future<bool> addCard(String characterName) async {
    final currentLevel = await getCharacterLevel(characterName);
    final currentCardCount = await getCharacterCardCount(characterName);
    
    final newCardCount = currentCardCount + 1;
    final requiredCards = getRequiredCardsForLevelUp(currentLevel);
    
    if (newCardCount >= requiredCards) {
      // レベルアップ
      await setCharacterLevel(characterName, currentLevel + 1);
      await setCharacterCardCount(characterName, 0); // カード枚数リセット
      return true; // レベルアップした
    } else {
      // カード枚数のみ増加
      await setCharacterCardCount(characterName, newCardCount);
      return false; // レベルアップしなかった
    }
  }
  
  /// 指定レベルからレベルアップに必要なカード枚数を取得
  static int getRequiredCardsForLevelUp(int currentLevel) {
    switch (currentLevel) {
      case 1:
        return 2; // レベル1→2: カード2枚
      case 2:
        return 4; // レベル2→3: カード4枚
      case 3:
        return 6; // レベル3→4: カード6枚
      case 4:
        return 8; // レベル4→5: カード8枚
      default:
        return 10; // レベル5以上: カード10枚
    }
  }
  
  /// キャラクターを初回解放時の処理
  static Future<void> unlockCharacter(String characterName) async {
    await setCharacterLevel(characterName, 1);
    await setCharacterCardCount(characterName, 1); // 初回解放時はカード1枚
  }
  
  /// 全データをクリア
  static Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    
    for (String key in keys) {
      if (key.startsWith(_levelKeyPrefix) || key.startsWith(_cardCountKeyPrefix)) {
        await prefs.remove(key);
      }
    }
  }
  
  /// レベルと現在のカード数から次のレベルまでの進捗を取得
  static Future<Map<String, dynamic>> getCharacterProgress(String characterName) async {
    final level = await getCharacterLevel(characterName);
    final currentCards = await getCharacterCardCount(characterName);
    final requiredCards = getRequiredCardsForLevelUp(level);
    
    return {
      'level': level,
      'currentCards': currentCards,
      'requiredCards': requiredCards,
      'progress': currentCards / requiredCards,
    };
  }
}