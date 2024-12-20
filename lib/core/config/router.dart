import 'package:auth_manager/views.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

var router = GoRouter(
  initialLocation: "/",
  routes: [
    GoRoute(
      path: '/',
      name: "home",
      pageBuilder: (context, state) => MaterialPage(
        key: state.pageKey,
        child: const HomePage(),
      ),
    ),
    GoRoute(
      path: '/about',
      name: "about",
      pageBuilder: (context, state) => MaterialPage(
        key: state.pageKey,
        child: const AboutPage(),
      ),
    ),
    GoRoute(
      path: '/totp',
      name: "totp",
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
