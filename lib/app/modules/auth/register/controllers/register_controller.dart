import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../data/repositories/auth_repository.dart';

class RegisterController extends GetxController {
  final AuthRepository repository;

  // Repository disuntikkan (inject) lewat constructor
  RegisterController({required this.repository});

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  var isLoading = false.obs;
  var isPasswordHidden = true.obs;


  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }


  void register() async {
    isLoading.value = true;
    try {
      final result = await repository.register(
        nameController.text,
        emailController.text,
        passwordController.text,
      );

      // Logika sukses/gagal berdasarkan respons dari repository
      if (result['user'] != null) {
        Get.snackbar('Sukses', 'Registrasi berhasil!');
        Get.offNamed('/auth/login');
      } else {
        Get.snackbar('Gagal', result['message'] ?? 'Terjadi kesalahan');
      }
    } catch (e) {
      print("❌ Register Error: $e"); // Log error untuk debugging
      Get.snackbar('Error', 'Koneksi ke server gagal');
    } finally {
      print("✅ Register Response: gagal"); // Log respons untuk debugging
      isLoading.value = false;
    }
  }
}