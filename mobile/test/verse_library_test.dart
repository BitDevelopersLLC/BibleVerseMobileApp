import 'package:flutter_test/flutter_test.dart';
import 'package:without_price/data/verse_cadence.dart';
import 'package:without_price/data/verse_library.dart';
import 'package:without_price/wallpaper/wallpaper_style.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late VerseLibrary library;
  setUpAll(() async => library = await VerseLibrary.load());

  group('bundled data', () {
    test('contains the four public-domain translations', () {
      expect(library.translations.map((t) => t.id), ['BSB', 'KJV', 'WEB', 'ASV']);
    });

    test('has every verse in every translation', () {
      expect(library.verses.length, greaterThan(100));
      for (final verse in library.verses) {
        for (final translation in library.translations) {
          expect(
            verse.texts[translation.id],
            isNotEmpty,
            reason: '${verse.reference} is missing ${translation.id}',
          );
        }
      }
    });

    test('has unique verse ids', () {
      final ids = library.verses.map((v) => v.id).toList();
      expect(ids.toSet().length, ids.length);
    });
  });

  group('rotation rule', () {
    test('daily uses the local calendar date, not the time of day', () {
      final justAfterMidnight = VerseCadence.daily.slotContaining(DateTime(2026, 11, 8, 0, 5));
      final lateEvening = VerseCadence.daily.slotContaining(DateTime(2026, 11, 8, 23, 55));
      final nextDay = VerseCadence.daily.slotContaining(DateTime(2026, 11, 9, 0, 5));

      expect(justAfterMidnight, lateEvening);
      expect(nextDay, justAfterMidnight + 1);
    });

    test('hourly changes at the top of every hour', () {
      final early = VerseCadence.hourly.slotContaining(DateTime(2026, 11, 8, 9, 0));
      final late = VerseCadence.hourly.slotContaining(DateTime(2026, 11, 8, 9, 59));
      final next = VerseCadence.hourly.slotContaining(DateTime(2026, 11, 8, 10, 0));

      expect(early, late);
      expect(next, early + 1);
    });

    test('hourly continues across midnight', () {
      final lastHour = VerseCadence.hourly.slotContaining(DateTime(2026, 11, 8, 23, 30));
      final firstHour = VerseCadence.hourly.slotContaining(DateTime(2026, 11, 9, 0, 30));
      expect(firstHour, lastHour + 1);
    });

    test('matches the values the Kotlin and Swift implementations expect', () {
      // 2026-11-08 is day 20765 after 1970-01-01, so noon is hourly slot 20765 * 24 + 12.
      // VerseCadence.kt and VerseCadence.swift must produce the same numbers.
      final noon = DateTime(2026, 11, 8, 12);
      expect(VerseCadence.daily.slotContaining(noon), 20765);
      expect(VerseCadence.hourly.slotContaining(noon), 498372);
    });

    test('next slot starts at the next midnight or full hour', () {
      final now = DateTime(2026, 11, 8, 14, 25);
      expect(VerseCadence.daily.startOfNextSlot(now), DateTime(2026, 11, 9));
      expect(VerseCadence.hourly.startOfNextSlot(now), DateTime(2026, 11, 8, 15));
      expect(VerseCadence.daily.startOfNextSlot(DateTime(2026, 12, 31, 23)), DateTime(2027));
    });

    test('changes every slot and repeats after the full list', () {
      final count = library.verses.length;
      expect(library.verseForSlot(20765).id, isNot(library.verseForSlot(20766).id));
      expect(library.verseForSlot(20765).id, library.verseForSlot(20765 + count).id);
    });

    test('current picks the verse for the slot', () {
      final noon = DateTime(2026, 11, 8, 12);
      expect(library.current(VerseCadence.daily, noon).id, library.verseForSlot(20765).id);
      expect(library.current(VerseCadence.hourly, noon).id, library.verseForSlot(498372).id);
    });
  });

  group('VerseCadence.fromId', () {
    test('finds a cadence by id', () => expect(VerseCadence.fromId('hourly'), VerseCadence.hourly));
    test('falls back to daily', () => expect(VerseCadence.fromId(null), VerseCadence.daily));
  });

  group('WallpaperStyle.fromId', () {
    test('finds a style by id', () => expect(WallpaperStyle.fromId('night'), WallpaperStyle.night));
    test('falls back to dawn', () => expect(WallpaperStyle.fromId('missing'), WallpaperStyle.dawn));
  });
}
