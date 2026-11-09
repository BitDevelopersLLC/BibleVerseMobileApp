/// Where the verse sits on the wallpaper, in four vertical areas of the screen.
///
/// Phones put the clock, fingerprint icon, and shortcuts in different places, so the user
/// picks the area that is clear on their own lock screen. Fractions are of the screen
/// height, with 0 at the very top. Top and Bottom stop short of the screen edges because some
/// lock screens (Pixel) magnify the wallpaper by about 12%.
///
/// The ids ([name]) and fractions are duplicated in `VersePosition.kt` (Android) and
/// `VersePosition.swift` (iOS Shortcuts action). Keep all three in sync.
enum VersePosition {
  /// The top quarter (0-25%). Starts below the status bar.
  top('Top', 'Top', 0.08, 0.25),

  /// The second quarter (25-50%).
  upperMiddle('Upper middle', 'Upper', 0.26, 0.49),

  /// The third quarter (50-75%).
  lowerMiddle('Lower middle', 'Lower', 0.51, 0.74),

  /// The bottom quarter (75-100%). Ends above the gesture bar.
  bottom('Bottom', 'Bottom', 0.76, 0.90);

  const VersePosition(this.label, this.shortLabel, this.bandTop, this.bandBottom);

  /// Full name, used for accessibility and tooltips.
  final String label;

  /// Short name that fits on a button on small phones.
  final String shortLabel;

  /// Top of the area the verse is centered in, as a fraction of the screen height.
  final double bandTop;

  /// Bottom of that area, as a fraction of the screen height.
  final double bandBottom;

  /// The position used until the user chooses one.
  ///
  /// Bottom suits the most phones: Pixels show a large clock across the middle quarters
  /// when there are no notifications, and in-screen fingerprint icons sit around 70%.
  static const defaultPosition = bottom;

  /// The position whose [name] is [id], or [defaultPosition] if there is no match.
  static VersePosition fromId(String? id) =>
      values.firstWhere((position) => position.name == id, orElse: () => defaultPosition);
}
