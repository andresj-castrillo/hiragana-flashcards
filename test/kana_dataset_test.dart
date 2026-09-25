import 'package:flutter_test/flutter_test.dart';
import 'package:hiragana_flashcards/data/kana_dataset.dart';

void main() {
  group('KanaDataset', () {
    test('has the expected number of base gojūon characters (46)', () {
      expect(KanaDataset.baseGojuon.length, 46);
    });

    test('every card has a unique id across the whole dataset', () {
      final ids = KanaDataset.all.map((k) => k.id).toList();
      expect(ids.toSet().length, ids.length,
          reason: 'Duplicate Kana.id found — ids must be unique.');
    });

    test('every card has a non-empty character and romaji', () {
      for (final kana in KanaDataset.all) {
        expect(kana.character, isNotEmpty, reason: 'Empty character for ${kana.id}');
        expect(kana.romaji, isNotEmpty, reason: 'Empty romaji for ${kana.id}');
      }
    });

    test('default decks cover every character exactly once (base/dakuten/handakuten/combinations)',
        () {
      final decks = KanaDataset.defaultDecks.where((d) => d.id != 'all');
      final coveredIds = decks.expand((d) => d.cards.map((k) => k.id)).toList();
      expect(coveredIds.toSet().length, coveredIds.length);
      expect(coveredIds.toSet(), KanaDataset.all.map((k) => k.id).toSet());
    });
  });
}
