import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:without_price/data/verse_cadence.dart';
import 'package:without_price/ui/widgets/verse_cadence_picker.dart';

void main() {
  testWidgets('shows both choices and reports the one the user taps', (tester) async {
    VerseCadence? picked;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: VerseCadencePicker(
            selected: VerseCadence.daily,
            onSelected: (cadence) => picked = cadence,
          ),
        ),
      ),
    );

    expect(find.text('Every day'), findsOneWidget);
    expect(find.text('Every hour'), findsOneWidget);

    await tester.tap(find.text('Every hour'));
    expect(picked, VerseCadence.hourly);
  });
}
