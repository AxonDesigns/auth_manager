import 'dart:ui';
import 'package:auth_manager/business.dart';
import 'package:auth_manager/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

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

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

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
      routerConfig: router,
    );
  }
}
