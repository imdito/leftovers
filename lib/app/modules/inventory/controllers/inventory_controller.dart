import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '../../../data/models/inventory_model.dart';


class InventoryController extends GetxController {

  // Inisialisasi Hive Box untuk InventoryItem
  final Box<InventoryItem> inventoryBox = Hive.box<InventoryItem>('inventoryBox');
  var inventoryItems = <InventoryItem>[].obs;

  // Variabel untuk form input
  final nameController = TextEditingController();
  var selectedCategory = 'Sayur'.obs;
  var quantity = 1.obs;
  var selectedDate = Rx<DateTime?>(null);
  final List<String> categories = ['Sayur', 'Buah', 'Daging', 'Dairy', 'Bumbu', 'Lainnya'];


  @override
  void onInit() {
    super.onInit();
    loadInventoryItems();
  }

  void loadInventoryItems() {

    final items = inventoryBox.values.toList();
    items.sort((a, b) => a.expirationDate.compareTo(b.expirationDate));

    inventoryItems.assignAll(items);
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
