import 'dart:ui';

import 'package:flutter/widgets.dart';

class FractionalClipRect extends CustomClipper<Rect> {
  const FractionalClipRect({
    required this.heightFactor,
    required this.widthFactor,
    this.alignment = Alignment.center,
  });

  final double heightFactor;
  final double widthFactor;
  final Alignment alignment;

  @override
  Rect getClip(Size size) {
    final alignmentX = (alignment.x * 0.5) + 0.5;
    final alignmentY = (alignment.y * 0.5) + 0.5;
    final currentWidth = size.width * widthFactor;
    final currentHeight = size.height * heightFactor;

    return Rect.fromLTRB(
      lerpDouble(0, size.width - currentWidth, alignmentX)!,
      lerpDouble(0, size.height - currentHeight, alignmentY)!,
      lerpDouble(0 + currentWidth, size.width, alignmentX)!,
      lerpDouble(0 + currentHeight, size.height, alignmentY)!,
    );
  }

  @override
  bool shouldReclip(FractionalClipRect oldClipper) {
    return oldClipper.heightFactor != heightFactor ||
        oldClipper.widthFactor != widthFactor;
  }
}
