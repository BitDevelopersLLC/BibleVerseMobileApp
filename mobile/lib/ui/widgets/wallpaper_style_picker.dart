import 'package:flutter/material.dart';

import '../../wallpaper/wallpaper_style.dart';

/// A row of round color swatches for choosing the wallpaper background.
class WallpaperStylePicker extends StatelessWidget {
  /// Creates a style picker.
  const WallpaperStylePicker({required this.selected, required this.onSelected, super.key});

  /// The currently chosen style.
  final WallpaperStyle selected;

  /// Called when the user taps a swatch.
  final ValueChanged<WallpaperStyle> onSelected;

  static const _swatchSize = 52.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: [
        for (final style in WallpaperStyle.values)
          Semantics(
            button: true,
            selected: style == selected,
            label: '${style.label} background',
            excludeSemantics: true,
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () => onSelected(style),
              child: Column(
                children: [
                  Container(
                    width: _swatchSize,
                    height: _swatchSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [style.topColor, style.bottomColor],
                      ),
                      border: Border.all(
                        width: 3,
                        color: style == selected ? theme.colorScheme.primary : Colors.transparent,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(style.label, style: theme.textTheme.labelSmall),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
