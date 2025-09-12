import 'services/character_collection_service.dart';

class DebugHelper {
  static Future<void> clearAllGameData() async {
    await CharacterCollectionService.clearAllData();
    print('All game data has been cleared');
  }
}

// 使用方法：
// main関数またはアプリ起動時に以下を呼び出す
// await DebugHelper.clearAllGameData();