import 'package:auth_manager/components.dart';
import 'package:flutter/material.dart';

class TotpPage extends StatefulWidget {
  const TotpPage({
    super.key,
    required this.name,
    required this.token,
  });

  final String name;
  final String token;

  @override
  State<TotpPage> createState() => _TotpPageState();
}

class _TotpPageState extends State<TotpPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(widget.name),
      ),
      body: Center(
        child: TotpDisplay(
          token: widget.token,
          progressBarHeight: 4,
        ),
      ),
    );
  }
}
