import 'dart:math';

import 'package:flutter/material.dart';

import '../models/flashcard_deck.dart';
import '../models/kana.dart';
import '../services/speech_recognition_service.dart';
import '../services/storage_service.dart';
import '../services/text_to_speech_service.dart';
import '../widgets/flashcard_widget.dart';
import 'flashcard_practice_screen.dart' show PracticeOrder;

enum _AttemptState { idle, listening, checked }

/// Pronunciation practice: hear the correct sound, try saying it, get
/// checked via on-device speech recognition.
class SpeechPracticeScreen extends StatefulWidget {
  const SpeechPracticeScreen({
    super.key,
    required this.deck,
    this.order = PracticeOrder.sequential,
  });

  final FlashcardDeck deck;
  final PracticeOrder order;

  @override
  State<SpeechPracticeScreen> createState() => _SpeechPracticeScreenState();
}

class _SpeechPracticeScreenState extends State<SpeechPracticeScreen> {
  final SpeechRecognitionService _speechService = SpeechRecognitionService();
  final TextToSpeechService _ttsService = TextToSpeechService();
  late final Future<StorageService> _storageFuture;
  late final List<Kana> _sessionCards;

  int _index = 0;
  int _correct = 0;
  int _incorrect = 0;
  _AttemptState _state = _AttemptState.idle;
  String? _lastTranscript;
  bool? _lastAnswerCorrect;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _storageFuture = StorageService.create();
    _sessionCards = List<Kana>.from(widget.deck.cards);
    if (widget.order == PracticeOrder.random) {
      _sessionCards.shuffle(Random());
    }
  }

  @override
  void dispose() {
    _speechService.stop();
    _ttsService.stop();
    super.dispose();
  }

  bool get _isSessionComplete => _index >= _sessionCards.length;

  Future<void> _playSound() async {
    final card = _sessionCards[_index];
    final ok = await _ttsService.speak(card.character);
    if (!ok && mounted) {
      setState(() => _errorMessage =
          'Couldn\'t play audio — this device may be missing a Japanese voice pack.');
    }
  }

  Future<void> _startListening() async {
    if (_state == _AttemptState.listening) return;

    setState(() {
      _state = _AttemptState.listening;
      _errorMessage = null;
      _lastTranscript = null;
    });

    final card = _sessionCards[_index];
    final transcript = await _speechService.listenOnce(
      localeId: 'ja-JP',
      timeout: const Duration(seconds: 4),
    );

    if (!mounted) return;

    if (transcript == null || transcript.isEmpty) {
      setState(() {
        _state = _AttemptState.idle;
        _errorMessage = _speechService.lastError != null
            ? 'Didn\'t catch that (${_speechService.lastError}). Try again.'
            : 'Didn\'t catch that — try again, a bit closer to the mic.';
      });
      return;
    }

    final wasCorrect = _speechService.matches(
      transcript,
      expectedRomaji: card.romaji,
      expectedCharacter: card.character,
    );

    final storage = await _storageFuture;
    await storage.recordAttempt(card.id, wasCorrect: wasCorrect);

    if (!mounted) return;
    setState(() {
      _state = _AttemptState.checked;
      _lastTranscript = transcript;
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
      _state = _AttemptState.idle;
      _lastTranscript = null;
      _lastAnswerCorrect = null;
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Pronunciation: ${widget.deck.name}')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: _isSessionComplete ? _buildSummary(context) : _buildPracticeCard(context),
        ),
      ),
    );
  }

  Widget _buildPracticeCard(BuildContext context) {
    final card = _sessionCards[_index];
    final checked = _state == _AttemptState.checked;
    final listening = _state == _AttemptState.listening;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LinearProgressIndicator(value: _index / _sessionCards.length),
        const SizedBox(height: 8),
        Text(
          'Card ${_index + 1} of ${_sessionCards.length}',
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        FlashcardWidget(prompt: card.character, caption: 'Say this out loud'),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton.filledTonal(
              onPressed: _playSound,
              icon: const Icon(Icons.volume_up),
              tooltip: 'Hear pronunciation',
              iconSize: 32,
            ),
            const SizedBox(width: 24),
            IconButton.filled(
              onPressed: listening ? null : _startListening,
              icon: Icon(listening ? Icons.mic : Icons.mic_none),
              tooltip: 'Record yourself',
              iconSize: 32,
              style: IconButton.styleFrom(
                backgroundColor: listening ? Colors.red : null,
                minimumSize: const Size(64, 64),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          listening ? 'Listening…' : 'Tap the mic and say the sound',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 16),
        if (_errorMessage != null)
          Text(
            _errorMessage!,
            textAlign: TextAlign.center,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        if (checked) ...[
          Text(
            'Heard: "$_lastTranscript"',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
          Text(
            _lastAnswerCorrect! ? 'Correct! 🎉' : 'Not quite — it\'s "${card.romaji}".',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: _lastAnswerCorrect! ? Colors.green[700] : Colors.red[700],
                ),
          ),
          const SizedBox(height: 16),
          FilledButton(onPressed: _next, child: const Text('Next')),
        ] else
          TextButton(
            onPressed: _next,
            child: const Text('Skip this card'),
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
