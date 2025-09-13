import 'package:shared_preferences/shared_preferences.dart';
import 'character_level_service.dart';

class CharacterCollectionService {
  static const String _keyPrefix = 'character_obtained_';
  
  // 初期キャラクター（最初から所持しているキャラ）
  static const List<String> _initialCharacters = [
    'ぷくらん', 'バゲットン', 'クレッシェン', 'あんまる', 'ダブルトングマン'
  ];
  
  static Future<void> markCharacterAsObtained(String characterName) async {
    final prefs = await SharedPreferences.getInstance();
    final isAlreadyObtained = prefs.getBool('$_keyPrefix$characterName') ?? false;
    
    if (!isAlreadyObtained) {
      // 初回解放の場合
      await prefs.setBool('$_keyPrefix$characterName', true);
      await CharacterLevelService.unlockCharacter(characterName);
    } else {
      // 既に解放済みの場合はカードを追加
      await CharacterLevelService.addCard(characterName);
    }
  }
  
  // 初期キャラクターのレベルデータを設定
  static Future<void> initializeDefaultCharacters() async {
    for (String characterName in _initialCharacters) {
      final isAlreadyObtained = await isCharacterObtained(characterName);
      if (!isAlreadyObtained) {
        await markCharacterAsObtained(characterName);
      }
    }
  }
  
  static Future<bool> isCharacterObtained(String characterName) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('$_keyPrefix$characterName') ?? false;
  }
  
  static Future<Set<String>> getObtainedCharacters() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    final obtainedCharacters = <String>{};
    
    for (String key in keys) {
      if (key.startsWith(_keyPrefix) && prefs.getBool(key) == true) {
        obtainedCharacters.add(key.substring(_keyPrefix.length));
      }
    }
    
    return obtainedCharacters;
  }
  
  static Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    
    for (String key in keys) {
      if (key.startsWith(_keyPrefix)) {
        await prefs.remove(key);
      }
    }
  }
}