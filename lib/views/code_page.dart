import 'dart:async';
import 'package:auth_manager/components.dart';
import 'package:auth_manager/utils.dart';
import 'package:axons_otp/axons_otp.dart';
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
    executeOnSeconds(_updateTime);
    _updateTime(null);
  }

  _updateTime(Timer? timer) {
    _timer = timer;
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
      extendBodyBehindAppBar: true,
      appBar: AppBar(),
      body: Center(
        child: CodeTimer(
          code: TOTP.generate(widget.token),
          seconds: _seconds,
          minSeconds: 0,
          maxSeconds: 30,
        ),
      ),
    );
  }
}
