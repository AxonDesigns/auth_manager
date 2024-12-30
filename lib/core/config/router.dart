import 'package:auth_manager/views.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

enum Routes {
  home(
    label: "Home",
    name: "home",
    path: "/",
  ),
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
  ),
  scanner(
    label: "Scanner",
    name: "scanner",
    path: "/authenticators/scanner",
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
    GoRoute(
      path: Routes.locked.path,
      name: Routes.locked.name,
      pageBuilder: (context, state) => MaterialPage(
        key: state.pageKey,
        child: const LockedPage(),
      ),
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
    //All other routes
    /*GoRoute(
      path: "/:path",
      pageBuilder: (context, state) {
        return MaterialPage(
          key: state.pageKey,
          child: const HomePage(),
        );
      },
    ),*/
    GoRoute(
        path: Routes.authenticators.path,
        pageBuilder: (context, state) {
          return const MaterialPage(
            key: ValueKey("home"),
            child: HomePage(),
          );
        },
        routes: [
          GoRoute(
            path: Routes.scanner.path,
            name: Routes.scanner.name,
            pageBuilder: (context, state) => MaterialPage(
              key: state.pageKey,
              child: const ScannerPage(),
            ),
          ),
        ]),
    GoRoute(
      path: Routes.passwords.path,
      pageBuilder: (context, state) {
        return const MaterialPage(
          key: ValueKey("home"),
          child: HomePage(),
        );
      },
    ),
    GoRoute(
      path: Routes.payments.path,
      pageBuilder: (context, state) {
        return const MaterialPage(
          key: ValueKey("home"),
          child: HomePage(),
        );
      },
    ),
    GoRoute(
      path: Routes.settings.path,
      pageBuilder: (context, state) {
        return const MaterialPage(
          key: ValueKey("home"),
          child: HomePage(),
        );
      },
    ),
  ],
);

final routerProvider = Provider(
  (ref) => router,
);
