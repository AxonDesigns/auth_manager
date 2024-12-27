import 'package:auth_manager/business/biometrics.dart';
import 'package:auth_manager/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LockedPage extends ConsumerStatefulWidget {
  const LockedPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _LockedPageState();
}

class _LockedPageState extends ConsumerState<LockedPage> {
  @override
  void initState() {
    super.initState();
    _authenticate();
  }

  void _authenticate() async {
    final authenticated =
        await requestBiometricAuthentication("Authenticate to unlock");
    if (!authenticated) return;

    final router = ref.read(routerProvider);
    router.go(Routes.passwords.path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: TextButton(
          onPressed: _authenticate,
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock),
              SizedBox(width: 10),
              Text("Authenticate to unlock"),
            ],
          ),
        ),
      ),
    );
  }
}
