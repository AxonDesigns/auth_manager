import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PasswordsPage extends ConsumerStatefulWidget {
  const PasswordsPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PasswordsPageState();
}

class _PasswordsPageState extends ConsumerState<PasswordsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("Passwords"),
      ),
    );
  }
}
