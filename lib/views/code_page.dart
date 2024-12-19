import 'dart:async';

import 'package:auth_manager/components/progress_with_code.dart';
import 'package:axons_totp/axons_totp.dart';
import 'package:flutter/material.dart';

class CodePage extends StatefulWidget {
  const CodePage({
    super.key,
    required this.name,
    required this.token,
  });

  final String name;
  final String token;

  @override
  State<CodePage> createState() => _CodePageState();
}

class _CodePageState extends State<CodePage> {
  Timer? _timer;
  int _seconds = 0;

  @override
  void initState() {
    super.initState();
    final initialDelay = 1000 - DateTime.now().millisecond;
    _updateTime(_timer);
    Future.delayed(Duration(milliseconds: initialDelay), () {
      _updateTime(_timer);
      _timer = Timer.periodic(const Duration(milliseconds: 1000), _updateTime);
    });
  }

  _updateTime(Timer? timer) {
    setState(() {
      _seconds = 30 - ((DateTime.now().second + 0) % 30);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: ProgressWithCode(
          code: TOTP.generate(widget.token),
          value: _seconds.toDouble(),
          minValue: 0,
          maxValue: 30,
        ),
      ),
    );
  }
}
