import 'kana.dart';

/// A named, ordered set of kana the user studies together.
/// Decks can be built-in (Base 46) or user-defined subsets 
class FlashcardDeck {
  const FlashcardDeck({
    required this.id,
    required this.name,
    required this.cards,
    this.description,
  });

  final String id;
  final String name;
  final String? description;
  final List<Kana> cards;

  int get length => cards.length;

  /// Builds a new deck containing only the given [ids], preserving this
  /// deck's card order. 
  /// practice only this 
  FlashcardDeck subsetByIds(Set<String> ids) {
    return FlashcardDeck(
      id: '$id-subset',
      name: '$name (custom)',
      cards: cards.where((k) => ids.contains(k.id)).toList(),
    );
  }
}
