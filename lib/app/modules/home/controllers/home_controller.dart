import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:leftovers/app/data/models/inventory_model.dart';
import 'package:shake/shake.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../data/services/notification_service.dart';
import '../../auth/services/auth_service.dart';

class HomeController extends GetxController {
  late final WebViewController webViewController;
  final Box<InventoryItem> inventoryBox = Hive.box<InventoryItem>('inventoryBox');
  var criticalItems = <InventoryItem>[].obs;
  final notificationService = Get.put(NotificationService());
  var totalSavedMoney = 0.obs;
  ShakeDetector? shakeDetector;
  @override
  void onInit() {
    super.onInit();
    // 1. Muat data saat halaman Home pertama kali dibuka
    loadHomeData();
    notificationService.init();

    _initEasterEgg();

    WidgetsBinding.instance.addPostFrameCallback((_) {

      notificationService.requestPermission();
    });

    // 2. Dengarkan setiap perubahan di dalam Hive
    inventoryBox.watch().listen((event) {
      loadHomeData();
    });

    webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
    // Langsung muat URL sumber dari iframe kamu
      ..loadRequest(Uri.parse('https://zv1y2i8p.play.gamezop.com/g/H1be5Ef0Qp'));
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
    shakeDetector?.stopListening();
  }

  void checkSecurity() {
    final authService = Get.find<AuthService>();
    if (!authService.isSessionValid) {
      Get.offAllNamed('/login');
      Get.snackbar('Terkunci', 'Sesi berakhir, silakan login kembali.');
    }
  }

  void loadHomeData() {
    final allItems = inventoryBox.values.toList();
    final now = DateTime.now();

    // --- GAMIFIKASI ---
    totalSavedMoney.value = allItems.length * 15000;

    // --- FILTER MAKANAN KRITIS ---
    final almostExpired = allItems.where((item) {
      final diff = item.expirationDate.difference(now).inDays;
      // Ambil yang belum lewat (basi) dan sisa harinya <= 3
      return diff >= 0 && diff <= 3;
    }).toList();

    // Urutkan dari yang paling mendesak (waktunya paling mepet)
    almostExpired.sort((a, b) => a.expirationDate.compareTo(b.expirationDate));

    // Ambil maksimal 3 item saja agar tampilan Home tidak kepanjangan
    criticalItems.assignAll(almostExpired.take(3).toList());
  }
  void _initEasterEgg() {

    print("🚀 Memulai inisialisasi Easter Egg goyangan...");
    // Memulai pendeteksi goyangan secara otomatis
    shakeDetector = ShakeDetector.autoStart(
      shakeThresholdGravity: 3, // Sensitivitas goyangan (makin kecil makin sensitif)
      onPhoneShake: (ShakeEvent event) {
        print("Hp Bergoyang");
        // Cegah dialog muncul berkali-kali kalau HP digoyang terus-terusan
        if (!Get.isDialogOpen!) {
          _begoyangDiaa();
        }
      },
    );
  }

  void _begoyangDiaa() {
    // Memunculkan popup GetX di tengah layar
    Get.dialog(
      Center(
        child: Material(
          color: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '😵‍💫',
                style: TextStyle(fontSize: 100),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Aduh... pusing jangan digoyang-goyang!',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
      // Dialog akan hilang otomatis jika user menyentuh area luar
      barrierDismissible: true,
    );
  }

}
