/// Classifies a kana by how its formed
/// built in decks (base 46, dakuten/handakuten, combinations)
enum KanaType {
  /// The 46 base gojūon characters (あ, か, さ, た, な, は, ま, や, ら, わ, ん...).
  base,

  /// Voiced sounds marked with a dakuten (゛), e.g. か → が.
  dakuten,

  /// Semi-voiced sounds marked with a handakuten (゜), e.g. は → ぱ.
  handakuten,

  /// Combination (yōon) sounds formed with a small や/ゆ/よ, e.g. きゃ, しゅ, ちょ.
  combination,
}

extension KanaTypeLabel on KanaType {
  /// Human-readable label used in deck pickers.
  String get label {
    switch (this) {
      case KanaType.base:
        return 'Base (Gojūon)';
      case KanaType.dakuten:
        return 'Dakuten (゛)';
      case KanaType.handakuten:
        return 'Handakuten (゜)';
      case KanaType.combination:
        return 'Combinations (ゃゅょ)';
    }
  }
}
