/// How often a new verse appears: once a day (the default) or once an hour.
///
/// The ids ([name]) and the rotation rule are duplicated in `VerseCadence.kt` (Android) and
/// `VerseCadence.swift` (iOS widget and Shortcuts action). Change all three together.
enum VerseCadence {
  /// A new verse at local midnight.
  daily('Every day', 'TODAY'),

  /// A new verse at the start of every local hour.
  hourly('Every hour', 'THIS HOUR');

  const VerseCadence(this.label, this.verseCardLabel);

  /// Name shown in the picker.
  final String label;

  /// Heading of the verse card on the main screen.
  final String verseCardLabel;

  /// The cadence used until the user chooses one.
  static const defaultCadence = daily;

  static const _hoursPerDay = 24;

  /// The cadence whose [name] is [id], or [defaultCadence] if there is no match.
  static VerseCadence fromId(String? id) =>
      values.firstWhere((cadence) => cadence.name == id, orElse: () => defaultCadence);

  /// The rotation slot that contains [now]: which verse to show is `slot % verseCount`.
  ///
  /// * Daily: days since 1970-01-01 for the local calendar date.
  /// * Hourly: that day number times 24, plus the local hour (0-23).
  ///
  /// Daily slots are the same numbers as the original once-a-day rule, so existing installs
  /// keep their verse.
  int slotContaining(DateTime now) {
    final day = localEpochDay(now);
    return switch (this) {
      daily => day,
      hourly => day * _hoursPerDay + now.hour,
    };
  }

  /// The first moment of the slot after the one that contains [now]: the next local midnight,
  /// or the next full hour.
  DateTime startOfNextSlot(DateTime now) => switch (this) {
    daily => DateTime(now.year, now.month, now.day + 1),
    hourly => DateTime(now.year, now.month, now.day, now.hour + 1),
  };

  /// Days since 1970-01-01 for the local calendar date of [now].
  ///
  /// Uses the year, month and day only, so the time of day and daylight saving time never
  /// affect the result.
  static int localEpochDay(DateTime now) =>
      DateTime.utc(now.year, now.month, now.day).millisecondsSinceEpoch ~/
      Duration.millisecondsPerDay;
}
