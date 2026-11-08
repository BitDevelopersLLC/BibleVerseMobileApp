import 'package:flutter/material.dart';

import 'data/app_settings.dart';
import 'data/verse_library.dart';
import 'ui/app_theme.dart';
import 'ui/screens/home_screen.dart';

/// The root widget of Without Price.
class WithoutPriceApp extends StatelessWidget {
  /// Creates the app with its already-loaded verse data and settings.
  const WithoutPriceApp({required this.library, required this.settings, super.key});

  /// Every bundled verse and translation.
  final VerseLibrary library;

  /// The user's saved choices.
  final AppSettings settings;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Without Price',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      home: HomeScreen(library: library, settings: settings),
    );
  }
}
