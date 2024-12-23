import 'dart:async';
import 'package:auth_manager/components/fractional_clip_r_rect.dart';
import 'package:axons_totp/axons_totp.dart';
import 'package:flutter/material.dart';

class TotpDisplay extends StatefulWidget {
  const TotpDisplay({
    super.key,
    required this.token,
    this.progressBarHeight = 4.0,
  });

  final String token;
  final double progressBarHeight;

  @override
  State<TotpDisplay> createState() => _TotpDisplayState();
}

class _TotpDisplayState extends State<TotpDisplay> {
  bool _flipped = true;
  String _lastCode = "000000";
  String _codeA = "000000";
  String _codeB = "000000";
  String _seconds = "00";
  late Timer _timer;

  double get height {
    final renderBox = context.findRenderObject() as RenderBox?;
    return renderBox?.size.height ?? 60;
  }

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();

    _lastCode = TOTP.generate(widget.token);
    _codeA = _lastCode;
    _codeB = _lastCode;

    Timer(now.difference(now.add(const Duration(milliseconds: 1000))), () {
      _timer = Timer.periodic(const Duration(milliseconds: 1000), (timer) {
        _updateTime();
      });
      _updateTime();
    });
  }

  void _updateTime() {
    final code = TOTP.generate(widget.token);
    final seconds = DateTime.now().second % 30;
    setState(() {
      _seconds = (30 - seconds).toString().padLeft(2, "0");
      if (_lastCode != code) {
        _flipped = !_flipped;
        _codeA = _flipped ? _codeA : code;
        _codeB = _flipped ? code : _codeB;
        _lastCode = code;
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: Theme.of(context).colorScheme.onSurface,
                  strokeAlign: BorderSide.strokeAlignInside,
                  width: height * 0.07,
                ),
                top: BorderSide(
                  color: Theme.of(context).colorScheme.onSurface,
                  strokeAlign: BorderSide.strokeAlignInside,
                  width: height * 0.07,
                ),
                bottom: BorderSide(
                  color: Theme.of(context).colorScheme.onSurface,
                  strokeAlign: BorderSide.strokeAlignInside,
                  width: height * 0.07,
                ),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Center(
              child: Text(
                _seconds,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontFamily: "JetbrainsMono",
                  fontVariations: const [
                    FontVariation.weight(300),
                  ],
                  fontFeatures: const [
                    FontFeature.tabularFigures(),
                    FontFeature.slashedZero(),
                  ],
                  fontSize: 20,
                ),
              ),
            ),
          ),
          Stack(
            fit: StackFit.loose,
            clipBehavior: Clip.none,
            children: [
              AnimatedFractionalClipRRect(
                duration: const Duration(milliseconds: 800),
                curve: Curves.fastEaseInToSlowEaseOut,
                heightFactor: _flipped ? 0.07 : 0.83,
                alignment: Alignment.topCenter,
                child: _buildText(
                  _codeA,
                  offset: _flipped ? 0.1 : -0.1,
                ),
              ),
              AnimatedFractionalClipRRect(
                duration: const Duration(milliseconds: 800),
                curve: Curves.fastEaseInToSlowEaseOut,
                heightFactor: _flipped ? 0.83 : 0.07,
                alignment: Alignment.bottomCenter,
                child: _buildText(
                  _codeB,
                  offset: _flipped ? 0.1 : -0.1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildText(String code, {double offset = 0.0, double opacity = 1.0}) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSurface,
      ),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedSlide(
            duration: const Duration(milliseconds: 800),
            curve: Curves.fastEaseInToSlowEaseOut,
            offset: Offset(0, offset),
            child: Text(
              "${code.substring(0, 3)} ${code.substring(3, 6)}",
              style: TextStyle(
                color: Theme.of(context).colorScheme.surface,
                fontFamily: "JetbrainsMono",
                fontVariations: const [
                  FontVariation.weight(900),
                ],
                fontFeatures: const [
                  FontFeature.tabularFigures(),
                  FontFeature.slashedZero(),
                ],
                fontSize: 30,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
