import 'package:flutter/material.dart';

import 'deck_selection_screen.dart';
import '../core/theme/theme_controller.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.themeController});

  final ThemeController themeController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hiragana Flashcards'),
      actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => SettingsScreen(themeController: themeController),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'あ い う え お',
              style: Theme.of(context).textTheme.displayMedium,
            ),
            const SizedBox(height: 16),
            Text(
              'Learn the Hiragana syllabary with flashcards, romaji '
              'typing, and pronunciation practice.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const DeckSelectionScreen()),
              ),
              icon: const Icon(Icons.style),
              label: const Text('Start practicing'),
            ),
          ],
        ),
      ),
    );
  }
}
