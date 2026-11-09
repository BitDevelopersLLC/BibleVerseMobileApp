import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:without_price/ui/screens/iphone_setup_screen.dart';

void main() {
  testWidgets('the wallpaper guide includes the Shortcuts automation', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: IphoneSetupScreen(initialTab: IphoneSetupTab.wallpaper)),
    );

    expect(kShortcutsActionAvailable, isTrue);
    await tester.scrollUntilVisible(
      find.text('Make it change every day by itself (Shortcuts)'),
      300,
      scrollable: find.byType(Scrollable).last,
    );
    // The action name in the steps must match GetTodaysWallpaperIntent.title in Swift.
    await tester.scrollUntilVisible(
      find.textContaining('"Get Today\'s Wallpaper."'),
      300,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.textContaining('"Get Today\'s Wallpaper."'), findsOneWidget);
  });

  testWidgets('the widget guide opens by default', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: IphoneSetupScreen()));
    expect(find.textContaining('Tap the "Verse" widget'), findsOneWidget);
  });
}
