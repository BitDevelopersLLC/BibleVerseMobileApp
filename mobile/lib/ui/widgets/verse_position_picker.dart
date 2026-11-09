import 'package:flutter/material.dart';

import '../../wallpaper/verse_position.dart';

/// Four buttons for choosing which quarter of the screen the verse sits in.
class VersePositionPicker extends StatelessWidget {
  /// Creates a position picker.
  const VersePositionPicker({required this.selected, required this.onSelected, super.key});

  /// The currently chosen position.
  final VersePosition selected;

  /// Called when the user picks a position.
  final ValueChanged<VersePosition> onSelected;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Verse position', style: textTheme.titleSmall),
        const SizedBox(height: 8),
        SegmentedButton<VersePosition>(
          showSelectedIcon: false,
          segments: [
            for (final position in VersePosition.values)
              ButtonSegment(
                value: position,
                label: Text(position.shortLabel),
                tooltip: position.label,
              ),
          ],
          selected: {selected},
          onSelectionChanged: (selection) => onSelected(selection.first),
        ),
        const SizedBox(height: 4),
        Text(
          'If your clock or fingerprint icon covers the verse, move it to a clear spot.',
          style: textTheme.bodySmall,
        ),
      ],
    );
  }
}
