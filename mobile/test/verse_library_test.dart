import 'package:flutter_test/flutter_test.dart';
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

  group('daily verse rule', () {
    test('uses the local calendar date, not the time of day', () {
      final justAfterMidnight = VerseLibrary.localEpochDay(DateTime(2026, 11, 8, 0, 5));
      final lateEvening = VerseLibrary.localEpochDay(DateTime(2026, 11, 8, 23, 55));
      final nextDay = VerseLibrary.localEpochDay(DateTime(2026, 11, 9, 0, 5));

      expect(justAfterMidnight, lateEvening);
      expect(nextDay, justAfterMidnight + 1);
    });

    test('matches the value the Kotlin and Swift implementations expect', () {
      // 2026-11-08 is day 20765 after 1970-01-01. DailyVerse.kt and VerseStore.swift must agree.
      expect(VerseLibrary.localEpochDay(DateTime(2026, 11, 8, 12)), 20765);
    });

    test('changes every day and repeats after the full list', () {
      final count = library.verses.length;
      expect(library.verseForDay(20765).id, isNot(library.verseForDay(20766).id));
      expect(library.verseForDay(20765).id, library.verseForDay(20765 + count).id);
    });
  });

  group('WallpaperStyle.fromId', () {
    test('finds a style by id', () => expect(WallpaperStyle.fromId('night'), WallpaperStyle.night));
    test('falls back to dawn', () => expect(WallpaperStyle.fromId('missing'), WallpaperStyle.dawn));
  });
}
