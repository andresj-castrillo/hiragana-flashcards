import '../models/flashcard_deck.dart';
import '../models/kana.dart';
import '../models/kana_type.dart';

/// Static source of truth for every Hiragana character the app knows about.
///
/// Stroke order data is not populated here (see [Kana.strokeOrder] docs) —
/// it should be layered in once a stroke dataset is wired up, without
/// touching [id]/[character]/[romaji], which progress tracking depends on.
abstract final class KanaDataset {
  static const List<Kana> baseGojuon = [
    Kana(id: 'a', character: 'あ', romaji: 'a', type: KanaType.base, row: 'a'),
    Kana(id: 'i', character: 'い', romaji: 'i', type: KanaType.base, row: 'a'),
    Kana(id: 'u', character: 'う', romaji: 'u', type: KanaType.base, row: 'a'),
    Kana(id: 'e', character: 'え', romaji: 'e', type: KanaType.base, row: 'a'),
    Kana(id: 'o', character: 'お', romaji: 'o', type: KanaType.base, row: 'a'),

    Kana(id: 'ka', character: 'か', romaji: 'ka', type: KanaType.base, row: 'ka'),
    Kana(id: 'ki', character: 'き', romaji: 'ki', type: KanaType.base, row: 'ka'),
    Kana(id: 'ku', character: 'く', romaji: 'ku', type: KanaType.base, row: 'ka'),
    Kana(id: 'ke', character: 'け', romaji: 'ke', type: KanaType.base, row: 'ka'),
    Kana(id: 'ko', character: 'こ', romaji: 'ko', type: KanaType.base, row: 'ka'),

    Kana(id: 'sa', character: 'さ', romaji: 'sa', type: KanaType.base, row: 'sa'),
    Kana(id: 'shi', character: 'し', romaji: 'shi', type: KanaType.base, row: 'sa'),
    Kana(id: 'su', character: 'す', romaji: 'su', type: KanaType.base, row: 'sa'),
    Kana(id: 'se', character: 'せ', romaji: 'se', type: KanaType.base, row: 'sa'),
    Kana(id: 'so', character: 'そ', romaji: 'so', type: KanaType.base, row: 'sa'),

    Kana(id: 'ta', character: 'た', romaji: 'ta', type: KanaType.base, row: 'ta'),
    Kana(id: 'chi', character: 'ち', romaji: 'chi', type: KanaType.base, row: 'ta'),
    Kana(id: 'tsu', character: 'つ', romaji: 'tsu', type: KanaType.base, row: 'ta'),
    Kana(id: 'te', character: 'て', romaji: 'te', type: KanaType.base, row: 'ta'),
    Kana(id: 'to', character: 'と', romaji: 'to', type: KanaType.base, row: 'ta'),

    Kana(id: 'na', character: 'な', romaji: 'na', type: KanaType.base, row: 'na'),
    Kana(id: 'ni', character: 'に', romaji: 'ni', type: KanaType.base, row: 'na'),
    Kana(id: 'nu', character: 'ぬ', romaji: 'nu', type: KanaType.base, row: 'na'),
    Kana(id: 'ne', character: 'ね', romaji: 'ne', type: KanaType.base, row: 'na'),
    Kana(id: 'no', character: 'の', romaji: 'no', type: KanaType.base, row: 'na'),

    Kana(id: 'ha', character: 'は', romaji: 'ha', type: KanaType.base, row: 'ha'),
    Kana(id: 'hi', character: 'ひ', romaji: 'hi', type: KanaType.base, row: 'ha'),
    Kana(id: 'fu', character: 'ふ', romaji: 'fu', type: KanaType.base, row: 'ha'),
    Kana(id: 'he', character: 'へ', romaji: 'he', type: KanaType.base, row: 'ha'),
    Kana(id: 'ho', character: 'ほ', romaji: 'ho', type: KanaType.base, row: 'ha'),

    Kana(id: 'ma', character: 'ま', romaji: 'ma', type: KanaType.base, row: 'ma'),
    Kana(id: 'mi', character: 'み', romaji: 'mi', type: KanaType.base, row: 'ma'),
    Kana(id: 'mu', character: 'む', romaji: 'mu', type: KanaType.base, row: 'ma'),
    Kana(id: 'me', character: 'め', romaji: 'me', type: KanaType.base, row: 'ma'),
    Kana(id: 'mo', character: 'も', romaji: 'mo', type: KanaType.base, row: 'ma'),

    Kana(id: 'ya', character: 'や', romaji: 'ya', type: KanaType.base, row: 'ya'),
    Kana(id: 'yu', character: 'ゆ', romaji: 'yu', type: KanaType.base, row: 'ya'),
    Kana(id: 'yo', character: 'よ', romaji: 'yo', type: KanaType.base, row: 'ya'),

    Kana(id: 'ra', character: 'ら', romaji: 'ra', type: KanaType.base, row: 'ra'),
    Kana(id: 'ri', character: 'り', romaji: 'ri', type: KanaType.base, row: 'ra'),
    Kana(id: 'ru', character: 'る', romaji: 'ru', type: KanaType.base, row: 'ra'),
    Kana(id: 're', character: 'れ', romaji: 're', type: KanaType.base, row: 'ra'),
    Kana(id: 'ro', character: 'ろ', romaji: 'ro', type: KanaType.base, row: 'ra'),

    Kana(id: 'wa', character: 'わ', romaji: 'wa', type: KanaType.base, row: 'wa'),
    Kana(id: 'wo', character: 'を', romaji: 'wo', type: KanaType.base, row: 'wa'),

    Kana(id: 'n', character: 'ん', romaji: 'n', type: KanaType.base),
  ];

  static const List<Kana> dakuten = [
    Kana(id: 'ga', character: 'が', romaji: 'ga', type: KanaType.dakuten, row: 'ka'),
    Kana(id: 'gi', character: 'ぎ', romaji: 'gi', type: KanaType.dakuten, row: 'ka'),
    Kana(id: 'gu', character: 'ぐ', romaji: 'gu', type: KanaType.dakuten, row: 'ka'),
    Kana(id: 'ge', character: 'げ', romaji: 'ge', type: KanaType.dakuten, row: 'ka'),
    Kana(id: 'go', character: 'ご', romaji: 'go', type: KanaType.dakuten, row: 'ka'),

    Kana(id: 'za', character: 'ざ', romaji: 'za', type: KanaType.dakuten, row: 'sa'),
    Kana(id: 'ji_z', character: 'じ', romaji: 'ji', type: KanaType.dakuten, row: 'sa'),
    Kana(id: 'zu', character: 'ず', romaji: 'zu', type: KanaType.dakuten, row: 'sa'),
    Kana(id: 'ze', character: 'ぜ', romaji: 'ze', type: KanaType.dakuten, row: 'sa'),
    Kana(id: 'zo', character: 'ぞ', romaji: 'zo', type: KanaType.dakuten, row: 'sa'),

    Kana(id: 'da', character: 'だ', romaji: 'da', type: KanaType.dakuten, row: 'ta'),
    Kana(id: 'ji_d', character: 'ぢ', romaji: 'ji', type: KanaType.dakuten, row: 'ta'),
    Kana(id: 'zu_d', character: 'づ', romaji: 'zu', type: KanaType.dakuten, row: 'ta'),
    Kana(id: 'de', character: 'で', romaji: 'de', type: KanaType.dakuten, row: 'ta'),
    Kana(id: 'do', character: 'ど', romaji: 'do', type: KanaType.dakuten, row: 'ta'),

    Kana(id: 'ba', character: 'ば', romaji: 'ba', type: KanaType.dakuten, row: 'ha'),
    Kana(id: 'bi', character: 'び', romaji: 'bi', type: KanaType.dakuten, row: 'ha'),
    Kana(id: 'bu', character: 'ぶ', romaji: 'bu', type: KanaType.dakuten, row: 'ha'),
    Kana(id: 'be', character: 'べ', romaji: 'be', type: KanaType.dakuten, row: 'ha'),
    Kana(id: 'bo', character: 'ぼ', romaji: 'bo', type: KanaType.dakuten, row: 'ha'),
  ];

  static const List<Kana> handakuten = [
    Kana(id: 'pa', character: 'ぱ', romaji: 'pa', type: KanaType.handakuten, row: 'ha'),
    Kana(id: 'pi', character: 'ぴ', romaji: 'pi', type: KanaType.handakuten, row: 'ha'),
    Kana(id: 'pu', character: 'ぷ', romaji: 'pu', type: KanaType.handakuten, row: 'ha'),
    Kana(id: 'pe', character: 'ぺ', romaji: 'pe', type: KanaType.handakuten, row: 'ha'),
    Kana(id: 'po', character: 'ぽ', romaji: 'po', type: KanaType.handakuten, row: 'ha'),
  ];

  static const List<Kana> combinations = [
    Kana(id: 'kya', character: 'きゃ', romaji: 'kya', type: KanaType.combination, row: 'ka'),
    Kana(id: 'kyu', character: 'きゅ', romaji: 'kyu', type: KanaType.combination, row: 'ka'),
    Kana(id: 'kyo', character: 'きょ', romaji: 'kyo', type: KanaType.combination, row: 'ka'),

    Kana(id: 'sha', character: 'しゃ', romaji: 'sha', type: KanaType.combination, row: 'sa'),
    Kana(id: 'shu', character: 'しゅ', romaji: 'shu', type: KanaType.combination, row: 'sa'),
    Kana(id: 'sho', character: 'しょ', romaji: 'sho', type: KanaType.combination, row: 'sa'),

    Kana(id: 'cha', character: 'ちゃ', romaji: 'cha', type: KanaType.combination, row: 'ta'),
    Kana(id: 'chu', character: 'ちゅ', romaji: 'chu', type: KanaType.combination, row: 'ta'),
    Kana(id: 'cho', character: 'ちょ', romaji: 'cho', type: KanaType.combination, row: 'ta'),

    Kana(id: 'nya', character: 'にゃ', romaji: 'nya', type: KanaType.combination, row: 'na'),
    Kana(id: 'nyu', character: 'にゅ', romaji: 'nyu', type: KanaType.combination, row: 'na'),
    Kana(id: 'nyo', character: 'にょ', romaji: 'nyo', type: KanaType.combination, row: 'na'),

    Kana(id: 'hya', character: 'ひゃ', romaji: 'hya', type: KanaType.combination, row: 'ha'),
    Kana(id: 'hyu', character: 'ひゅ', romaji: 'hyu', type: KanaType.combination, row: 'ha'),
    Kana(id: 'hyo', character: 'ひょ', romaji: 'hyo', type: KanaType.combination, row: 'ha'),

    Kana(id: 'mya', character: 'みゃ', romaji: 'mya', type: KanaType.combination, row: 'ma'),
    Kana(id: 'myu', character: 'みゅ', romaji: 'myu', type: KanaType.combination, row: 'ma'),
    Kana(id: 'myo', character: 'みょ', romaji: 'myo', type: KanaType.combination, row: 'ma'),

    Kana(id: 'rya', character: 'りゃ', romaji: 'rya', type: KanaType.combination, row: 'ra'),
    Kana(id: 'ryu', character: 'りゅ', romaji: 'ryu', type: KanaType.combination, row: 'ra'),
    Kana(id: 'ryo', character: 'りょ', romaji: 'ryo', type: KanaType.combination, row: 'ra'),

    Kana(id: 'gya', character: 'ぎゃ', romaji: 'gya', type: KanaType.combination, row: 'ka'),
    Kana(id: 'gyu', character: 'ぎゅ', romaji: 'gyu', type: KanaType.combination, row: 'ka'),
    Kana(id: 'gyo', character: 'ぎょ', romaji: 'gyo', type: KanaType.combination, row: 'ka'),

    Kana(id: 'ja', character: 'じゃ', romaji: 'ja', type: KanaType.combination, row: 'sa'),
    Kana(id: 'ju', character: 'じゅ', romaji: 'ju', type: KanaType.combination, row: 'sa'),
    Kana(id: 'jo', character: 'じょ', romaji: 'jo', type: KanaType.combination, row: 'sa'),

    Kana(id: 'bya', character: 'びゃ', romaji: 'bya', type: KanaType.combination, row: 'ha'),
    Kana(id: 'byu', character: 'びゅ', romaji: 'byu', type: KanaType.combination, row: 'ha'),
    Kana(id: 'byo', character: 'びょ', romaji: 'byo', type: KanaType.combination, row: 'ha'),

    Kana(id: 'pya', character: 'ぴゃ', romaji: 'pya', type: KanaType.combination, row: 'ha'),
    Kana(id: 'pyu', character: 'ぴゅ', romaji: 'pyu', type: KanaType.combination, row: 'ha'),
    Kana(id: 'pyo', character: 'ぴょ', romaji: 'pyo', type: KanaType.combination, row: 'ha'),
  ];

  /// Every character the app knows about, in a sensible study order.
  static List<Kana> get all => [
        ...baseGojuon,
        ...dakuten,
        ...handakuten,
        ...combinations,
      ];

  /// Default decks offered on the deck-selection screen.
  static List<FlashcardDeck> get defaultDecks => [
        FlashcardDeck(
          id: 'base',
          name: 'Base Hiragana',
          description: 'The core 46 gojūon characters — start here.',
          cards: baseGojuon,
        ),
        FlashcardDeck(
          id: 'dakuten',
          name: 'Dakuten & Handakuten',
          description: 'Voiced (゛) and semi-voiced (゜) sounds.',
          cards: [...dakuten, ...handakuten],
        ),
        FlashcardDeck(
          id: 'combinations',
          name: 'Combinations (ゃゅょ)',
          description: 'Yōon sounds like きゃ, しゅ, ちょ.',
          cards: combinations,
        ),
        FlashcardDeck(
          id: 'all',
          name: 'All Hiragana',
          description: 'Every character in one deck.',
          cards: all,
        ),
      ];
}
