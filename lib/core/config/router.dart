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
  ],
);

final routerProvider = Provider(
  (ref) => router,
);
