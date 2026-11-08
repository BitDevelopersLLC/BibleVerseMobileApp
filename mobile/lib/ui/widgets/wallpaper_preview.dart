import 'dart:typed_data';

import 'package:flutter/material.dart';

/// A phone-shaped thumbnail of the rendered wallpaper.
class WallpaperPreview extends StatelessWidget {
  /// Creates a preview for a PNG that may still be rendering.
  const WallpaperPreview({required this.image, super.key});

  /// The wallpaper PNG.
  final Future<Uint8List> image;

  static const _width = 180.0;
  static const _height = 390.0;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: SizedBox(
          width: _width,
          height: _height,
          child: FutureBuilder<Uint8List>(
            future: image,
            builder: (context, snapshot) => snapshot.hasData
                ? Image.memory(
                    snapshot.data!,
                    fit: BoxFit.cover,
                    gaplessPlayback: true,
                    semanticLabel: "Preview of today's wallpaper",
                  )
                : const ColoredBox(color: Colors.black12),
          ),
        ),
      ),
    );
  }
}
