import 'dart:async';
import 'dart:ui';
import 'package:auth_manager/components/fractional_clip_r_rect.dart';
import 'package:axons_otp/axons_otp.dart';
import 'package:flutter/material.dart';

class TotpDisplay extends StatefulWidget {
  const TotpDisplay({
    super.key,
    required this.token,
  });

  final String token;

  @override
  State<TotpDisplay> createState() => _TotpDisplayState();
}

class _TotpDisplayState extends State<TotpDisplay> {
  bool _flipped = true;
  String _lastCode = "000000";
  String _codeA = "000000";
  String _codeB = "000000";
  double _factor = 1.0;
  double _progressBarHeight = 4.0;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();

    Timer(now.difference(now.add(const Duration(seconds: 1))), () {
      _timer = Timer.periodic(const Duration(milliseconds: 1000), (timer) {
        _updateTime();
      });
      _updateTime();
    });
  }

  void _updateTime() {
    final code = TOTP.generate(widget.token);
    final seconds = DateTime.now().second % 30;
    _factor = ((seconds - 1) / (29 - 1)).clamp(0, 1);
    _factor = 1.0;
    setState(() {
      if (_lastCode != code) {
        _flipped = !_flipped;
        _codeA = _flipped ? _codeA : code;
        _codeB = _flipped ? code : _codeB;
        _lastCode = code;
        _factor = 1.0;
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
    return SizedBox(
      height: 60,
      child: TweenAnimationBuilder(
        tween: Tween<double>(begin: 0.0, end: _flipped ? 1.0 : 0.0),
        duration: const Duration(milliseconds: 1000),
        curve: Curves.fastEaseInToSlowEaseOut,
        builder: (context, value, child) {
          return Column(
            children: [
              ClipRect(
                clipBehavior: Clip.antiAlias,
                child: Align(
                  alignment: Alignment.topCenter,
                  heightFactor: lerpDouble(
                          (60.0 - (_progressBarHeight * 2.0)) / 60.0,
                          _progressBarHeight / 60.0,
                          value)!
                      .clamp(0, 60.0),
                  child: AnimatedFractionalClipRRect(
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.fastEaseInToSlowEaseOut,
                    alignment:
                        _flipped ? Alignment.centerRight : Alignment.centerLeft,
                    widthFactor: _flipped ? _factor : 1.0,
                    child: _buildText(_codeA),
                  ),
                ),
              ),
              SizedBox(height: _progressBarHeight),
              ClipRect(
                clipBehavior: Clip.antiAlias,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  heightFactor: lerpDouble(_progressBarHeight / 60.0,
                          (60.0 - (_progressBarHeight * 2.0)) / 60.0, value)!
                      .clamp(0, 60.0),
                  child: AnimatedFractionalClipRRect(
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.fastEaseInToSlowEaseOut,
                    alignment: Alignment.centerLeft,
                    widthFactor: _flipped ? 1.0 : _factor,
                    child: _buildText(_codeB),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildText(String code) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSurface,
      ),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "${code.substring(0, 3)} ${code.substring(3, 6)}",
            style: TextStyle(
              color: Theme.of(context).colorScheme.surface,
              fontFamily: "JetbrainsMono",
              fontVariations: const [
                FontVariation.weight(700),
              ],
              fontSize: 30,
            ),
          ),
        ],
      ),
    );
  }
}
