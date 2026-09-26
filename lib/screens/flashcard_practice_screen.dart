import 'package:flutter/material.dart';

import '../models/flashcard_deck.dart';
import '../models/kana.dart';
import '../services/storage_service.dart';
import '../widgets/flashcard_widget.dart';

import 'dart:math';

/// for deck studied in order or shuffle for that session
enum PracticeOrder { sequential, random}

/// working practice loop: see the kana, type its romaji.
class FlashcardPracticeScreen extends StatefulWidget {
  const FlashcardPracticeScreen({
    super.key, 
    required this.deck,
    this.order = PracticeOrder.sequential,
    });

  final FlashcardDeck deck;
  final PracticeOrder order;

  @override
  State<FlashcardPracticeScreen> createState() => _FlashcardPracticeScreenState();
}

class _FlashcardPracticeScreenState extends State<FlashcardPracticeScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  late Future<StorageService> _storageFuture;

  late final List<Kana> _sessionCards;

  int _index = 0;
  int _correct = 0;
  int _incorrect = 0;
  bool? _lastAnswerCorrect; // null = not answered yet for current card

  @override
  void initState() {
    super.initState();
    _storageFuture = StorageService.create();

    // copy decks card for shufflign 
    _sessionCards = List<Kana>.from(widget.deck.cards);

    if (widget.order == PracticeOrder.random) {
      _sessionCards.shuffle(Random());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  bool get _isSessionComplete => _index >= widget.deck.cards.length;

  Future<void> _submit() async {
    if (_isSessionComplete || _lastAnswerCorrect != null) return;

    // get card, format input and check anwser 
    final card = widget.deck.cards[_index];
    final userInput = _controller.text.trim().toLowerCase();
    final wasCorrect = userInput == card.romaji.toLowerCase();

    final storage = await _storageFuture;
    await storage.recordAttempt(card.id, wasCorrect: wasCorrect);

    setState(() {
      _lastAnswerCorrect = wasCorrect;
      if (wasCorrect) {
        _correct++;
      } else {
        _incorrect++;
      }
    });
  }

  void _next() {
    setState(() {
      _index++;
      _lastAnswerCorrect = null;
      _controller.clear();
    });
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.deck.name)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: _isSessionComplete ? _buildSummary(context) : _buildPracticeCard(context),
        ),
      ),
    );
  }

  Widget _buildPracticeCard(BuildContext context) {
    final card = widget.deck.cards[_index];
    final answered = _lastAnswerCorrect != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LinearProgressIndicator(value: _index / widget.deck.cards.length),
        const SizedBox(height: 8),
        Text(
          'Card ${_index + 1} of ${widget.deck.cards.length}',
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        FlashcardWidget(prompt: card.character, caption: 'Type the romaji'),
        const SizedBox(height: 24),
        TextField(
          controller: _controller,
          focusNode: _focusNode,
          autofocus: true,
          enabled: !answered,
          textAlign: TextAlign.center,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _submit(),
          decoration: InputDecoration(
            labelText: 'Romaji',
            border: const OutlineInputBorder(),
            filled: answered,
            fillColor: answered
                ? (_lastAnswerCorrect!
                    ? Colors.green.withValues(alpha: 0.1)
                    : Colors.red.withValues(alpha: 0.1))
                : null,
          ),
        ),
        const SizedBox(height: 16),
        if (answered)
          Text(
            _lastAnswerCorrect!
                ? 'Correct! 🎉'
                : 'Not quite — it\'s "${card.romaji}".',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: _lastAnswerCorrect! ? Colors.green[700] : Colors.red[700],
                ),
          ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: answered ? _next : _submit,
          child: Text(answered ? 'Next' : 'Check'),
        ),
      ],
    );
  }

  Widget _buildSummary(BuildContext context) {
    final total = _correct + _incorrect;
    final accuracyPct = total == 0 ? 0 : ((_correct / total) * 100).round();

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.emoji_events, size: 64, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 16),
        Text('Session complete!', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 8),
        Text('$_correct / $total correct ($accuracyPct%)'),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Back to decks'),
        ),
      ],
    );
  }
}
