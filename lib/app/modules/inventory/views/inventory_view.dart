import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart'; // Buka terminal dan jalankan: flutter pub add intl
import 'package:leftovers/app/modules/inventory/views/add_inventory_bottom_sheet.dart';
import '../controllers/inventory_controller.dart';

class InventoryView extends GetView<InventoryController> {
  const InventoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Isi Kulkasku', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: Obx(() {
        // Jika kulkas kosong
        if (controller.inventoryItems.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.kitchen, size: 80, color: Colors.grey.shade300),
                const SizedBox(height: 16),
                const Text(
                  "Kulkasmu masih kosong!",
                  style: TextStyle(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Yuk, catat bahan makananmu agar tidak mubazir.",
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        // Jika ada isinya
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.inventoryItems.length,
          itemBuilder: (context, index) {
            final item = controller.inventoryItems[index];

            // Hitung sisa hari
            final difference = item.expirationDate.difference(DateTime.now()).inDays;
            Color statusColor = Colors.green;
            String statusText = "Aman";

            if (difference < 0) {
              statusColor = Colors.grey;
              statusText = "Basi";
            } else if (difference <= 2) {
              statusColor = Colors.redAccent;
              statusText = "Kritis ($difference hari)";
            } else if (difference <= 5) {
              statusColor = Colors.orange;
              statusText = "Waspada ($difference hari)";
            }

            return Card(
              elevation: 0,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.fastfood, color: statusColor), // Bisa dibuat dinamis sesuai kategori nanti
                ),
                title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(item.category, style: const TextStyle(fontSize: 12)),
                    Text(
                      'Kedaluwarsa: ${DateFormat('dd MMM yyyy').format(item.expirationDate)}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                  onPressed: () {
                    // Tampilkan dialog konfirmasi sebelum menghapus
                    Get.defaultDialog(
                      title: "Hapus Makanan",
                      middleText: "Yakin ingin membuang ${item.name}?",
                      textConfirm: "Hapus",
                      textCancel: "Batal",
                      confirmTextColor: Colors.white,
                      buttonColor: Colors.redAccent,
                      onConfirm: () {
                        controller.deleteInventoryItem(item);
                        Get.back(); // Tutup dialog
                      },
                    );
                  },
                ),
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF2E7D32),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Tambah", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true, // Wajib agar form bisa tinggi
            backgroundColor: Colors.transparent, // Hilangkan background putih bawaan
            builder: (context) {
              return const AddInventoryBottomSheet();
            },
          );
        },
      ),
    );
  }
}