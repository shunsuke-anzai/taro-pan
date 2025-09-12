import 'package:shared_preferences/shared_preferences.dart';

class CharacterCollectionService {
  static const String _keyPrefix = 'character_obtained_';
  
  static Future<void> markCharacterAsObtained(String characterName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('$_keyPrefix$characterName', true);
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