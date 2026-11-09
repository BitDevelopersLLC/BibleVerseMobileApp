import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../data/app_settings.dart';
import '../screens/iphone_setup_screen.dart';
import 'verse_position_picker.dart';
import 'wallpaper_preview.dart';
import 'wallpaper_style_picker.dart';

/// iPhone lock screen options: the widget (recommended) and a wallpaper image.
///
/// iOS does not let apps change the wallpaper, so the wallpaper option saves an
/// image to Photos and links to step-by-step instructions.
class IphoneLockScreenPanel extends StatelessWidget {
  /// Creates the iPhone lock screen panel.
  const IphoneLockScreenPanel({
    required this.settings,
    required this.preview,
    required this.onSaveToPhotos,
    required this.onOpenGuide,
    super.key,
  });

  /// The user's saved choices.
  final AppSettings settings;

  /// Preview of today's wallpaper.
  final Future<Uint8List> preview;

  /// Saves today's wallpaper to the photo library.
  final VoidCallback onSaveToPhotos;

  /// Opens the setup guide on the given tab.
  final ValueChanged<IphoneSetupTab> onOpenGuide;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          child: ListTile(
            leading: const Icon(Icons.widgets_outlined),
            title: const Text('Add the lock screen widget'),
            subtitle: const Text(
              "Recommended. Shows today's verse under the clock and changes by itself every day.",
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => onOpenGuide(IphoneSetupTab.widget),
          ),
        ),
        const SizedBox(height: 20),
        Text('Or use the verse as your wallpaper', style: textTheme.titleSmall),
        const SizedBox(height: 4),
        Text(
          'Shows the whole verse, full screen. You set it yourself in a few taps.',
          style: textTheme.bodySmall,
        ),
        const SizedBox(height: 12),
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
        FilledButton.icon(
          icon: const Icon(Icons.download),
          label: const Text("Save today's wallpaper to Photos"),
          onPressed: onSaveToPhotos,
        ),
        TextButton(
          child: const Text('How to set it as your lock screen'),
          onPressed: () => onOpenGuide(IphoneSetupTab.wallpaper),
        ),
      ],
    );
  }
}
