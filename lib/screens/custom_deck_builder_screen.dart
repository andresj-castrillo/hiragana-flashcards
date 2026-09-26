import 'package:flutter/material.dart';

import '../data/kana_dataset.dart';
import '../models/custom_deck_record.dart';
import '../models/kana.dart';
import '../models/kana_type.dart';
import '../services/custom_deck_storage.dart';

/// Lets user hand-pick which Kana go into a deck.
///
/// Shows every character in a scrollable grid 
/// Optional KanaType filter chips narrow the
/// grid without losing selections made under a different filter
/// 
/// The bottom bar shows how many
/// are selected and opens a naming dialog to save
///
/// Pass existing to edit a previously saved deck instead of creating a new one 
/// the grid opens selected and the name field filled
/// 
class CustomDeckBuilderScreen extends StatefulWidget {
  const CustomDeckBuilderScreen({super.key, this.existing});

  final CustomDeckRecord? existing;

  @override
  State<CustomDeckBuilderScreen> createState() => _CustomDeckBuilderScreenState();
}

class _CustomDeckBuilderScreenState extends State<CustomDeckBuilderScreen> {
  late final Set<String> _selectedIds = {...?widget.existing?.kanaIds};
  KanaType? _filter; // null = show all types

  bool get _isEditing => widget.existing != null;

  List<Kana> get _visibleCards {
    if (_filter == null) return KanaDataset.all;
    return KanaDataset.all.where((k) => k.type == _filter).toList();
  }

  void _toggle(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit deck' : 'Create a deck')),
      body: Column(
        children: [
          _buildFilterChips(context),
          Expanded(child: _buildGrid(context)),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton.icon(
            onPressed: _selectedIds.isEmpty ? null : () => _openNameDialog(context),
            icon: const Icon(Icons.check),
            label: Text('Accept (${_selectedIds.length} selected)'),
          ),
        ),
      ),
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
    final colorScheme = Theme.of(context).colorScheme;

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
        final isSelected = _selectedIds.contains(kana.id);

        return InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _toggle(kana.id),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: isSelected ? colorScheme.primary : colorScheme.surfaceContainerHighest,
              border: Border.all(
                color: isSelected ? colorScheme.primary : colorScheme.outlineVariant,
                width: 2,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              kana.character,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _openNameDialog(BuildContext context) async {
    final controller = TextEditingController(text: widget.existing?.name ?? '');

    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Name your deck'),
          content: TextField(
            controller: controller,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(hintText: 'e.g. "Tricky ones"'),
            onSubmitted: (value) => Navigator.of(dialogContext).pop(value.trim()),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(controller.text.trim()),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (name == null || name.isEmpty || !context.mounted) return;

    final storage = await CustomDeckStorage.create();

    final record = CustomDeckRecord(
      id: widget.existing?.id ?? CustomDeckStorage.newId(),
      name: name,
      kanaIds: _selectedIds.toList(),
    );
    
    await storage.save(record);

    if (context.mounted) {
      Navigator.of(context).pop(true); // signal the caller to refresh its list
    }
  }
}
