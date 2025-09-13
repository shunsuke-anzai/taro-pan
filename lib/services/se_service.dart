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
}
