import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:local_auth/local_auth.dart';

import '../../../routes/app_pages.dart';

class AuthService extends GetxService {
  final _box = Hive.box('sessionbox');
  final LocalAuthentication _auth = LocalAuthentication();

  // Ambil data sesi
  String? get token => _box.get('token');
  String? get screenLock => _box.get('expiryTime');

  bool get isSessionValid {
    if (token == null || token!.isEmpty) return false;

    // 1. Cek Token Express (JWT)
    bool isTokenExpired = JwtDecoder.isExpired(token!);
    if (isTokenExpired) {
      _box.clear(); // Bersihkan jika token server mati
      return false;
    }

    // 2. Cek Gembok Layar (10 Menit)
    if (screenLock != null) {
      final lockTime = DateTime.parse(screenLock!);
      return DateTime.now().isBefore(lockTime);
    }

    return false;
  }

  // --- UPDATE WAKTU GEMBOK ---
  void refreshScreenLock() {
    final newExpiry = DateTime.now().add(const Duration(minutes: 1));
    _box.put('expiryTime', newExpiry.toIso8601String());
  }

  // --- LOGIN BIOMETRIK ---
  Future<bool> authenticateBiometric() async {
    try {
      bool isSupported = await _auth.isDeviceSupported();
      if (!isSupported) return false;

      return await _auth.authenticate(
        localizedReason: 'Scan sidik jari untuk masuk',
          biometricOnly: true,
      );
    } catch (e) {
      return false;
    }
  }

  // --- LOGOUT ---
  void logout() {
    _box.clear();
    Get.offAllNamed(Routes.AUTH_LOGIN);
  }
}