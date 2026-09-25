import 'kana_type.dart';

/// a single Hiragana character 
/// what a flashcard needs to know

class Kana {
  const Kana({
    required this.id,
    required this.character,
    required this.romaji,
    required this.type,
    this.row,
    this.strokeOrder = const [],
  });

  /// Stable unique id, eg 'a', 'ka', 'kya' 
  /// map key for progress tracking
  final String id;

  /// The Hiragana glyph
  final String character;

  /// Romanized reading
  final String romaji;

  final KanaType type;

  /// Optional consonant row grouping 
  final String? row;

  /// Stroke order as a list of strokes, each a list of (x, y) points in the 0.0–1.0 range. 
  final List<List<(double x, double y)>> strokeOrder;

  @override
  bool operator ==(Object other) => other is Kana && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Kana($character, $romaji)';
}
