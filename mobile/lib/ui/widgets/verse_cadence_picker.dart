import 'package:flutter/material.dart';

import '../../data/verse_cadence.dart';

/// Two buttons for choosing how often a new verse appears.
class VerseCadencePicker extends StatelessWidget {
  /// Creates a cadence picker.
  const VerseCadencePicker({required this.selected, required this.onSelected, super.key});

  /// The currently chosen cadence.
  final VerseCadence selected;

  /// Called when the user picks a cadence.
  final ValueChanged<VerseCadence> onSelected;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('New verse', style: textTheme.titleMedium),
        const SizedBox(height: 8),
        SegmentedButton<VerseCadence>(
          showSelectedIcon: false,
          segments: [
            for (final cadence in VerseCadence.values)
              ButtonSegment(value: cadence, label: Text(cadence.label)),
          ],
          selected: {selected},
          onSelectionChanged: (selection) => onSelected(selection.first),
        ),
      ],
    );
  }
}
