import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:without_price/ui/widgets/dedication_note.dart';

void main() {
  testWidgets('tapping the small question mark shows the dedication', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: DedicationNote())));
    expect(find.text(DedicationNote.message), findsNothing);

    await tester.tap(find.byIcon(Icons.help_outline));
    await tester.pumpAndSettle();
    expect(find.text(DedicationNote.message), findsOneWidget);

    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
    expect(find.text(DedicationNote.message), findsNothing);
  });
}
