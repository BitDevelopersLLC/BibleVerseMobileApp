import 'package:flutter/material.dart';

import '../widgets/numbered_steps.dart';

/// Whether the "Get Today's Wallpaper" Shortcuts action exists in the iOS app.
///
/// The action is `GetTodaysWallpaperIntent` in `ios/WallpaperShortcut/`. When this is `true`,
/// the wallpaper guide includes the Shortcuts automation steps.
const kShortcutsActionAvailable = true;

/// The tabs of [IphoneSetupScreen].
enum IphoneSetupTab {
  /// Adding the lock screen widget.
  widget,

  /// Setting a saved verse image as the wallpaper.
  wallpaper,
}

/// Step-by-step help for putting a verse on an iPhone lock screen.
class IphoneSetupScreen extends StatelessWidget {
  /// Creates the setup guide, opened on [initialTab].
  const IphoneSetupScreen({this.initialTab = IphoneSetupTab.widget, super.key});

  /// The tab shown first.
  final IphoneSetupTab initialTab;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: IphoneSetupTab.values.length,
      initialIndex: initialTab.index,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('iPhone lock screen'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Widget'),
              Tab(text: 'Wallpaper'),
            ],
          ),
        ),
        body: const TabBarView(children: [_WidgetGuide(), _WallpaperGuide()]),
      ),
    );
  }
}

class _WidgetGuide extends StatelessWidget {
  const _WidgetGuide();

  static const _steps = [
    "Wake your iPhone so the lock screen shows. Unlock it with Face ID or Touch ID, but stay on the lock screen. Don't swipe up.",
    'Touch and hold an empty part of the lock screen until "Customize" appears at the bottom.',
    'Tap "Customize." If iOS asks which screen, choose the lock screen.',
    'Tap the widget box. It may say "Add Widgets." On iOS 26 it is near the bottom of the screen; '
        'on iOS 17 and 18 it is just under the clock.',
    'Scroll down the list and tap "Without Price."',
    'Tap the "Verse" widget to add it.',
    'If the box is full, remove a widget first by tapping the minus sign on it.',
    'Close the widget list, then tap "Done" in the top corner.',
  ];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'The widget shows the verse on your lock screen and changes by itself. iOS keeps lock '
          'screen widgets small, so long verses are shortened. For a big, full-screen verse, use '
          'the Wallpaper tab.',
          style: textTheme.bodyLarge,
        ),
        const SizedBox(height: 16),
        const NumberedSteps(steps: _steps),
        const SizedBox(height: 8),
        Text(
          'Needs iOS 17 or later. To change the translation, pick it on the main screen. '
          'The widget follows your choice.',
          style: textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _WallpaperGuide extends StatelessWidget {
  const _WallpaperGuide();

  static const _manualSteps = [
    'On the main screen of this app, choose a background color, then tap "Save today\'s wallpaper to Photos." '
        "Allow adding photos when asked. The app can only add pictures. It can't see your photos.",
    'Wake your iPhone, unlock it, and stay on the lock screen.',
    'Touch and hold the lock screen, then tap the blue + button at the bottom.',
    'Tap "Photos" at the top, then pick the verse picture you just saved.',
    "Don't pinch or move the picture. The verse is already where you chose in this app. "
        'If iOS offers "Depth Effect," turn it off so the clock does not cover the words.',
    'Tap "Add." When asked, choose "Set as Wallpaper Pair" to use it everywhere, '
        'or "Customize Home Screen" to keep a different home screen.',
  ];

  static const _automationSteps = [
    'First set a verse wallpaper by hand once (steps above). Shortcuts can only change a wallpaper '
        'that was made from a photo.',
    'Open the Shortcuts app and tap "Automation" at the bottom. Tap "New Automation" (or + at the top).',
    'Tap "Time of Day." Pick a time, such as 6:00 AM. Keep "Daily," choose "Run Immediately," and tap "Next."',
    'Tap "Create New Shortcut." (On iOS 17 and 18: "New Blank Automation," then "Add Action.")',
    'Search for "Without Price" and tap "Get Today\'s Wallpaper."',
    'Search for "Wallpaper" and tap "Set Wallpaper Photo." It uses the picture from the step before by itself.',
    'In that action, tap the blue word "Wallpaper" and choose the verse wallpaper you made. '
        'To keep your home screen as it is, tap "Lock Screen and Home Screen" and untick "Home Screen."',
    'Tap the small arrow on the action and turn off "Show Preview" and "Crop to Subject" '
        '(and "Legibility Blur" if you see it).',
    'Tap the check mark in the top corner. Your lock screen now gets the new verse every morning.',
  ];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'A wallpaper shows the whole verse, full screen. Apple does not let apps change your '
          'wallpaper, so you set it once yourself. It takes about a minute. Then the Shortcuts '
          'app can change it every morning for you (see below).',
          style: textTheme.bodyLarge,
        ),
        const SizedBox(height: 20),
        Text('Set it once by hand', style: textTheme.titleMedium),
        const NumberedSteps(steps: _manualSteps),
        const SizedBox(height: 8),
        Text(
          'Want a new verse tomorrow? Save the new picture and repeat steps 3-6. '
          'Or go to Settings > Wallpaper and swap the photo in the wallpaper you already made.',
          style: textTheme.bodyMedium,
        ),
        if (kShortcutsActionAvailable) ...[
          const SizedBox(height: 28),
          Text('Make it change every day by itself (Shortcuts)', style: textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            'The free Shortcuts app from Apple can replace the picture for you each morning. '
            'It uses the translation, background and verse position you chose in this app.',
            style: textTheme.bodyMedium,
          ),
          const NumberedSteps(steps: _automationSteps),
          const SizedBox(height: 8),
          Text(
            'Shortcuts can repeat an automation once a day at most. If you chose "Every hour," '
            'the wallpaper still changes once a day; the widget changes every hour. Needs iOS 17 '
            'or later.',
            style: textTheme.bodySmall,
          ),
        ],
      ],
    );
  }
}
