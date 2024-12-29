import 'dart:io';

import 'package:auth_manager/business/biometrics.dart';
import 'package:auth_manager/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LockedPage extends ConsumerStatefulWidget {
  const LockedPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _LockedPageState();
}

class _LockedPageState extends ConsumerState<LockedPage> with WidgetsBindingObserver {
  bool get canAuthenticate => Platform.isAndroid || Platform.isIOS;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _authenticate();
    });
  }

  void _authenticate() async {
    if (!canAuthenticate) {
      return;
    }

    final authenticated = await requestBiometricAuthentication("Authenticate to unlock");
    if (!authenticated) return;

    final router = ref.read(routerProvider);
    router.go(Routes.authenticators.path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: TextButton(
          onPressed: () {
            if (!canAuthenticate) {
              final router = ref.read(routerProvider);
              router.go(Routes.authenticators.path);
              return;
            }
            _authenticate();
          },
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
