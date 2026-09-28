import 'dart:async';

import 'package:speech_to_text/speech_to_text.dart' as stt;

/// Thin wrapper around [speech_to_text], which uses the native speech engine 
///
/// Design note: this checks a transcription match, not phonetic accuracy —
/// 
/// Hoping it works for syllable set 
/// Probably will need a phonetic assessment api or ai as alternative
class SpeechRecognitionService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isInitialized = false;
  String? _lastError;

  Future<bool> initialize() async {
    if (_isInitialized) return true;
    _isInitialized = await _speech.initialize(
      onError: (error) => _lastError = error.errorMsg,
      onStatus: (_) {},
    );
    return _isInitialized;
  }

  /// The most recent initialization/listen error message, 
  /// Show a helpful message if failure
  String? get lastError => _lastError;

  bool get isListening => _speech.isListening;

  /// Listens once and resolves with the best-guess transcript 
  /// (lowercased, trimmed), or null if nothing was recognized 
  ///
  /// [localeId] should be a Japanese locale (ja_JP) when available
  /// on the device, so the recognizers language model matches whats being
  /// said - falls back to the device default otherwise.
  Future<String?> listenOnce({
    String? localeId,
    Duration timeout = const Duration(seconds: 5),
  }) async {
    _lastError = null;
    if (!await initialize()) return null;

    String? result;
    final completer = Completer<String?>();

    void complete(String? value) {
      if (!completer.isCompleted) completer.complete(value);
    }

    await _speech.listen(
      onResult: (recognition) {
        result = recognition.recognizedWords.trim().toLowerCase();
        if (recognition.finalResult) complete(result);
      },
      onSoundLevelChange: null,
      listenOptions: stt.SpeechListenOptions(
        localeId: localeId,
        listenFor: timeout,
        cancelOnError: true,
        partialResults: true,
        onDevice: false,
        listenMode: stt.ListenMode.confirmation,
      ),
    );

    // Safety net: if the platform never reports a final result,
    // fall back to whatever partial result we have once the timeout elapses.
    return completer.future.timeout(
      timeout + const Duration(seconds: 1),
      onTimeout: () => result,
    );
  }

  /// Checks a transcript against the expected answer
  ///
  /// Devices behave differently depending on whether they honor a Japanese
  /// [listenOnce.localeId]: some transcribe the actual kana script, 
  /// others fall back to the device locale and transcribe a
  /// phonetic latin approximation
  /// this checks both: a direct substring match against the kana
  /// character, or a normalized latin-letters match against the romaji.
  bool matches(String? transcript, {required String expectedRomaji, required String expectedCharacter}) {
    if (transcript == null || transcript.trim().isEmpty) return false;

    final trimmed = transcript.trim().toLowerCase();

    if (trimmed.contains(expectedCharacter)) return true;

    final normalizedLatin = trimmed.replaceAll(RegExp(r'[^a-z]'), '');
    if (normalizedLatin.isEmpty) return false;

    return normalizedLatin == expectedRomaji.toLowerCase() || normalizedLatin.contains(expectedRomaji.toLowerCase());
  }

  Future<void> stop() => _speech.stop();

  Future<void> cancel() => _speech.cancel();
}