import 'dart:ui';
import 'package:auth_manager/business.dart';
import 'package:auth_manager/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kReleaseMode) {
    await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
  }
  final documentsDir = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(documentsDir.path);
  Hive.registerAdapter(AccountAdapter());
  final accountsBox = await Hive.openBox<Account>("accounts");

  runApp(ProviderScope(
    overrides: [
      accountsProvider.overrideWith((ref) => accountsBox),
    ],
    child: const MainApp(),
  ));
}

class MainApp extends ConsumerStatefulWidget {
  const MainApp({super.key});

  @override
  ConsumerState<MainApp> createState() => _MainAppState();
}

class _MainAppState extends ConsumerState<MainApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    final router = ref.read(routerProvider);
    if (state == AppLifecycleState.paused) {
      router.goNamed("locked", extra: {
        "reason": "App paused",
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {
          PointerDeviceKind.touch,
          PointerDeviceKind.mouse,
          PointerDeviceKind.stylus,
          PointerDeviceKind.invertedStylus,
          PointerDeviceKind.trackpad,
          PointerDeviceKind.unknown,
        },
      ),
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData.from(
        colorScheme: ColorScheme.fromSeed(
          dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
          seedColor: Colors.white,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      builder: (context, child) {
        return AnnotatedRegion(
          value: SystemUiOverlayStyle(
            statusBarColor: Theme.of(context).colorScheme.surface,
            systemNavigationBarColor: Theme.of(context).colorScheme.surface,
          ),
          child: child!,
        );
      },
      routerConfig: ref.read(routerProvider),
    );
  }
}
