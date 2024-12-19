import 'dart:async';
import 'package:auth_manager/components/fractional_clip_r_rect.dart';
import 'package:axons_totp/axons_totp.dart';
import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';

class Clock extends StatefulWidget {
  const Clock({super.key});

  @override
  State<Clock> createState() => _ClockState();
}

class _ClockState extends State<Clock> {
  Timer? _timer;
  int _seconds = 0;
  final _token = "MYTIWWM5RF5BSGQLGZIYS7OTCT47DVFH";
  String _code = "000000";
  String _lastCode = "000000";
  int _timeDrift = 0;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final initialDelay = 1000 - now.millisecond;
    _updateTime(_timer);
    Future.delayed(Duration(milliseconds: initialDelay), () {
      _updateTime(_timer);
      _timer = Timer.periodic(const Duration(milliseconds: 1000), _updateTime);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  _updateTime(Timer? timer) {
    setState(() {
      _seconds = 30 - ((DateTime.now().second + _timeDrift) % 30);
    });

    final generatedCode = TOTP.generate(
      _token,
      offset: _timeDrift,
    );

    _code = generatedCode;
    if (_seconds != 30) {
      _lastCode = _code;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            fit: StackFit.loose,
            children: [
              _buildText(context, _lastCode, inverted: true),
              AnimatedFractionalClipRRect(
                duration: const Duration(milliseconds: 800),
                curve: _seconds == 30
                    ? Curves.fastEaseInToSlowEaseOut
                    : Curves.elasticOut,
                widthFactor: _seconds / 30.0,
                alignment: Alignment.centerLeft,
                borderRadius: const Radius.circular(4),
                child: _buildText(context, _code, inverted: false),
              ),
            ],
          ),
          const SizedBox(height: 20),
          NumberPicker(
            minValue: 0,
            maxValue: 120,
            value: _timeDrift,
            step: 1,
            haptics: true,
            infiniteLoop: true,
            axis: Axis.horizontal,
            itemHeight: 60,
            itemWidth: 60,
            decoration: BoxDecoration(
              color: Colors.transparent,
              border: Border.all(
                color: Colors.white,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            onChanged: (value) {
              setState(() {
                _timeDrift = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildText(BuildContext context, String code,
      {bool inverted = false}) {
    final lightColor = Theme.of(context).colorScheme.onSurface;
    final darkColor = Theme.of(context).colorScheme.surface;
    return Container(
      decoration: BoxDecoration(
        color: inverted ? darkColor : lightColor,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: lightColor,
          width: 1,
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _seconds.toString().padLeft(2, "0"),
            style: TextStyle(
              fontFamily: "JetbrainsMono",
              fontVariations: [
                FontVariation.weight(inverted ? 200 : 600),
              ],
              fontSize: 18,
              color: inverted ? lightColor : darkColor,
            ),
          ),
          const SizedBox(width: 16),
          Container(
            color: inverted ? lightColor : darkColor,
            width: 1,
            height: 18,
          ),
          const SizedBox(width: 16),
          Text(
            "${code.substring(0, 3)} ${code.substring(3, 6)}",
            style: TextStyle(
              fontFamily: "JetbrainsMono",
              fontVariations: [
                FontVariation.weight(inverted ? 700 : 800),
              ],
              fontSize: 30,
              color: inverted ? lightColor : darkColor,
            ),
          ),
        ],
      ),
    );
  }
}
