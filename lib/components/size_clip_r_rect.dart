import 'package:flutter/cupertino.dart';

class SizeClipRRect extends CustomClipper<RRect> {
  const SizeClipRRect({
    this.top = 0.0,
    this.right = 0.0,
    this.bottom = 0.0,
    this.left = 0.0,
    this.borderRadius = Radius.zero,
  });

  final double top;
  final double right;
  final double bottom;
  final double left;
  final Radius borderRadius;

  @override
  RRect getClip(Size size) {
    return RRect.fromLTRBR(
      left,
      top,
      size.width - right,
      size.height - bottom,
      borderRadius,
    );
  }

  @override
  bool shouldReclip(covariant SizeClipRRect oldClipper) {
    return oldClipper.top != top ||
        oldClipper.right != right ||
        oldClipper.bottom != bottom ||
        oldClipper.left != left ||
        oldClipper.borderRadius != borderRadius;
  }
}
