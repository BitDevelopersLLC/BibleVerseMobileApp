import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:without_price/data/verse_library.dart';
import 'package:without_price/ui/screens/about_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Load real asset data outside testWidgets: its fake clock would stall asset I/O.
  late VerseLibrary library;
  setUpAll(() async => library = await VerseLibrary.load());

  testWidgets('About screen shows the privacy promise and every translation', (tester) async {
    await tester.pumpWidget(MaterialApp(home: AboutScreen(library: library)));

    expect(find.text('No ads.'), findsOneWidget);
    for (final translation in library.translations) {
      // The list builds lazily, so scroll each entry into view before checking it.
      final entry = find.text('${translation.name} (${translation.id})');
      await tester.scrollUntilVisible(entry, 100);
      expect(entry, findsOneWidget);
    }
  });
}
