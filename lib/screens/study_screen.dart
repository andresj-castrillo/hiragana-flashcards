import 'package:flutter/material.dart';

import '../models/flashcard_deck.dart';
import '../widgets/flashcard_widget.dart';

/// swipe/tap through every card in the deck, seeing the
/// kana and its romaji
class StudyScreen extends StatefulWidget {
  const StudyScreen({super.key, required this.deck});

  final FlashcardDeck deck;

  @override
  State<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends State<StudyScreen> {
  late final PageController _pageController = PageController();
  int _index = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goTo(int newIndex) {
    _pageController.animateToPage(
      newIndex,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cards = widget.deck.cards;

    return Scaffold(
      appBar: AppBar(title: Text('Study: ${widget.deck.name}')),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),
            Text(
              '${_index + 1} / ${cards.length}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: cards.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (context, i) {
                  final card = cards[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Center(
                      child: FlashcardWidget(
                        prompt: card.character,
                        caption: card.romaji,
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton.filledTonal(
                    onPressed: _index > 0 ? () => _goTo(_index - 1) : null,
                    icon: const Icon(Icons.chevron_left),
                    tooltip: 'Previous',
                  ),
                  Text(
                    'Swipe or tap to move through the deck',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  IconButton.filledTonal(
                    onPressed: _index < cards.length - 1 ? () => _goTo(_index + 1) : null,
                    icon: const Icon(Icons.chevron_right),
                    tooltip: 'Next',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
