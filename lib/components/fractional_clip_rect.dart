import 'dart:ui';

import 'package:flutter/widgets.dart';

class _FractionalCustomClipper extends CustomClipper<Rect> {
  const _FractionalCustomClipper({
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
  bool shouldReclip(_FractionalCustomClipper oldClipper) {
    return oldClipper.heightFactor != heightFactor ||
        oldClipper.widthFactor != widthFactor;
  }
}

class FractionalClipRect extends StatelessWidget {
  const FractionalClipRect({
    super.key,
    this.heightFactor = 1.0,
    this.widthFactor = 1.0,
    this.alignment = Alignment.center,
    this.clipBehavior = Clip.antiAlias,
    required this.child,
  });

  final double heightFactor;
  final double widthFactor;
  final Alignment alignment;
  final Widget child;
  final Clip clipBehavior;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      clipper: _FractionalCustomClipper(
        heightFactor: heightFactor,
        widthFactor: widthFactor,
        alignment: alignment,
      ),
      clipBehavior: clipBehavior,
      child: child,
    );
  }
}

class AnimatedFractionalClipRect extends ImplicitlyAnimatedWidget {
  const AnimatedFractionalClipRect({
    super.key,
    super.curve,
    required super.duration,
    super.onEnd,
    this.alignment = Alignment.center,
    this.heightFactor = 1.0,
    this.widthFactor = 1.0,
    this.clipBehavior = Clip.antiAlias,
    required this.child,
  });

  final Alignment alignment;
  final double heightFactor;
  final double widthFactor;
  final Clip clipBehavior;
  final Widget child;

  @override
  AnimatedWidgetBaseState<AnimatedFractionalClipRect> createState() =>
      _AnimatedFractionalClipRectState();
}

class _AnimatedFractionalClipRectState
    extends AnimatedWidgetBaseState<AnimatedFractionalClipRect> {
  Tween<double>? _heightTween;
  Tween<double>? _widthTween;
  Tween<Alignment>? _alignment;

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
  }

  @override
  Widget build(BuildContext context) {
    return FractionalClipRect(
      alignment: Alignment(
        _alignment?.evaluate(animation).x ?? widget.alignment.x,
        _alignment?.evaluate(animation).y ?? widget.alignment.x,
      ),
      heightFactor: _heightTween?.evaluate(animation) ?? widget.heightFactor,
      widthFactor: _widthTween!.evaluate(animation),
      clipBehavior: widget.clipBehavior,
      child: widget.child,
    );
  }
}
