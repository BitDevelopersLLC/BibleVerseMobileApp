import 'package:flutter/material.dart';

import '../app_theme.dart';

/// A card showing the current verse and its reference.
class VerseCard extends StatelessWidget {
  /// Creates a verse card.
  const VerseCard({required this.label, required this.text, required this.reference, super.key});

  /// Small heading above the verse, for example `TODAY`.
  final String label;

  /// The verse text.
  final String text;

  /// The reference line, for example `John 3:16 (BSB)`.
  final String reference;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHigh,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: theme.textTheme.labelSmall?.copyWith(letterSpacing: 1.5)),
            const SizedBox(height: 12),
            SelectableText(
              text,
              style: theme.textTheme.titleLarge?.copyWith(
                fontFamily: AppTheme.serifFontFamily,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            Text(reference, style: theme.textTheme.labelLarge),
          ],
        ),
      ),
    );
  }
}
