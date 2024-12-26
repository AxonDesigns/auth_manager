import 'dart:io';

import 'package:auth_manager/views.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

enum Routes {
  authenticators(
    label: "Authenticators",
    name: "authenticators",
    path: "/authenticators",
  ),
  passwords(
    label: "Passwords",
    name: "passwords",
    path: "/passwords",
  ),
  payments(
    label: "Payments",
    name: "payments",
    path: "/payments",
  ),
  settings(
    label: "Settings",
    name: "settings",
    path: "/settings",
  ),
  totp(
    label: "TOTP",
    name: "totp",
    path: "/totp",
  ),
  locked(
    label: "Locked",
    name: "locked",
    path: "/locked",
  );

  const Routes({
    required this.name,
    required this.path,
    required this.label,
  });

  final String name;
  final String label;
  final String path;
}

var router = GoRouter(
  initialLocation: Routes.locked.path,
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        return MainShell(child: child);
      },
      routes: [
        GoRoute(
          path: Routes.authenticators.path,
          name: Routes.authenticators.name,
          pageBuilder: (context, state) => MaterialPage(
            key: state.pageKey,
            child: const AuthenticatorsPage(),
          ),
        ),
        GoRoute(
          path: Routes.passwords.path,
          name: Routes.passwords.name,
          pageBuilder: (context, state) => MaterialPage(
            key: state.pageKey,
            child: const PasswordsPage(),
          ),
        ),
        GoRoute(
          path: Routes.payments.path,
          name: Routes.payments.name,
          pageBuilder: (context, state) => MaterialPage(
            key: state.pageKey,
            child: const PaymentsPage(),
          ),
        ),
        GoRoute(
          path: Routes.settings.path,
          name: Routes.settings.name,
          pageBuilder: (context, state) => MaterialPage(
            key: state.pageKey,
            child: const SettingsPage(),
          ),
        ),
      ],
    ),
    /*StatefulShellRoute(
      branches: branches,
      navigatorContainerBuilder: (context, navigationShell, children) {
        return MainShell(
          child: child,
        );
      },
    ),*/
    GoRoute(
      path: Routes.locked.path,
      name: Routes.locked.name,
      pageBuilder: (context, state) => MaterialPage(
        key: state.pageKey,
        child: const LockedPage(),
      ),
      redirect: (context, state) {
        if (Platform.isWindows || Platform.isLinux) {
          print("object");
          return Routes.passwords.path;
        }
        return null;
      },
    ),
    GoRoute(
      path: Routes.totp.path,
      name: Routes.totp.name,
      pageBuilder: (context, state) {
        final map = state.extra! as Map<String, dynamic>;
        return MaterialPage(
          key: state.pageKey,
          child: TotpPage(
            name: map["name"] as String,
            token: map["token"] as String,
          ),
        );
      },
    ),
  ],
);

final routerProvider = Provider(
  (ref) => router,
);
