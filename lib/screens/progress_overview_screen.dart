import 'package:flutter/material.dart';

import '../data/kana_dataset.dart';
import '../models/kana.dart';
import '../models/kana_type.dart';
import '../models/mastery_level.dart';
import '../services/storage_service.dart';

/// Shows every Hiragana character color-coded by how well its known
/// Global accuracy stats
/// recall map to identify what needs more study, separate from any single practice session.
class ProgressOverviewScreen extends StatefulWidget {
  const ProgressOverviewScreen({super.key});

  @override
  State<ProgressOverviewScreen> createState() => _ProgressOverviewScreenState();
}

class _ProgressOverviewScreenState extends State<ProgressOverviewScreen> {
  late Future<StorageService> _storageFuture;

  @override
  void initState() {
    super.initState();
    _storageFuture = StorageService.create();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your progress')),
      body: FutureBuilder<StorageService>(
        future: _storageFuture,
        builder: (context, snapshot) {
          final storage = snapshot.data;
          if (storage == null) {
            return const Center(child: CircularProgressIndicator());
          }
          return _ProgressBody(storage: storage);
        },
      ),
    );
  }
}

class _ProgressBody extends StatefulWidget {
  const _ProgressBody({required this.storage});

  final StorageService storage;

  @override
  State<_ProgressBody> createState() => _ProgressBodyState();
}

class _ProgressBodyState extends State<_ProgressBody> {
  KanaType? _filter; // null = show all types

  List<Kana> get _visibleCards {
    if (_filter == null) return KanaDataset.all;
    return KanaDataset.all.where((k) => k.type == _filter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _GlobalStatsCard(storage: widget.storage),
        _buildFilterChips(context),
        Expanded(child: _buildGrid(context)),
        _buildLegend(context),
      ],
    );
  }

  Widget _buildFilterChips(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Wrap(
        spacing: 8,
        children: [
          ChoiceChip(
            label: const Text('All'),
            selected: _filter == null,
            onSelected: (_) => setState(() => _filter = null),
          ),
          for (final type in KanaType.values)
            ChoiceChip(
              label: Text(type.label),
              selected: _filter == type,
              onSelected: (_) => setState(() => _filter = type),
            ),
        ],
      ),
    );
  }

  Widget _buildGrid(BuildContext context) {
    final cards = _visibleCards;

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemCount: cards.length,
      itemBuilder: (context, i) {
        final kana = cards[i];
        final stats = widget.storage.statsFor(kana.id);
        final mastery = MasteryEvaluator.evaluate(
          totalAttempts: stats.totalAttempts,
          accuracy: stats.accuracy,
        );

        return _KanaMasteryTile(
          kana: kana,
          mastery: mastery,
          onTap: () => _showDetail(context, kana),
        );
      },
    );
  }

  Widget _buildLegend(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 12,
        runSpacing: 4,
        alignment: WrapAlignment.center,
        children: [
          for (final level in MasteryLevel.values) _LegendDot(level: level),
        ],
      ),
    );
  }

  void _showDetail(BuildContext context, Kana kana) {
    final stats = widget.storage.statsFor(kana.id);
    final mastery = MasteryEvaluator.evaluate(
      totalAttempts: stats.totalAttempts,
      accuracy: stats.accuracy,
    );

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(kana.character, style: Theme.of(sheetContext).textTheme.displayMedium),
                Text(kana.romaji, style: Theme.of(sheetContext).textTheme.titleMedium),
                const SizedBox(height: 12),
                Chip(
                  label: Text(mastery.label),
                  backgroundColor: mastery.color.withValues(alpha: 0.2),
                ),
                const SizedBox(height: 16),
                if (stats.totalAttempts == 0)
                  const Text('Not studied yet — try it in a practice session.')
                else ...[
                  Text(
                    '${(stats.accuracy * 100).round()}% accuracy '
                    '(${stats.correctCount} correct, ${stats.incorrectCount} incorrect, '
                    '${stats.totalAttempts} total)',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text('Recent attempts', style: Theme.of(sheetContext).textTheme.bodySmall),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    alignment: WrapAlignment.center,
                    children: [
                      for (final wasCorrect in stats.recentAttempts)
                        Icon(
                          wasCorrect ? Icons.check_circle : Icons.cancel,
                          color: wasCorrect ? Colors.green : Colors.red,
                          size: 20,
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _GlobalStatsCard extends StatelessWidget {
  const _GlobalStatsCard({required this.storage});

  final StorageService storage;

  @override
  Widget build(BuildContext context) {
    final all = KanaDataset.all;
    var studied = 0;
    var mastered = 0;
    var needsWork = 0;
    var totalCorrect = 0;
    var totalAttempts = 0;

    for (final kana in all) {
      final stats = storage.statsFor(kana.id);
      if (stats.totalAttempts == 0) continue;

      studied++;
      totalCorrect += stats.correctCount;
      totalAttempts += stats.totalAttempts;

      final mastery = MasteryEvaluator.evaluate(
        totalAttempts: stats.totalAttempts,
        accuracy: stats.accuracy,
      );
      if (mastery == MasteryLevel.mastered) mastered++;
      if (mastery == MasteryLevel.needsWork) needsWork++;
    }

    final overallAccuracy = totalAttempts == 0 ? 0 : (totalCorrect / totalAttempts * 100).round();

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _StatColumn(value: '$studied/${all.length}', label: 'Studied'),
            _StatColumn(value: '$overallAccuracy%', label: 'Accuracy'),
            _StatColumn(value: '$mastered', label: 'Mastered'),
            _StatColumn(value: '$needsWork', label: 'Needs work'),
          ],
        ),
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: Theme.of(context).textTheme.titleLarge),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _KanaMasteryTile extends StatelessWidget {
  const _KanaMasteryTile({required this.kana, required this.mastery, required this.onTap});

  final Kana kana;
  final MasteryLevel mastery;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: mastery.color.withValues(alpha: mastery == MasteryLevel.notStudied ? 0.15 : 0.55),
          border: Border.all(color: mastery.color, width: 1.5),
        ),
        alignment: Alignment.center,
        child: Text(
          kana.character,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.level});

  final MasteryLevel level;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: level.color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(level.label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

/// UI-only concern (color), kept separate from the pure [MasteryLevel]
/// classification so the model stays Flutter-free.
extension MasteryLevelColor on MasteryLevel {
  Color get color {
    switch (this) {
      case MasteryLevel.notStudied:
        return Colors.grey;
      case MasteryLevel.needsWork:
        return Colors.red;
      case MasteryLevel.learning:
        return Colors.amber.shade700;
      case MasteryLevel.mastered:
        return Colors.green;
    }
  }
}
