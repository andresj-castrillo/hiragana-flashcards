import 'package:flutter/material.dart';

import '../data/kana_dataset.dart';
import '../models/flashcard_deck.dart';
import 'flashcard_practice_screen.dart';

/// Lets the user pick which deck to study 
/// built in - default decks 
class DeckSelectionScreen extends StatelessWidget {
  const DeckSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final decks = KanaDataset.defaultDecks;

    return Scaffold(
      appBar: AppBar(title: const Text('Choose a deck')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: decks.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) => _DeckTile(deck: decks[index]),
      ),
    );
  }
}

class _DeckTile extends StatelessWidget {
  const _DeckTile({required this.deck});

  final FlashcardDeck deck;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(deck.name, style: Theme.of(context).textTheme.titleMedium),
        subtitle: Text(deck.description ?? ''),
        trailing: Chip(label: Text('${deck.length}')),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => FlashcardPracticeScreen(deck: deck)),
        ),
      ),
    );
  }
}
