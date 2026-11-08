import 'package:flutter/widgets.dart';

import 'app.dart';
import 'data/app_settings.dart';
import 'data/verse_library.dart';

/// Loads the bundled verses and the saved settings, then starts the app.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final (library, settings) = await (VerseLibrary.load(), AppSettings.load()).wait;
  runApp(WithoutPriceApp(library: library, settings: settings));
}
