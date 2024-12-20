import 'package:auth_manager/components/fractional_clip_r_rect.dart';
import 'package:auth_manager/components/size_clip_r_rect.dart';
import 'package:flutter/material.dart';

class CodeTimer extends StatefulWidget {
  const CodeTimer({
    super.key,
    required this.code,
    required this.seconds,
    this.darkColor,
    this.lightColor,
    this.minSeconds = 0,
    this.maxSeconds = 30,
  });

  final String code;
  final int seconds;
  final int minSeconds;
  final int maxSeconds;
  final Color? darkColor;
  final Color? lightColor;

  @override
  State<CodeTimer> createState() => _CodeTimerState();
}

class _CodeTimerState extends State<CodeTimer> {
  bool _flipped = false;
  String _lastCode = "000000";
  double _height = 1.0;

  Duration _duration = const Duration(milliseconds: 950);

  Color get _darkColor =>
      widget.darkColor ?? Theme.of(context).colorScheme.surface;
  Color get _lightColor =>
      widget.lightColor ?? Theme.of(context).colorScheme.onSurface;

  double get factor =>
      1 -
      ((widget.seconds - 1) - widget.minSeconds) /
          ((widget.maxSeconds - 1) - widget.minSeconds);

  @override
  void initState() {
    super.initState();
    _lastCode = widget.code;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        border: Border.all(
          color: _lightColor,
          strokeAlign: BorderSide.strokeAlignCenter,
          width: 2,
        ),
      ),
      child: Stack(
        fit: StackFit.loose,
        clipBehavior: Clip.none,
        children: [
          _buildText(
            context,
            _lastCode,
            duration: const Duration(milliseconds: 950),
            dark: !_flipped,
            active: true,
          ),
          _buildText(
            context,
            widget.code,
            height: _height,
            duration: _duration,
            dark: _flipped,
            active: false,
          ),
          Positioned.fill(
            child: ClipRRect(
              clipper: SizeClipRRect(
                  top: _flipped ? 0.5 : 0,
                  right: _flipped ? 0.5 : 0,
                  bottom: _flipped ? 0.5 : 0,
                  left: _flipped ? 0.5 : 0),
              child: AnimatedFractionallySizedBox(
                duration: Duration(
                  milliseconds: widget.seconds >= widget.maxSeconds ? 0 : 1000,
                ),
                curve: Curves.linear,
                alignment: Alignment.bottomRight,
                widthFactor: factor,
                heightFactor: 0.1,
                child: Container(
                  color: _flipped ? _lightColor : _darkColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildText(BuildContext context, String code,
      {required Duration duration,
      bool dark = false,
      bool active = false,
      double height = 1.0}) {
    final textStyle = TextStyle(
      fontFamily: "JetbrainsMono",
      fontFeatures: const [
        FontFeature.tabularFigures(),
        FontFeature.slashedZero(),
      ],
      color: dark ? _lightColor : _darkColor,
    );

    return ClipRRect(
      clipper: SizeClipRRect(
        top: dark ? 0 : 0.5,
        right: dark ? 0 : 0.5,
        bottom: dark ? 0 : 0.5,
        left: dark ? 0 : 0.5,
      ),
      child: AnimatedFractionalClipRRect(
        duration: duration,
        curve: Curves.fastEaseInToSlowEaseOut,
        heightFactor: height,
        alignment: Alignment.bottomRight,
        child: Container(
          decoration: BoxDecoration(
            color: dark ? _darkColor : _lightColor,
            border: Border.all(
              color: _darkColor,
              width: 2,
              strokeAlign: BorderSide.strokeAlignCenter,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.seconds
                    .toStringAsFixed(0)
                    .padLeft(widget.maxSeconds.toString().length, "0"),
                style: textStyle.copyWith(
                  fontSize: 18,
                  fontVariations: [
                    FontVariation.weight(dark ? 200 : 600),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Container(
                color: dark ? _lightColor : _darkColor,
                width: 2,
                height: 18,
              ),
              const SizedBox(width: 16),
              Text(
                "${code.substring(0, 3)} ${code.substring(3, 6)}",
                style: textStyle.copyWith(
                  fontSize: 30,
                  fontVariations: [
                    FontVariation.weight(dark ? 700 : 800),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void didUpdateWidget(covariant CodeTimer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.code != oldWidget.code) {
      setState(() {
        _flipped = !_flipped;
        _height = 0.1;
        _duration = const Duration(milliseconds: 0);
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _height = 1.0;
          _duration = const Duration(milliseconds: 950);
        });
      });
      return;
    }
    if (widget.seconds == widget.maxSeconds - 1) {
      setState(() {
        _lastCode = widget.code;
      });
    }
  }
}
