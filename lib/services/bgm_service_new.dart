import 'package:audioplayers/audioplayers.dart';

class BGMService {
  static final BGMService _instance = BGMService._internal();
  factory BGMService() => _instance;
  BGMService._internal();

  AudioPlayer? _bgmPlayer;
  String? _currentBGM;
  bool _isPlaying = false;

  Future<void> _initializePlayer() async {
    if (_bgmPlayer == null) {
      _bgmPlayer = AudioPlayer();
      await _bgmPlayer!.setReleaseMode(ReleaseMode.loop);
    }
  }

  Future<void> playBGM(String assetPath) async {
    try {
      print('BGM再生開始: $assetPath');
      
      // 同じBGMが既に再生中の場合は何もしない
      if (_currentBGM == assetPath && _isPlaying) {
        print('同じBGMが既に再生中です: $assetPath');
        return;
      }
      
      await _initializePlayer();
      
      // 現在のBGMを停止
      if (_isPlaying && _bgmPlayer != null) {
        await _bgmPlayer!.stop();
      }
      
      // BGMの初期設定
      _currentBGM = assetPath;
      
      // 新しいBGMを再生（軽量化）
      await _bgmPlayer!.play(AssetSource(assetPath));
      _isPlaying = true;
      print('BGM再生成功: $assetPath');
    } catch (e) {
      if (e.toString().contains('user didn\'t interact') || 
          e.toString().contains('NotAllowedError')) {
        print('Web環境: ユーザーインタラクションを待機中');
        // エラーを隠して、後でリトライ可能にする
        _currentBGM = assetPath;
        _isPlaying = false;
      } else {
        print('BGM再生エラー: $e');
      }
    }
  }

  Future<void> stopBGM() async {
    try {
      if (_bgmPlayer != null) {
        await _bgmPlayer!.stop();
      }
      _isPlaying = false;
      _currentBGM = null;
    } catch (e) {
      print('BGM停止エラー: $e');
    }
  }

  Future<void> pauseBGM() async {
    try {
      if (_bgmPlayer != null && _isPlaying) {
        await _bgmPlayer!.pause();
      }
    } catch (e) {
      print('BGM一時停止エラー: $e');
    }
  }

  Future<void> resumeBGM() async {
    try {
      if (_bgmPlayer != null && !_isPlaying && _currentBGM != null) {
        await _bgmPlayer!.resume();
      }
    } catch (e) {
      print('BGM再開エラー: $e');
    }
  }

  void dispose() {
    _bgmPlayer?.dispose();
    _bgmPlayer = null;
    _isPlaying = false;
    _currentBGM = null;
  }
}
