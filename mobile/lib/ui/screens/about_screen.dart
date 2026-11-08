import 'package:flutter/material.dart';

import '../../data/verse_library.dart';
import '../app_theme.dart';

/// The app's promise (free, no ads, no data collected) and translation credits.
class AboutScreen extends StatelessWidget {
  /// Creates the About screen.
  const AboutScreen({required this.library, super.key});

  /// Source of the translation names and notices.
  final VerseLibrary library;

  static const _promises = [
    'Free forever. No price, no subscription, no "premium."',
    'No ads.',
    'No account and no sign-in.',
    "Nothing is collected. The app has no analytics or tracking and doesn't send crash reports. "
        'On Android it does not even have permission to use the internet.',
    'Everything works offline. The verses are built into the app.',
  ];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            '"Come, buy wine and milk without money and without price."',
            style: textTheme.titleLarge?.copyWith(
              fontFamily: AppTheme.serifFontFamily,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 6),
          Text('Isaiah 55:1 (WEB)', style: textTheme.labelLarge),
          const SizedBox(height: 24),
          Text('Our promise', style: textTheme.titleMedium),
          const SizedBox(height: 8),
          for (final promise in _promises)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Icon(Icons.check, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Text(promise)),
                ],
              ),
            ),
          const SizedBox(height: 24),
          Text('Translations', style: textTheme.titleMedium),
          const SizedBox(height: 8),
          for (final translation in library.translations)
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('${translation.name} (${translation.id})'),
              subtitle: Text(translation.notice),
            ),
          Text(
            'Bible text from eBible.org. ${library.verses.length} verses, '
            'chosen to be short enough for a lock screen.',
            style: textTheme.bodySmall,
          ),
          const SizedBox(height: 24),
          Text('withoutprice.app', style: textTheme.bodySmall),
        ],
      ),
    );
  }
}
