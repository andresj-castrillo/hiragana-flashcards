import 'package:flutter_tts/flutter_tts.dart';

/// Lets user hear a Kana's correct pronunciation
/// using the device's native Japanese text-to-speech voice (no audio assets)
class TextToSpeechService {
  final FlutterTts _tts = FlutterTts();
  bool _isInitialized = false;

  static const String _japaneseLocale = 'ja-JP';

  Future<bool> initialize() async {
    if (_isInitialized) return true;
    try {
      await _tts.setLanguage(_japaneseLocale);
      await _tts.setSpeechRate(0.4); // slower than default
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);
      _isInitialized = true;
    } catch (_) {
      _isInitialized = false;
    }
    return _isInitialized;
  }

  /// Speaks the given Kana character aloud. Returns false if Japanese TTS isn't available on the device
  Future<bool> speak(String character) async {
    if (!await initialize()) return false;
    final result = await _tts.speak(character);
    return result == 1;
  }

  Future<void> stop() => _tts.stop();
}
