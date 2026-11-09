import 'package:flutter_test/flutter_test.dart';
import 'package:without_price/wallpaper/verse_position.dart';

void main() {
  test('the four areas are in order, on screen, and do not overlap', () {
    var previousBottom = 0.0;
    for (final position in VersePosition.values) {
      expect(position.bandTop, greaterThanOrEqualTo(previousBottom), reason: position.name);
      expect(position.bandBottom, greaterThan(position.bandTop), reason: position.name);
      expect(position.bandBottom, lessThanOrEqualTo(1.0), reason: position.name);
      previousBottom = position.bandBottom;
    }
  });

  test('each area stays inside its quarter of the screen', () {
    for (final (index, position) in VersePosition.values.indexed) {
      expect(position.bandTop, greaterThanOrEqualTo(index * 0.25), reason: position.name);
      expect(position.bandBottom, lessThanOrEqualTo((index + 1) * 0.25), reason: position.name);
    }
  });

  test('fromId finds a position and falls back to the default', () {
    expect(VersePosition.fromId('top'), VersePosition.top);
    expect(VersePosition.fromId('bottom'), VersePosition.bottom);
    expect(VersePosition.fromId(null), VersePosition.defaultPosition);
    expect(VersePosition.fromId('sideways'), VersePosition.defaultPosition);
  });
}
