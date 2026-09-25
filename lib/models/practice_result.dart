/// three ways a card can be checked
enum PracticeMode {
  /// sees the kana and types its romaji reading
  typedRomaji,

  /// sees a romaji and hand-draws the kana
  drawnStroke,

  /// sees or hears a prompt and speaks the sound
  spokenAudio,
}

/// outcome of a single attempt at a single card, used for progress tracking 
class PracticeResult {
  PracticeResult({
    required this.kanaId,
    required this.mode,
    required this.wasCorrect,
    DateTime? attemptedAt,
  }) : attemptedAt = attemptedAt ?? DateTime.now();

  final String kanaId;
  final PracticeMode mode;
  final bool wasCorrect;
  final DateTime attemptedAt;
}
