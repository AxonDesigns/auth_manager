import 'dart:ui';

import 'package:flutter/material.dart';

class _FractionalCustomClipper extends CustomClipper<RRect> {
  const _FractionalCustomClipper({
    required this.heightFactor,
    required this.widthFactor,
    required this.borderRadius,
    this.alignment = Alignment.center,
  });

  final double heightFactor;
  final double widthFactor;
  final Alignment alignment;
  final Radius borderRadius;

  @override
  RRect getClip(Size size) {
    final alignmentX = (alignment.x * 0.5) + 0.5;
    final alignmentY = (alignment.y * 0.5) + 0.5;
    final currentWidth = size.width * widthFactor;
    final currentHeight = size.height * heightFactor;

    return RRect.fromLTRBR(
      lerpDouble(0, size.width - currentWidth, alignmentX)!,
      lerpDouble(0, size.height - currentHeight, alignmentY)!,
      lerpDouble(0 + currentWidth, size.width, alignmentX)!,
      lerpDouble(0 + currentHeight, size.height, alignmentY)!,
      borderRadius,
    );
  }

  @override
  bool shouldReclip(_FractionalCustomClipper oldClipper) {
    return oldClipper.heightFactor != heightFactor ||
        oldClipper.widthFactor != widthFactor ||
        oldClipper.borderRadius != borderRadius;
  }
}

class FractionalClipRRect extends StatelessWidget {
  const FractionalClipRRect({
    super.key,
    this.heightFactor = 1.0,
    this.widthFactor = 1.0,
    this.alignment = Alignment.center,
    this.borderRadius = Radius.zero,
    this.clipBehavior = Clip.antiAlias,
    required this.child,
  });

  final double heightFactor;
  final double widthFactor;
  final Alignment alignment;
  final Radius borderRadius;
  final Clip clipBehavior;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      clipper: _FractionalCustomClipper(
        heightFactor: heightFactor,
        widthFactor: widthFactor,
        alignment: alignment,
        borderRadius: borderRadius,
      ),
      clipBehavior: clipBehavior,
      child: child,
    );
  }
}

class AnimatedFractionalClipRRect extends ImplicitlyAnimatedWidget {
  const AnimatedFractionalClipRRect({
    super.key,
    super.curve,
    required super.duration,
    super.onEnd,
    this.alignment = Alignment.center,
    this.heightFactor = 1.0,
    this.widthFactor = 1.0,
    this.borderRadius = Radius.zero,
    this.clipBehavior = Clip.antiAlias,
    required this.child,
  });

  final Alignment alignment;
  final double heightFactor;
  final double widthFactor;
  final Radius borderRadius;
  final Clip clipBehavior;
  final Widget child;

  @override
  AnimatedWidgetBaseState<AnimatedFractionalClipRRect> createState() =>
      _AnimatedFractionalClipRRectState();
}

class _AnimatedFractionalClipRRectState
    extends AnimatedWidgetBaseState<AnimatedFractionalClipRRect> {
  Tween<double>? _heightTween;
  Tween<double>? _widthTween;
  Tween<Alignment>? _alignment;
  Tween<Radius>? _radiusTween;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _heightTween = visitor(_heightTween, widget.heightFactor,
            (dynamic value) => Tween<double>(begin: value as double))
        as Tween<double>?;
    _widthTween = visitor(_widthTween, widget.widthFactor,
            (dynamic value) => Tween<double>(begin: value as double))
        as Tween<double>?;
    _alignment = visitor(_alignment, widget.alignment,
            (dynamic value) => Tween<Alignment>(begin: value as Alignment))
        as Tween<Alignment>?;
    _radiusTween = visitor(_radiusTween, widget.borderRadius,
            (dynamic value) => Tween<Radius>(begin: value as Radius))
        as Tween<Radius>?;
  }

  @override
  Widget build(BuildContext context) {
    return FractionalClipRRect(
      alignment: Alignment(
        _alignment?.evaluate(animation).x ?? widget.alignment.x,
        _alignment?.evaluate(animation).y ?? widget.alignment.x,
      ),
      heightFactor: _heightTween?.evaluate(animation) ?? widget.heightFactor,
      widthFactor: _widthTween?.evaluate(animation) ?? widget.widthFactor,
      borderRadius: _radiusTween?.evaluate(animation) ?? widget.borderRadius,
      clipBehavior: widget.clipBehavior,
      child: widget.child,
    );
  }
}
