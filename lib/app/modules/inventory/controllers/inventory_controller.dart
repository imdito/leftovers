import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import '../../../data/models/inventory_model.dart';
import '../../../data/services/notification_service.dart';


class InventoryController extends GetxController {

  // Inisialisasi Hive Box untuk InventoryItem
  final Box<InventoryItem> inventoryBox = Hive.box<InventoryItem>('inventoryBox');
  var inventoryItems = <InventoryItem>[].obs;
  var filteredInventoryItems = <InventoryItem>[].obs;

  final notificationService = Get.find<NotificationService>();

  // Variabel untuk form input
  final nameController = TextEditingController();
  var selectedCategory = 'Sayur'.obs;
  var quantity = 1.obs;
  var selectedDate = Rx<DateTime?>(null);
  final List<String> categories = ['Sayur', 'Buah', 'Daging', 'Dairy', 'Bumbu', 'Lainnya'];

  // Variabel untuk pencarian
  var allItems = <Map<String, dynamic>>[].obs;
  var filteredItems = <Map<String, dynamic>>[].obs;
  TextEditingController searchController = TextEditingController();


  @override
  void onInit() {
    super.onInit();
    loadInventoryItems();
  }

  void loadInventoryItems() {

    final items = inventoryBox.values.toList();
    items.sort((a, b) => a.expirationDate.compareTo(b.expirationDate));

    inventoryItems.assignAll(items);
    filteredInventoryItems.assignAll(items); // Initialize filtered items
  }

  void searchFood(String query) {
    if (query.isEmpty) {
      // Jika kolom pencarian kosong, kembalikan ke list penuh
      filteredInventoryItems.value = List<InventoryItem>.from(inventoryItems);
    } else {
      // Jika ada teks, filter berdasarkan nama makanan
      filteredInventoryItems.value = inventoryItems.where((item) {
        final foodName = item.name.toLowerCase();
        final searchLower = query.toLowerCase();

        // Cek apakah nama makanan mengandung teks yang diketik
        return foodName.contains(searchLower);
      }).toList();
    }
  }

  void deleteInventoryItem(InventoryItem item) async {
    await item.delete(); // Karena pakai HiveObject, bisa langsung panggil .delete()
    loadInventoryItems(); // Refresh tampilan
    Get.snackbar(
      'Terhapus',
      '${item.name} berhasil dikeluarkan dari kulkas',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void setTanggal(DateTime date) {
    selectedDate.value = date;
  }

  void incrementQuantity() {
    quantity.value++;
  }

  void decrementQuantity() {
    if (quantity.value > 1) {
      quantity.value--;
    }
  }

  void resetQuantity() {
    quantity.value = 1;
  }

  Future<void> addItem() async {
    if(nameController.text.isEmpty || selectedDate.value == null){
      Get.snackbar(
        'Gagal',
        'Nama dan tanggal kedaluwarsa harus diisi!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: CupertinoColors.systemRed,
        colorText: CupertinoColors.white,
      );
      return;
    }

    if(selectedDate.value!.isBefore(DateTime.now())) {
      Get.snackbar(
        'Gagal',
        'Tanggal kedaluwarsa tidak boleh di masa lalu!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: CupertinoColors.systemRed,
        colorText: CupertinoColors.white,
      );
      return;
    }

    if(quantity.value <= 0) {
      Get.snackbar(
        'Gagal',
        'Kuantitas harus lebih dari 0!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: CupertinoColors.systemRed,
        colorText: CupertinoColors.white,
      );
      return;
    }

    final newItem = InventoryItem(
      id: DateTime.now().millisecondsSinceEpoch, // ID unik berdasarkan timestamp
      name: nameController.text,
      quantity: quantity.value,
      expirationDate: selectedDate.value!,
      category: selectedCategory.value,
    );

    await inventoryBox.add(newItem);

    if(newItem.expirationDate.difference(DateTime.now()).inDays <= 3) {
      notificationService.showInstantNotification(title: "Peringatan !", body: "${newItem.name} akan kedaluwarsa pada ${DateFormat('d MMM').format(newItem.expirationDate)}");
    }else{
      notificationService.scheduleNotification(
        id: newItem.id,
        title: "Peringatan !",
        body: "${newItem.name} akan kedaluwarsa pada ${DateFormat('d MMM').format(newItem.expirationDate)}",
        scheduledTime: newItem.expirationDate.subtract(const Duration(days: 3)),
      );
    }

    loadInventoryItems();
    Get.back();
    Get.snackbar(
      'Berhasil',
      '${newItem.name} berhasil ditambahkan ke kulkas',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: CupertinoColors.systemGreen,
      colorText: CupertinoColors.white,
    );


  }

  @override
  void onClose() {
    super.onClose();
  }

}
