import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '../../../../data/repositories/auth_repository.dart';
import '../../services/auth_service.dart';

class LoginController extends GetxController {
  final AuthRepository repository;

  LoginController({required this.repository});
  final sessionBox = Hive.box('sessionBox');
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final _authService = Get.find<AuthService>();
  var isLoading = false.obs;
  var isPasswordHidden = true.obs;
  var isRememberMe = false.obs;

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  @override
  void onInit() {
    super.onInit();

    if (_authService.token != null && _authService.token!.isNotEmpty) {
      print("Token ditemukan, mencoba login biometrik...");
      onBiometricLoginPressed();
    }
  }

  void toggleRememberMe() {
    isRememberMe.value = !isRememberMe.value;
  }

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  void login() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      Get.snackbar('Gagal', 'Email dan password harus diisi!',
          backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    isLoading.value = true;
    try {
      final result = await repository.login(
        emailController.text,
        passwordController.text,
      );

      if (result['statusCode'] == 200) {
        // Ambil data dari response API
        final userData = result['user'];
        final token = result['token'];

        print("Login Berhasil!");
        print("User: ${userData['name']}");
        print("Token: $token");

        // Simpan session menggunakan Hive
        saveSession(token, userData['name']);

        Get.snackbar('Sukses', 'Selamat datang kembali, ${userData['name']}!',
            backgroundColor: Colors.green, colorText: Colors.white);

        // Arahkan ke halaman utama
        Get.offAllNamed('/home');
      } else {
        Get.snackbar('Gagal', result['message'] ?? 'Email atau password salah',
            backgroundColor: Colors.redAccent, colorText: Colors.white);
      }
    } catch (e) {
      print("Error catch: $e");
      Get.snackbar('Error', 'Koneksi ke server gagal',
          backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  void saveSession(String token, String username) {
    sessionBox.put('token', token);
    sessionBox.put('isLoggedIn', true);
    sessionBox.put('username', username);
    sessionBox.put('expiryTime', DateTime.now().add(const Duration(minutes: 1)).toIso8601String());
  }

  void onBiometricLoginPressed() async {
    bool success = await _authService.authenticateBiometric();

    if (success) {
      // Jika sidik jari oke, kita cek apakah ada token lama
      if (_authService.token != null) {
        Get.offAllNamed('/home');
      } else {
        Get.snackbar('Gagal', 'Silakan login manual dulu.');
      }
    }
  }

}