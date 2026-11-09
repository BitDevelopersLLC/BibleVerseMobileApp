import 'dart:async';
import 'dart:io' show Platform;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:gal/gal.dart';

import '../../data/app_settings.dart';
import '../../data/verse_library.dart';
import '../../platform/lock_screen_channel.dart';
import '../../wallpaper/wallpaper_renderer.dart';
import '../widgets/android_lock_screen_panel.dart';
import '../widgets/dedication_note.dart';
import '../widgets/iphone_lock_screen_panel.dart';
import '../widgets/verse_cadence_picker.dart';
import '../widgets/verse_card.dart';
import 'about_screen.dart';
import 'iphone_setup_screen.dart';

/// The main screen: the current verse, the translation and cadence pickers, and lock screen setup.
class HomeScreen extends StatefulWidget {
  /// Creates the home screen.
  const HomeScreen({required this.library, required this.settings, super.key});

  /// Every bundled verse and translation.
  final VerseLibrary library;

  /// The user's saved choices.
  final AppSettings settings;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  /// Logical size of the in-app preview image. It is shown scaled down.
  static const _previewSize = Size(390, 844);

  late Verse _verse = _currentVerse;
  bool _androidSupported = false;

  /// Fires when the next verse is due (midnight, or the top of the hour) while the app is open.
  Timer? _nextVerseTimer;

  /// Cached preview, rebuilt only when the verse, translation, or style changes.
  Future<Uint8List>? _preview;
  String? _previewKey;

  AppSettings get _settings => widget.settings;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _settings.addListener(_onSettingsChanged);
    if (Platform.isAndroid) unawaited(_checkAndroidSupport());
    unawaited(_syncNative());
    _scheduleNextVerse();
  }

  @override
  void dispose() {
    _nextVerseTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _settings.removeListener(_onSettingsChanged);
    super.dispose();
  }

  /// The verse for the current time and the chosen cadence.
  Verse get _currentVerse => widget.library.current(_settings.cadence);

  /// Shows the current verse and arms the timer for the next one.
  void _refreshVerse() {
    setState(() => _verse = _currentVerse);
    _scheduleNextVerse();
  }

  /// Arms [_nextVerseTimer] for the start of the next rotation slot.
  void _scheduleNextVerse() {
    _nextVerseTimer?.cancel();
    final now = DateTime.now();
    // A one-second margin makes sure the new slot has begun when the timer fires.
    final delay =
        _settings.cadence.startOfNextSlot(now).difference(now) + const Duration(seconds: 1);
    _nextVerseTimer = Timer(delay, () {
      if (mounted) _refreshVerse();
    });
  }

  /// Shows the right verse when the app comes back to the foreground, since timers don't run
  /// while it is in the background.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _refreshVerse();
  }

  Future<void> _checkAndroidSupport() async {
    final supported = await LockScreenChannel.isSupported();
    if (mounted) setState(() => _androidSupported = supported);
  }

  void _onSettingsChanged() {
    // The cadence may have changed, which changes the current verse and the next deadline.
    _refreshVerse();
    unawaited(_syncNative());
  }

  /// Keeps the native lock screen code (Android job or iOS widget) in step with the settings.
  Future<void> _syncNative() => LockScreenChannel.configure(
    enabled: Platform.isIOS || _settings.dailyLockScreen,
    translationId: _settings.translationId,
    style: _settings.style,
    position: _settings.versePosition,
    cadence: _settings.cadence,
  );

  String get _referenceLine => '${_verse.reference} (${_settings.translationId})';

  Future<Uint8List> _wallpaperPng(Size size) => WallpaperRenderer.renderPng(
    width: size.width.round(),
    height: size.height.round(),
    text: _verse.textIn(_settings.translationId),
    reference: _referenceLine,
    style: _settings.style,
    position: _settings.versePosition,
  );

  Future<Uint8List> get _previewImage {
    final key =
        '${_verse.id}|${_settings.translationId}|${_settings.style.name}|${_settings.versePosition.name}';
    if (key != _previewKey || _preview == null) {
      _previewKey = key;
      _preview = _wallpaperPng(_previewSize);
    }
    return _preview!;
  }

  /// iOS: renders today's wallpaper at the screen's full resolution and adds it to Photos.
  Future<void> _saveWallpaperToPhotos() async {
    final messenger = ScaffoldMessenger.of(context);
    final physical = View.of(context).physicalSize;
    final portrait = Size(physical.shortestSide, physical.longestSide);
    try {
      final hasAccess = await Gal.hasAccess() || await Gal.requestAccess();
      if (!hasAccess) {
        messenger.showSnackBar(
          const SnackBar(content: Text('To save the wallpaper, allow adding photos in Settings.')),
        );
        return;
      }
      await Gal.putImageBytes(await _wallpaperPng(portrait), name: 'without-price-${_verse.id}');
      messenger.showSnackBar(
        const SnackBar(content: Text('Saved to Photos. Tap "How to set it" for the next steps.')),
      );
    } on GalException catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Could not save the image: ${e.type.message}')),
      );
    }
  }

  void _applyNow() {
    unawaited(LockScreenChannel.applyNow());
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Your lock screen will update in a moment.')));
  }

  void _open(Widget screen) =>
      unawaited(Navigator.push(context, MaterialPageRoute<void>(builder: (_) => screen)));

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final translation = widget.library.translation(_settings.translationId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Without Price'),
        actions: [
          IconButton(
            tooltip: 'About',
            icon: const Icon(Icons.info_outline),
            onPressed: () => _open(AboutScreen(library: widget.library)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          VerseCard(
            label: _settings.cadence.verseCardLabel,
            text: _verse.textIn(translation.id),
            reference: _referenceLine,
          ),
          const SizedBox(height: 24),
          Text('Translation', style: textTheme.titleMedium),
          const SizedBox(height: 8),
          SegmentedButton<String>(
            showSelectedIcon: false,
            segments: [
              for (final t in widget.library.translations)
                ButtonSegment(value: t.id, label: Text(t.id), tooltip: t.name),
            ],
            selected: {translation.id},
            onSelectionChanged: (selection) => _settings.translationId = selection.first,
          ),
          const SizedBox(height: 4),
          Text(translation.name, style: textTheme.bodySmall),
          const SizedBox(height: 24),
          VerseCadencePicker(
            selected: _settings.cadence,
            onSelected: (cadence) => _settings.cadence = cadence,
          ),
          const SizedBox(height: 28),
          Text('Lock screen', style: textTheme.titleMedium),
          const SizedBox(height: 8),
          if (Platform.isAndroid)
            AndroidLockScreenPanel(
              supported: _androidSupported,
              settings: _settings,
              preview: _previewImage,
              onApplyNow: _applyNow,
            )
          else
            IphoneLockScreenPanel(
              settings: _settings,
              preview: _previewImage,
              onSaveToPhotos: _saveWallpaperToPhotos,
              onOpenGuide: (tab) => _open(IphoneSetupScreen(initialTab: tab)),
            ),
          const SizedBox(height: 32),
          Text(
            'Free forever. No ads. No account. Nothing you do here leaves your phone.',
            textAlign: TextAlign.center,
            style: textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
          const DedicationNote(),
        ],
      ),
    );
  }
}
