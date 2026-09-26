import 'package:flutter/material.dart';

import '../data/kana_dataset.dart';
import '../models/flashcard_deck.dart';
import 'flashcard_practice_screen.dart';
import 'study_screen.dart';

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
        onTap: () => _showModePicker(context),
        ),
    );
  }

  Future<void> _showModePicker(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(deck.name, style: Theme.of(sheetContext).textTheme.titleMedium),
                const SizedBox(height: 12),
                ListTile(
                  leading: const Icon(Icons.menu_book),
                  title: const Text('Study'),
                  subtitle: const Text('Browse the cards — no checking, just learning.'),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => StudyScreen(deck: deck)),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.quiz),
                  title: const Text('Practice'),
                  subtitle: const Text('Get quizzed and track your progress.'),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    _showOrderPicker(context);
                  },
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  
  Future<void> _showOrderPicker(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Card order', style: Theme.of(sheetContext).textTheme.titleMedium),
                const SizedBox(height: 12),
                ListTile(
                  leading: const Icon(Icons.format_list_numbered),
                  title: const Text('In order'),
                  subtitle: const Text('Go through the deck from first to last.'),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => FlashcardPracticeScreen(
                          deck: deck,
                          order: PracticeOrder.sequential,
                        ),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.shuffle),
                  title: const Text('Random'),
                  subtitle: const Text('Shuffle the cards for this session.'),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => FlashcardPracticeScreen(
                          deck: deck,
                          order: PracticeOrder.random,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }
  
}


