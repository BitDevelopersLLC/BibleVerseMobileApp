import UIKit

/// Draws a full-screen verse wallpaper for the "Get Today's Wallpaper" Shortcuts action.
///
/// This is a port of `lib/wallpaper/wallpaper_renderer.dart`, which draws the in-app preview and
/// the "Save to Photos" image, so both paths produce the same picture. Android draws the same
/// layout in `WallpaperRenderer.kt`. Keep the layout constants below in sync with those files.
enum WallpaperRenderer {
  /// Horizontal margin on each side, as a fraction of the width.
  private static let marginFraction: CGFloat = 0.10

  /// Starting verse font size, as a fraction of the width.
  private static let startFontFraction: CGFloat = 0.062

  /// Smallest verse font size before the text is allowed to overflow.
  private static let minFontFraction: CGFloat = 0.035

  /// Factor applied to the font size on each attempt to fit a long verse.
  private static let shrinkStep: CGFloat = 0.92

  /// Reference font size relative to the verse font size.
  private static let referenceScale: CGFloat = 0.62

  /// Gap between the verse and the reference, relative to the verse font size.
  private static let gapScale: CGFloat = 1.2

  /// Line height multiplier for all text.
  private static let lineHeight: CGFloat = 1.25

  /// Opacity of the reference line.
  private static let referenceOpacity: CGFloat = 0.82

  /// Serif font for the verse. It ships with iOS (the Flutter app uses it too), so nothing is
  /// ever downloaded.
  private static let serifFontName = "Georgia"

  /// Renders `verse` as a PNG of `pixelSize` pixels, or returns `nil` if encoding fails.
  ///
  /// The image is drawn at a scale of 1, so `pixelSize` is the exact output size. Pass the
  /// screen's native resolution for a sharp wallpaper.
  static func pngData(for verse: CurrentVerse, pixelSize: CGSize) -> Data? {
    let format = UIGraphicsImageRendererFormat()
    format.scale = 1
    format.opaque = true
    let renderer = UIGraphicsImageRenderer(size: pixelSize, format: format)
    let data = renderer.pngData { context in
      draw(verse, in: CGRect(origin: .zero, size: pixelSize), context: context.cgContext)
    }
    return data.isEmpty ? nil : data
  }

  /// Draws the gradient background and the verse block into `context`.
  private static func draw(_ verse: CurrentVerse, in bounds: CGRect, context: CGContext) {
    drawBackground(verse.style, in: bounds, context: context)

    let width = bounds.width
    let margin = width * marginFraction
    let textWidth = width - 2 * margin
    let bandTop = bounds.height * verse.position.bandTop
    let bandHeight = bounds.height * (verse.position.bandBottom - verse.position.bandTop)
    let textColor = UIColor(rgb: verse.style.textRGB)

    // Shrink long verses until they fit inside the band, exactly like the Dart renderer.
    var fontSize = width * startFontFraction
    var body: NSAttributedString
    var reference: NSAttributedString
    var bodyHeight: CGFloat
    var referenceHeight: CGFloat
    while true {
      body = attributed(verse.text, font: serifFont(size: fontSize), color: textColor)
      reference = attributed(
        verse.referenceWithTranslation,
        font: .systemFont(ofSize: fontSize * referenceScale, weight: .bold),
        color: textColor.withAlphaComponent(referenceOpacity)
      )
      bodyHeight = height(of: body, width: textWidth)
      referenceHeight = height(of: reference, width: textWidth)
      let fits = bodyHeight + fontSize * gapScale + referenceHeight <= bandHeight
      if fits || fontSize < width * minFontFraction {
        break
      }
      fontSize *= shrinkStep
    }

    let gap = fontSize * gapScale
    let top = bandTop + (bandHeight - (bodyHeight + gap + referenceHeight)) / 2
    draw(body, at: CGPoint(x: margin, y: top), width: textWidth)
    draw(reference, at: CGPoint(x: margin, y: top + bodyHeight + gap), width: textWidth)
  }

  /// Fills `bounds` with the style's top-to-bottom gradient.
  private static func drawBackground(_ style: WallpaperStyle, in bounds: CGRect, context: CGContext) {
    let colors = [UIColor(rgb: style.topRGB).cgColor, UIColor(rgb: style.bottomRGB).cgColor]
    guard let gradient = CGGradient(
      colorsSpace: CGColorSpaceCreateDeviceRGB(),
      colors: colors as CFArray,
      locations: [0, 1]
    ) else {
      context.setFillColor(colors[0])
      context.fill(bounds)
      return
    }
    context.drawLinearGradient(
      gradient,
      start: CGPoint(x: bounds.midX, y: bounds.minY),
      end: CGPoint(x: bounds.midX, y: bounds.maxY),
      options: []
    )
  }

  /// The verse font at `size`, falling back to the system font if Georgia is unavailable.
  private static func serifFont(size: CGFloat) -> UIFont {
    UIFont(name: serifFontName, size: size) ?? .systemFont(ofSize: size)
  }

  /// Centered text with Flutter's line height and a soft shadow, matching the Dart renderer.
  ///
  /// Flutter gives every line a box of `lineHeight` x the font size and centers the glyphs in it.
  /// Here the same extra space goes between lines (`lineSpacing`), and `height(of:)` and
  /// `draw(_:at:width:)` add the half that Flutter puts above the first and below the last line.
  private static func attributed(_ text: String, font: UIFont, color: UIColor) -> NSAttributedString {
    let paragraph = NSMutableParagraphStyle()
    paragraph.alignment = .center
    paragraph.lineBreakMode = .byWordWrapping
    paragraph.lineSpacing = extraLeading(for: font)

    let shadow = NSShadow()
    shadow.shadowColor = UIColor.black.withAlphaComponent(0.4)
    shadow.shadowOffset = CGSize(width: 0, height: font.pointSize * 0.05)
    shadow.shadowBlurRadius = font.pointSize * 0.15

    return NSAttributedString(string: text, attributes: [
      .font: font,
      .foregroundColor: color,
      .paragraphStyle: paragraph,
      .shadow: shadow,
    ])
  }

  /// Space Flutter adds to each line beyond the font's natural line height.
  private static func extraLeading(for font: UIFont) -> CGFloat {
    max(0, font.pointSize * lineHeight - font.lineHeight)
  }

  /// The font of the first character of `text`.
  private static func font(of text: NSAttributedString) -> UIFont {
    text.attribute(.font, at: 0, effectiveRange: nil) as? UIFont ?? .systemFont(ofSize: 12)
  }

  /// The height Flutter would give `text` wrapped to `width`: the laid-out lines plus half the
  /// extra leading above the first line and half below the last.
  private static func height(of text: NSAttributedString, width: CGFloat) -> CGFloat {
    let laidOut = text.boundingRect(
      with: CGSize(width: width, height: .greatestFiniteMagnitude),
      options: [.usesLineFragmentOrigin, .usesFontLeading],
      context: nil
    ).height
    return (laidOut + extraLeading(for: font(of: text))).rounded(.up)
  }

  /// Draws `text` wrapped to `width` with its top (including Flutter's half leading) at `origin`.
  ///
  /// The drawing area is a few lines taller than the measured text, so rounding can never push
  /// the last line outside it and get it dropped.
  private static func draw(_ text: NSAttributedString, at origin: CGPoint, width: CGFloat) {
    let textFont = font(of: text)
    let halfLeading = extraLeading(for: textFont) / 2
    let area = CGRect(
      x: origin.x,
      y: origin.y + halfLeading,
      width: width,
      height: height(of: text, width: width) + textFont.lineHeight * 3
    )
    text.draw(with: area, options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil)
  }
}
