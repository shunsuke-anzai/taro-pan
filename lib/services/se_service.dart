import 'package:audioplayers/audioplayers.dart';

class SEService {
  static Future<void> playButtonSE() async {
    try {
      final sePlayer = AudioPlayer();
      await sePlayer.play(AssetSource('BGM/button.mp3'));
      sePlayer.onPlayerComplete.listen((event) {
        sePlayer.dispose();
      });
    } catch (e) {
      print('SE再生エラー: $e');
    }
  }

  static Future<void> playGachaBefore() async {
    try {
      final sePlayer = AudioPlayer();
      await sePlayer.play(AssetSource('BGM/gatyabefore.mp3'));
      sePlayer.onPlayerComplete.listen((event) {
        sePlayer.dispose();
      });
    } catch (e) {
      print('ガチャ開始SE再生エラー: $e');
    }
  }

  static Future<void> playGachaAfter() async {
    try {
      final sePlayer = AudioPlayer();
      await sePlayer.play(AssetSource('BGM/gatyaafter.mp3'));
      sePlayer.onPlayerComplete.listen((event) {
        sePlayer.dispose();
      });
    } catch (e) {
      print('ガチャ結果SE再生エラー: $e');
    }
  }
}
