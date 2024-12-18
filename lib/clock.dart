import 'dart:async';

import 'package:auth_manager/clipper.dart';
import 'package:axons_totp/axons_totp.dart';
import 'package:flutter/material.dart';

class Clock extends StatefulWidget {
  const Clock({super.key});

  @override
  State<Clock> createState() => _ClockState();
}

class _ClockState extends State<Clock> {
  Timer? _timer;
  int _seconds = 0;
  final _offsetSeconds = 118;
  final _token = "MYTIWWM5RF5BSGQLGZIYS7OTCT47DVFH";

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final initialDelay = 1000 - now.millisecond;
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
      _seconds = 30 - ((DateTime.now().second + _offsetSeconds) % 30);
    });
  }

  String get code => TOTP.generate(
        _token,
        offset: _offsetSeconds,
      );

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        fit: StackFit.loose,
        children: [
          _buildText(context, inverted: true),
          ClipRect(
            clipper: FractionalClipRect(
              heightFactor: 1.0,
              widthFactor: _seconds / 30,
              alignment: Alignment.centerLeft,
            ),
            child: _buildText(context, inverted: false),
          ),
        ],
      ),
    );
  }

  Widget _buildText(BuildContext context, {bool inverted = false}) {
    return Container(
      decoration: BoxDecoration(
        color: inverted ? Colors.white : Colors.black,
        //borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: Colors.black,
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
                FontVariation.weight(inverted ? 600 : 200),
              ],
              fontSize: 18,
              color: inverted ? Colors.black : Colors.white,
            ),
          ),
          const SizedBox(width: 16),
          Container(
            color: inverted ? Colors.black : Colors.white,
            width: 1,
            height: 18,
          ),
          const SizedBox(width: 16),
          Text(
            "${code.substring(0, 3)} ${code.substring(3, 6)}",
            style: TextStyle(
              fontFamily: "JetbrainsMono",
              fontVariations: [
                FontVariation.weight(inverted ? 800 : 700),
              ],
              fontSize: 30,
              color: inverted ? Colors.black : Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
