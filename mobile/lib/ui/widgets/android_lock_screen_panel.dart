import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../data/app_settings.dart';
import 'verse_position_picker.dart';
import 'wallpaper_preview.dart';
import 'wallpaper_style_picker.dart';

/// Android lock screen controls: the daily wallpaper switch, style, preview, and refresh.
class AndroidLockScreenPanel extends StatelessWidget {
  /// Creates the Android lock screen panel.
  const AndroidLockScreenPanel({
    required this.supported,
    required this.settings,
    required this.preview,
    required this.onApplyNow,
    super.key,
  });

  /// Whether this device lets apps change the lock screen wallpaper.
  final bool supported;

  /// The user's saved choices.
  final AppSettings settings;

  /// Preview of today's wallpaper.
  final Future<Uint8List> preview;

  /// Called when the user asks to update the lock screen right away.
  final VoidCallback onApplyNow;

  @override
  Widget build(BuildContext context) {
    if (!supported) {
      return const Text('This phone does not let apps change the lock screen wallpaper.');
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Put a new verse on my lock screen every day'),
          subtitle: const Text('Changes only the lock screen. Your home screen stays the same.'),
          value: settings.dailyLockScreen,
          onChanged: (enabled) => settings.dailyLockScreen = enabled,
        ),
        const SizedBox(height: 8),
        WallpaperStylePicker(
          selected: settings.style,
          onSelected: (style) => settings.style = style,
        ),
        const SizedBox(height: 16),
        VersePositionPicker(
          selected: settings.versePosition,
          onSelected: (position) => settings.versePosition = position,
        ),
        const SizedBox(height: 16),
        WallpaperPreview(image: preview),
        const SizedBox(height: 12),
        if (settings.dailyLockScreen)
          OutlinedButton.icon(
            icon: const Icon(Icons.refresh),
            label: const Text('Update my lock screen now'),
            onPressed: onApplyNow,
          ),
        const SizedBox(height: 8),
        Text(
          'Some Samsung and Xiaomi phones have their own lock screen features (such as '
          '"Dynamic Lock Screen" or "Wallpaper carousel"). If the verse does not appear, turn those off.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
