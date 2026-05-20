import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/scan_controller.dart';
import '../../inventory/controllers/inventory_controller.dart';
import '../../inventory/views/add_inventory_bottom_sheet.dart';

class ScanView extends GetView<ScanController> {
  const ScanView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "Scan Makanan",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- AREA GAMBAR (KLIK UNTUK MENGGANTI/MEMILIH GAMBAR) ---
            Obx(() {
              final file = controller.imageFile.value;
              return GestureDetector(
                onTap: () => _showPickerOptions(context),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: file == null
                      ? _buildPlaceholder()
                      : _buildImagePreview(file),
                ),
              );
            }),

            const SizedBox(height: 24),

            // --- SMART CAMERA ASSISTANT (LIGHT SENSOR) ---
            Obx(() {
              final lux = controller.luxValue.value;
              final isDim = lux < 15; // Ambang batas redup

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isDim ? Colors.orange.shade50 : Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDim ? Colors.orange.shade200 : Colors.green.shade200,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isDim ? Icons.lightbulb_outline : Icons.wb_sunny,
                      color: isDim ? Colors.orange.shade700 : Colors.green.shade700,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        isDim
                            ? "⚠️ Ruangan redup ($lux lux). Disarankan gunakan flash agar deteksi AI akurat!"
                            : "✅ Cahaya ruangan sangat baik ($lux lux) untuk memotret makanan!",
                        style: TextStyle(
                          color: isDim ? Colors.orange.shade900 : Colors.green.shade900,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 24),

            // --- TOMBOL SCAN ---
            Obx(
              () => ElevatedButton.icon(
                onPressed:
                    (controller.isLoading.value ||
                            controller.imageFile.value == null)
                        ? null // Nonaktifkan jika sedang loading atau gambar belum ada
                        : controller.scanFood,
                icon: const Icon(Icons.document_scanner_outlined),
                label: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    controller.isLoading.value
                        ? "Memproses..."
                        : "Scan Makanan",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // --- INDIKATOR LOADING & HASIL SCAN ---
            Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.detectedItems.isEmpty) {
                return const SizedBox.shrink();
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Hasil Deteksi:",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...controller.detectedItems.map(
                    (item) {
                      final raw = item.toString();
                      final name = _cleanDetectedFoodName(raw);

                      return Card(
                        elevation:
                            0, // Menggunakan elevasi 0 dan border untuk tampilan lebih clean
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.grey.shade200),
                        ),
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          onTap: () => _openAddInventoryBottomSheet(
                            context,
                            initialName: name,
                          ),
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.restaurant_menu,
                              color: Colors.green,
                              size: 20,
                            ),
                          ),
                          title: Text(
                            raw,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: const Text("Tap untuk masukkan ke kulkas"),
                          trailing: const Icon(Icons.add),
                        ),
                      );
                    },
                  ),
                ],
              );
            }),

            // Memberikan jarak ekstra di bawah agar konten tidak tertutup FloatingActionButton
            const SizedBox(height: 80),
          ],
        ),
      ),

      // --- TOMBOL GENERATE RESEP (KANAN BAWAH) ---
      floatingActionButton: Obx(() {
        // Hanya tampilkan tombol jika sudah ada hasil deteksi makanan
        if (controller.detectedItems.isEmpty || controller.isLoading.value) {
          return const SizedBox.shrink();
        }

        return FloatingActionButton.extended(
          onPressed: controller.generateRecipe,
          backgroundColor: Colors.orange, // Warna pembeda untuk aksi generate
          foregroundColor: Colors.white,
          elevation: 3,
          icon: const Icon(Icons.auto_awesome),
          label: const Text(
            "Generate Resep",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        );
      }),
    );
  }

  // --- WIDGET BANTUAN ---

  String _cleanDetectedFoodName(String raw) {
    var name = raw.trim();

    // Hapus confidence semacam "(95%)" atau "(0.95)" jika ada.
    final idxParen = name.indexOf('(');
    if (idxParen > 0) {
      name = name.substring(0, idxParen).trim();
    }

    // Hapus trailing separator umum
    name = name.replaceAll(RegExp(r'[-,:]+$'), '').trim();

    return name;
  }

  void _openAddInventoryBottomSheet(
    BuildContext context, {
    required String initialName,
  }) {
    if (initialName.trim().isEmpty) {
      Get.snackbar(
        'Gagal',
        'Item hasil scan tidak valid.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Ambil atau buat InventoryController supaya bottom sheet bisa memakai controller yang sama.
    final InventoryController inventoryController = Get.isRegistered<InventoryController>()
        ? Get.find<InventoryController>()
        : Get.put(InventoryController());

    // Prefill form
    inventoryController.nameController.text = initialName;
    inventoryController.selectedDate.value = null;
    inventoryController.resetQuantity();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return const AddInventoryBottomSheet();
      },
    );
  }

  void _showPickerOptions(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Pilih Sumber Gambar",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.camera_alt_outlined,
                  color: Colors.blue,
                ),
              ),
              title: const Text(
                "Ambil dari Kamera",
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              onTap: () {
                Get.back(); // Tutup bottom sheet
                controller.pickImage(fromCamera: true);
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.photo_library_outlined,
                  color: Colors.purple,
                ),
              ),
              title: const Text(
                "Pilih dari Galeri",
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              onTap: () {
                Get.back(); // Tutup bottom sheet
                controller.pickImage(fromCamera: false);
              },
            ),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      height: 250,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade300,
          width: 2,
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_a_photo_outlined, size: 50, color: Colors.grey[400]),
          const SizedBox(height: 12),
          Text(
            "Ketuk untuk pilih gambar",
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview(File file) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          height: 250,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.file(file, fit: BoxFit.cover),
          ),
        ),
        // Overlay tipis agar user tahu gambar bisa diklik lagi untuk diubah
        Container(
          height: 250,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Center(
            child: Icon(
              Icons.change_circle_outlined,
              color: Colors.white70,
              size: 40,
            ),
          ),
        ),
      ],
    );
  }
}
