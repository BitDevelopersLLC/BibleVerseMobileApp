import 'dart:typed_data';
import 'dart:ui' as ui;

import '../ui/app_theme.dart';
import 'verse_position.dart';
import 'wallpaper_style.dart';

/// Draws a full-screen verse wallpaper as a PNG image.
///
/// Used for the in-app preview on both platforms and for "Save to Photos" on iOS.
/// The Android background job draws the same layout natively in `WallpaperRenderer.kt`.
/// Keep the layout constants below in sync with that file.
abstract final class WallpaperRenderer {
  /// Horizontal margin on each side, as a fraction of the width.
  static const _marginFraction = 0.10;

  /// Starting verse font size, as a fraction of the width.
  static const _startFontFraction = 0.062;

  /// Smallest verse font size before the text is allowed to overflow.
  static const _minFontFraction = 0.035;

  /// Factor applied to the font size on each attempt to fit a long verse.
  static const _shrinkStep = 0.92;

  /// Reference font size relative to the verse font size.
  static const _referenceScale = 0.62;

  /// Gap between the verse and the reference, relative to the verse font size.
  static const _gapScale = 1.2;

  /// Line height multiplier for all text.
  static const _lineHeight = 1.25;

  /// Renders [text] and [reference] on [style] at [width] x [height] pixels, centered
  /// vertically in the area chosen by [position].
  static Future<Uint8List> renderPng({
    required int width,
    required int height,
    required String text,
    required String reference,
    required WallpaperStyle style,
    required VersePosition position,
  }) async {
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);
    final w = width.toDouble();
    final h = height.toDouble();

    canvas.drawRect(
      ui.Rect.fromLTWH(0, 0, w, h),
      ui.Paint()
        ..shader = ui.Gradient.linear(ui.Offset.zero, ui.Offset(0, h), [
          style.topColor,
          style.bottomColor,
        ]),
    );

    final margin = w * _marginFraction;
    final textWidth = w - 2 * margin;
    final bandTop = h * position.bandTop;
    final bandHeight = h * (position.bandBottom - position.bandTop);

    // Shrink long verses until they fit inside the band.
    var fontSize = w * _startFontFraction;
    ui.Paragraph body;
    ui.Paragraph ref;
    while (true) {
      body = _paragraph(text, fontSize, style.textColor, textWidth, serif: true);
      ref = _paragraph(
        reference,
        fontSize * _referenceScale,
        style.textColor.withValues(alpha: 0.82),
        textWidth,
        bold: true,
      );
      final fits = body.height + fontSize * _gapScale + ref.height <= bandHeight;
      if (fits || fontSize < w * _minFontFraction) break;
      fontSize *= _shrinkStep;
    }

    final blockHeight = body.height + fontSize * _gapScale + ref.height;
    final top = bandTop + (bandHeight - blockHeight) / 2;
    canvas
      ..drawParagraph(body, ui.Offset(margin, top))
      ..drawParagraph(ref, ui.Offset(margin, top + body.height + fontSize * _gapScale));

    final image = await recorder.endRecording().toImage(width, height);
    try {
      final png = await image.toByteData(format: ui.ImageByteFormat.png);
      return png!.buffer.asUint8List();
    } finally {
      image.dispose();
    }
  }

  static ui.Paragraph _paragraph(
    String text,
    double fontSize,
    ui.Color color,
    double width, {
    bool serif = false,
    bool bold = false,
  }) {
    final builder = ui.ParagraphBuilder(ui.ParagraphStyle(textAlign: ui.TextAlign.center))
      ..pushStyle(
        ui.TextStyle(
          color: color,
          fontSize: fontSize,
          height: _lineHeight,
          fontFamily: serif ? AppTheme.serifFontFamily : null,
          fontWeight: bold ? ui.FontWeight.w700 : ui.FontWeight.w400,
          shadows: [
            ui.Shadow(
              color: const ui.Color(0x66000000),
              offset: ui.Offset(0, fontSize * 0.05),
              blurRadius: fontSize * 0.15,
            ),
          ],
        ),
      )
      ..addText(text);
    return builder.build()..layout(ui.ParagraphConstraints(width: width));
  }
}
