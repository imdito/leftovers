import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../data/repositories/auth_repository.dart';

class LoginController extends GetxController {
  final AuthRepository repository;

  LoginController({required this.repository});

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  var isLoading = false.obs;
  var isPasswordHidden = true.obs;
  var isRememberMe = false.obs;

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
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

        // Cek di terminal Kitty kamu apakah data dan token berhasil diterima
        print("✅ Login Berhasil!");
        print("User: ${userData['name']}");
        print("Token: $token");

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
}