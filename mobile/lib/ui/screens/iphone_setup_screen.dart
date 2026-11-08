import 'package:flutter/material.dart';

import '../widgets/numbered_steps.dart';

/// Whether the "Get Today's Wallpaper" Shortcuts action exists in the iOS app.
///
/// Leave this `false` until the App Intent ships (see `docs/ios-setup.md`).
/// The automation steps below are already written and appear once it is `true`.
const kShortcutsActionAvailable = false;

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
    'Tap "Customize", then tap the lock screen picture on the left.',
    'Tap the box just under the clock. It may say "Add Widgets."',
    'Scroll down the list and tap "Without Price."',
    'Tap the wide "Verse" widget. It fits the most text. The one-line version works too.',
    'If the box is full, remove a widget first by tapping the minus sign on it.',
    'Tap outside the box, then tap "Done" in the top corner.',
  ];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'The widget sits under the clock and shows a new verse every day by itself. '
          'It is small, so very long verses are shortened. Open this app to read the whole verse.',
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
    "Don't pinch or move the picture. The verse is already placed below the clock. "
        'If iOS offers "Depth Effect," turn it off so the clock does not cover the words.',
    'Tap "Add." When asked, choose "Set as Wallpaper Pair" to use it everywhere, '
        'or "Customize Home Screen" to keep a different home screen.',
  ];

  static const _automationSteps = [
    "First set a verse wallpaper by hand once (steps above). The automation replaces that wallpaper's photo each day.",
    'Open the Shortcuts app, tap "Automation" at the bottom, then tap + (or "New Automation").',
    'Choose "Time of Day." Pick a time like 6:00 AM, choose "Daily," select "Run Immediately," and tap "Next."',
    'Tap "New Blank Automation," then "Add Action." Search for "Without Price" and tap "Get Today\'s Wallpaper."',
    'Tap the search bar again, search for "Wallpaper," and add "Set Wallpaper Photo."',
    'In that action, tap "Wallpaper" to choose your verse wallpaper. '
        'Make sure the photo is the "Wallpaper Image" from the step before.',
    'Tap the arrow on the action and turn off "Show Preview" and "Crop to Subject."',
    'Tap "Done." Your lock screen now gets a new verse every morning.',
  ];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'A wallpaper shows the whole verse, full screen. Apple does not let apps change your wallpaper, '
          'so you set it yourself. It takes about a minute.',
          style: textTheme.bodyLarge,
        ),
        const SizedBox(height: 20),
        Text('Set it by hand', style: textTheme.titleMedium),
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
          const NumberedSteps(steps: _automationSteps),
        ],
      ],
    );
  }
}
