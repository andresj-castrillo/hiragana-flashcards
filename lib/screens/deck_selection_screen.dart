import 'package:flutter/material.dart';

import '../data/kana_dataset.dart';
import '../models/flashcard_deck.dart';
import 'flashcard_practice_screen.dart';
import 'study_screen.dart';
import '../models/custom_deck_record.dart';
import '../services/custom_deck_storage.dart';
import 'custom_deck_builder_screen.dart';


/// Lets the user pick which deck to study 
/// built in - default decks 
/// or deck they created 
class DeckSelectionScreen extends StatefulWidget {
  const DeckSelectionScreen({super.key});

  @override
  State<DeckSelectionScreen> createState() => _DeckSelectionScreenState();
}

class _DeckSelectionScreenState extends State<DeckSelectionScreen> {
  late Future<CustomDeckStorage> _storageFuture;
  List<CustomDeckRecord> _customDecks = [];

  @override
  void initState() {
    super.initState();
    _storageFuture = CustomDeckStorage.create();
    _loadCustomDecks();
  }

  Future<void> _loadCustomDecks() async {
    final storage = await CustomDeckStorage.create();
    if (!mounted) return;
    setState(() => _customDecks = storage.all);
  }

  /// Turns a saved [CustomDeckRecord] into a usable [FlashcardDeck] by
  /// looking up each id in the master dataset, in dataset order (so study
  /// order stays consistent regardless of the order cards were tapped in).
  FlashcardDeck _toFlashcardDeck(CustomDeckRecord record) {
    final idSet = record.kanaIds.toSet();
    final cards = KanaDataset.all.where((k) => idSet.contains(k.id)).toList();
    return FlashcardDeck(
      id: record.id,
      name: record.name,
      description: 'Custom deck',
      cards: cards,
    );
  }

  Future<void> _createDeck() async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const CustomDeckBuilderScreen()),
    );

    if (saved == true) _loadCustomDecks();
  }

  Future<void> _editDeck(CustomDeckRecord record) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => CustomDeckBuilderScreen(existing: record)),
    );

    if (saved == true) _loadCustomDecks();
  }

  Future<void> _deleteDeck(CustomDeckRecord record) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete deck?'),
        content: Text('"${record.name}" will be removed. This can\'t be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;


    final storage = await _storageFuture;

    await storage.delete(record.id);
    _loadCustomDecks();
  }

  @override
  Widget build(BuildContext context) {
    final builtInDecks = KanaDataset.defaultDecks;

    return Scaffold(
      appBar: AppBar(title: const Text('Choose a deck')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createDeck,
        icon: const Icon(Icons.add),
        label: const Text('Create deck'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        children: [
          Text('Built-in decks', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          for (final deck in builtInDecks) ...[
            _DeckTile(deck: deck),
            const SizedBox(height: 12),
          ],
          const SizedBox(height: 12),
          Text('Your decks', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          if (_customDecks.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'No custom decks created — tap "Create deck" to pick your own cards.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            )
          else
            for (final record in _customDecks) ...[
              _DeckTile(
                deck: _toFlashcardDeck(record),
                onEdit: () => _editDeck(record),
                onDelete: () => _deleteDeck(record),
              ),
              const SizedBox(height: 12),
            ],
        ],
      ),
    );
  }
}

class _DeckTile extends StatelessWidget {
  const _DeckTile({required this.deck, this.onEdit, this.onDelete});

  final FlashcardDeck deck;

  /// Non-null only for custom decks — built-in decks can't be edited/deleted.
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  bool get _isCustom => onEdit != null;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(deck.name, style: Theme.of(context).textTheme.titleMedium),
        subtitle: Text(deck.description ?? ''),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Chip(label: Text('${deck.length}')),
            if (_isCustom) ...[
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                tooltip: 'Edit',
                onPressed: onEdit,
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: 'Delete',
                onPressed: onDelete,
              ),
            ],
          ],
        ),
        onTap: deck.cards.isEmpty ? null : () => _showModePicker(context),
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
