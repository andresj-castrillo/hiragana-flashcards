# Hiragana Flashcards

A mobile flashcard app for learning the Japanese Hiragana syllabary, built with Flutter.

> Early development. This README will evolve as features land.

## What it does

- Browse Hiragana characters as flashcards, organized into decks (e.g. base 46, dakuten/handakuten, combination sounds).
- Pick which decks/cards to study in a session.
- **Check yourself two ways:**
  - **Type the romaji** for the kana shown (e.g. see `あ`, type `a`).
  - **Draw the stroke** for a given romaji (e.g. see `a`, hand-draw `あ`) with basic stroke-shape comparison.
  - **Speak the sound** and get it checked with on-device speech recognition (works offline).
- Track progress per card (correct/incorrect streaks) to resurface the ones you struggle with.

## Project Structure

```text
lib/
├── core/       # Theme, app-wide constants, and styling
├── data/       # Master Hiragana dataset and default decks
├── models/     # Domain models (Kana, FlashcardDeck, PracticeResult, CustomDeckRecord)
├── screens/    # App screens (Home, Deck Selection, Practice, Study, Custom Builder)
├── services/   # Local storage services (SharedPreferences, CustomDeckStorage)
└── widgets/    # Reusable UI components (Interactive Flashcards)


## License and Rights of Use

Copyright © 2026 Andres Jose Castrillo Torres. All rights reserved.

This repository is made publicly available **strictly for personal portfolio showcase and code demonstration purposes**. 

Unauthorized copying, modification, redistribution, or commercial use of this software, in whole or in part, is strictly prohibited without explicit written permission from the author.