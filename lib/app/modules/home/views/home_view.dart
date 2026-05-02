import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Latar belakang abu-abu sangat terang
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Halo, Food Warrior! 🦸‍♂️",
              style: TextStyle(
                color: Colors.black87,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "Siap menyelamatkan makanan hari ini?",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.black87),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGamificationCard(),
            const SizedBox(height: 24),
            _buildQuickActions(),
            const SizedBox(height: 32),
            _buildSectionHeader("🚨 Hampir Basi!", "Lihat Semua"),
            const SizedBox(height: 12),
            _buildCriticalItemsList(),

            const SizedBox(height: 32),
            _buildSectionHeader("🎮 Mini Games", "Mainkan"),
            const SizedBox(height: 12),
            _buildMiniGameSection(),
            const SizedBox(height: 70),

          ],
        ),
      ),
      // Tombol Utama untuk Scanner AI
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF2E7D32),
        icon: const Icon(Icons.document_scanner_outlined, color: Colors.white),
        label: const Text("Scan Makanan", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        onPressed: () {
          Get.toNamed("/scan");
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  // Komponen 1: Kartu Gamifikasi & Uang Terselamatkan
  Widget _buildGamificationCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Total Uang Terselamatkan",
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Obx(() {
            // Karena kita sudah punya package intl, kita pakai formatter
            final formatCurrency = NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);
            return Text(
              formatCurrency.format(controller.totalSavedMoney.value),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            );
          }),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.local_fire_department, color: Colors.orangeAccent, size: 18),
                SizedBox(width: 4),
                Text(
                  "5 Hari tanpa Food Waste!",
                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  // Komponen 2: Menu Cepat
  Widget _buildQuickActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _actionButton(Icons.kitchen, "Kulkas", Colors.blue, "/inventory"),
        _actionButton(Icons.menu_book, "Resep", Colors.orange, "/recipes"),
        _actionButton(Icons.map_outlined, "Donasi", Colors.purple, "/donation"),
        _actionButton(Icons.person_outline, "Profil", Colors.teal, "/profile"),
      ],
    );
  }

  Widget _actionButton(IconData icon, String label, Color color, String route) {
    return InkWell(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
      onTap: (){
        Get.toNamed(route);
      },
    );
  }

  // Komponen 3: Header Section
  Widget _buildSectionHeader(String title, String actionText) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        TextButton(
          onPressed: () {},
          child: Text(actionText, style: const TextStyle(color: Color(0xFF2E7D32))),
        ),
      ],
    );
  }

  // Komponen 4: Daftar Makanan Kritis (Mockup Sementara)
  Widget _buildCriticalItemsList() {
    return Obx(() {
      // Jika tidak ada makanan yang mepet kedaluwarsa
      if (controller.criticalItems.isEmpty) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.green.shade200),
          ),
          child: const Column(
            children: [
              Icon(Icons.check_circle_outline, color: Colors.green, size: 40),
              SizedBox(height: 8),
              Text(
                "Aman! Tidak ada makanan yang mau basi.",
                style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );
      }

      // Jika ada makanan kritis, render daftarnya
      return Column(
        children: controller.criticalItems.map((item) {
          final diff = item.expirationDate.difference(DateTime.now()).inDays;

          // Penentuan teks dan warna secara dinamis
          String status = diff == 0 ? "Kedaluwarsa Hari Ini!" : "Tersisa $diff Hari";
          Color statusColor = diff == 0 ? Colors.redAccent : Colors.orange;

          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: _foodItemCard(item.name, status, item.category, statusColor),
          );
        }).toList(), // Ubah list of Widget menjadi children
      );
    });
  }

  Widget _buildMiniGameSection() {
    return Container(
      width: double.infinity,
      height: 400, // Kamu bisa menyesuaikan tingginya agar pas di layar
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      // Menggunakan Clip.hardEdge agar webview tidak keluar dari border radius lengkung
      clipBehavior: Clip.hardEdge,
      child: WebViewWidget(
        controller: controller.webViewController,
      ),
    );
  }

  Widget _foodItemCard(String name, String status, String category, Color statusColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            // Ikon dinamis berdasarkan kategori
            child: Icon(
              category == "Daging" ? Icons.set_meal : category == "Dairy" ? Icons.local_drink : Icons.eco,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  category,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              status,
              style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}