import 'package:audioplayers/audioplayers.dart';

class BGMService {
  static final BGMService _instance = BGMService._internal();
  factory BGMService() => _instance;
  BGMService._internal();

  AudioPlayer? _bgmPlayer;
  bool _isPlaying = false;
  static const String _bgmPath = 'BGM/bgm.mp3';

  Future<void> playBGM() async {
    try {
      // 既に再生中の場合は何もしない
      if (_isPlaying) {
        return;
      }
      
      _bgmPlayer = AudioPlayer();
      await _bgmPlayer!.setReleaseMode(ReleaseMode.loop);
      await _bgmPlayer!.play(AssetSource(_bgmPath));
      _isPlaying = true;
      print('BGM開始: $_bgmPath');
    } catch (e) {
      print('BGM再生エラー: $e');
    }
  }

  void dispose() {
    _bgmPlayer?.dispose();
    _bgmPlayer = null;
    _isPlaying = false;
  }
}
