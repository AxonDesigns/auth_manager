import 'package:local_auth/local_auth.dart';

Future<bool> requestBiometricAuthentication(String reason) async {
  final LocalAuthentication auth = LocalAuthentication();
  final bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
  final bool canAuthenticate = canAuthenticateWithBiometrics || await auth.isDeviceSupported();

  if (!canAuthenticate) return false;

  final List<BiometricType> availableBiometrics = await auth.getAvailableBiometrics();

  if (availableBiometrics.isEmpty) return false;

  if (!availableBiometrics.contains(BiometricType.strong) && !availableBiometrics.contains(BiometricType.face)) return false;

  try {
    await auth.stopAuthentication();
  } catch (e) {
    // ignore
  }

  await Future.delayed(const Duration(milliseconds: 100));

  try {
    final bool didAuthenticate = await auth.authenticate(
      localizedReason: reason,
    );
    return didAuthenticate;
  } catch (e) {
    return false;
  }
}
