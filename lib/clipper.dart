import 'dart:ui';

import 'package:flutter/widgets.dart';

class CustomRect extends CustomClipper<Rect> {
  const CustomRect({
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

    //TODO: Alinear esto

    return Rect.fromLTRB(
      0,
      size.height * alignmentY,
      currentWidth,
      (size.height * alignmentY) + currentHeight,
    );
  }

  @override
  bool shouldReclip(CustomRect oldClipper) {
    return oldClipper.heightFactor != heightFactor ||
        oldClipper.widthFactor != widthFactor;
  }
}
