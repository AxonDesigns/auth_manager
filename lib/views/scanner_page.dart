import 'dart:async';
import 'package:auth_manager/components.dart';
import 'package:auth_manager/core.dart';
import 'package:auth_manager/core/config/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScannerPage extends ConsumerStatefulWidget {
  const ScannerPage({super.key});

  @override
  ConsumerState<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends ConsumerState<ScannerPage>
    with WidgetsBindingObserver {
  final MobileScannerController controller = MobileScannerController(
    autoStart: true,
    facing: CameraFacing.back,
    formats: [
      BarcodeFormat.qrCode,
    ],
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(controller.stop());
    unawaited(controller.start());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (!controller.value.hasCameraPermission) return;
    switch (state) {
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        return;
      case AppLifecycleState.resumed:
        unawaited(controller.start());
      case AppLifecycleState.inactive:
        unawaited(controller.stop());
    }
  }

  @override
  Future<void> dispose() async {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
    await controller.dispose();
  }

  @override
  Widget build(BuildContext outerContext) {
    return Scaffold(
      body: LayoutBuilder(builder: (context, constraints) {
        final center = Offset(
          constraints.maxWidth * 0.5,
          constraints.maxHeight * 0.5,
        );
        final size = constraints.maxWidth - 40;
        final rect = Rect.fromCenter(
          center: center,
          width: size,
          height: size,
        );
        return MobileScanner(
          controller: controller,
          scanWindow: rect,
          overlayBuilder: (context, _) {
            return Stack(
              children: [
                Container(
                  color: Colors.black.withOpacity(0.75),
                ),
                Positioned.fromRect(
                  rect: rect,
                  child: SaveLayer(
                    paint: Paint()..blendMode = BlendMode.dstOut,
                    child: Container(
                      color: Colors.white,
                    ),
                  ),
                ),
                Positioned.fromRect(
                  rect: rect,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      border: Border.all(
                        color: Colors.white,
                        width: 3,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: rect.bottom,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text("Scan a QR code"),
                        const Text("or"),
                        FilledButton.tonal(
                          onPressed: () {
                            ref.read(routerProvider).pop();
                          },
                          child: const Text("Add manually"),
                        )
                      ],
                    ),
                  ),
                )
              ],
            );
          },
          onDetect: (capture) async {
            if (capture.barcodes.isEmpty) return;
            final value = capture.barcodes[0].rawValue;
            if (value == null) return;
            await controller.stop();
            if (!context.mounted) return;
            print(ref
                .read(routerProvider)
                .routerDelegate
                .currentConfiguration
                .routes);
            try {
              ref.read(routerProvider).pop(value);
            } catch (e) {}
          },
        );
      }),
    );
  }
}
