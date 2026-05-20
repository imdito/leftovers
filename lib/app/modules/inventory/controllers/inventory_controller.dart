import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import '../../../data/models/inventory_model.dart';
import '../../../data/services/currency_service.dart';
import '../../../data/services/notification_service.dart';

class InventoryController extends GetxController {
  // Inisialisasi Hive Box untuk InventoryItem
  final Box<InventoryItem> inventoryBox = Hive.box<InventoryItem>(
    'inventoryBox',
  );

  // Box sederhana untuk data gamifikasi (uang terselamatkan + streak)
  final Box gamificationBox = Hive.box('gamificationBox');

  var inventoryItems = <InventoryItem>[].obs;
  var filteredInventoryItems = <InventoryItem>[].obs;

  final notificationService = Get.find<NotificationService>();

  // Variabel untuk form input
  final nameController = TextEditingController();
  final priceController = TextEditingController();
  var selectedCategory = 'Sayur'.obs;
  var quantity = 1.obs;
  var selectedDate = Rx<DateTime?>(null);
  final List<String> categories = [
    'Sayur',
    'Buah',
    'Daging',
    'Dairy',
    'Bumbu',
    'Lainnya',
  ];

  // Variabel untuk pencarian
  var allItems = <Map<String, dynamic>>[].obs;
  var filteredItems = <Map<String, dynamic>>[].obs;
  TextEditingController searchController = TextEditingController();

  static const String _kSavedMoneyKey = 'savedMoney';
  static const String _kStreakKey = 'streak';

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
    await item
        .delete(); // Karena pakai HiveObject, bisa langsung panggil .delete()
    loadInventoryItems(); // Refresh tampilan
    Get.snackbar(
      'Terhapus',
      '${item.name} berhasil dikeluarkan dari kulkas',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  Future<void> markCooked(InventoryItem item) async {
    final double itemTotalPrice = item.price * item.quantity;

    // Tambah uang terselamatkan sesuai harga item
    final currentSaved =
        (gamificationBox.get(_kSavedMoneyKey) as num?)?.toDouble() ?? 0.0;
    final newSaved = currentSaved + itemTotalPrice;
    await gamificationBox.put(_kSavedMoneyKey, newSaved);

    await item.delete();
    loadInventoryItems();

    Get.back();
    final currency = CurrencyService(box: gamificationBox);
    Get.snackbar(
      'Mantap!',
      '${item.name} ditandai sudah dimasak. +${currency.formatFromIdr(itemTotalPrice)} terselamatkan',
      snackPosition: SnackPosition.TOP,
      backgroundColor: CupertinoColors.systemGreen,
      colorText: CupertinoColors.white,
    );
  }

  Future<void> markWasted(InventoryItem item) async {
    // Reset streak
    await gamificationBox.put(_kStreakKey, 0);

    await item.delete();
    loadInventoryItems();

    Get.back();
    Get.snackbar(
      'Sayang sekali',
      '${item.name} terbuang.',
      snackPosition: SnackPosition.TOP,
      backgroundColor: CupertinoColors.systemRed,
      colorText: CupertinoColors.white,
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
    final currency = CurrencyService(box: gamificationBox);
    if (nameController.text.isEmpty || selectedDate.value == null) {
      Get.snackbar(
        'Gagal',
        'Nama dan tanggal kedaluwarsa harus diisi!',
        snackPosition: SnackPosition.TOP,
        backgroundColor: CupertinoColors.systemRed,
        colorText: CupertinoColors.white,
      );
      return;
    }

    final rawPrice = priceController.text.trim();
    // Mendukung input desimal dengan titik (.) maupun koma (,)
    final normalizedPrice = rawPrice.replaceAll(',', '.');
    final parsedPrice = double.tryParse(normalizedPrice) ?? 0.0;
    double convertedPrice = parsedPrice;
    if (currency.symbol != 'Rp ') {
      // Jika simbol bukan Rp, konversi dari mata uang terpilih ke IDR
      convertedPrice = currency.convertSelectedToIdr(parsedPrice);
    }

    if (convertedPrice <= 0) {
      Get.snackbar(
        'Gagal',
        'Harga harus diisi dan lebih dari 0!',
        snackPosition: SnackPosition.TOP,
        backgroundColor: CupertinoColors.systemRed,
        colorText: CupertinoColors.white,
      );
      return;
    }

    if (selectedDate.value!.isBefore(DateTime.now())) {
      Get.snackbar(
        'Gagal',
        'Tanggal kedaluwarsa tidak boleh di masa lalu!',
        snackPosition: SnackPosition.TOP,
        backgroundColor: CupertinoColors.systemRed,
        colorText: CupertinoColors.white,
      );
      return;
    }

    if (quantity.value <= 0) {
      Get.snackbar(
        'Gagal',
        'Kuantitas harus lebih dari 0!',
        snackPosition: SnackPosition.TOP,
        backgroundColor: CupertinoColors.systemRed,
        colorText: CupertinoColors.white,
      );
      return;
    }

    final newItem = InventoryItem(
      id: DateTime.now()
          .millisecondsSinceEpoch, // ID unik berdasarkan timestamp
      name: nameController.text,
      quantity: quantity.value,
      expirationDate: selectedDate.value!,
      category: selectedCategory.value,
      price: convertedPrice,
    );

    await inventoryBox.add(newItem);

    // reset form minimal
    nameController.clear();
    priceController.clear();
    resetQuantity();
    selectedDate.value = null;

    if (newItem.expirationDate.difference(DateTime.now()).inDays <= 3) {
      notificationService.showInstantNotification(
        title: "Peringatan !",
        body:
            "${newItem.name} akan kedaluwarsa pada ${DateFormat('d MMM').format(newItem.expirationDate)}",
      );
    } else {
      notificationService.scheduleNotification(
        id: newItem.id,
        title: "Peringatan !",
        body:
            "${newItem.name} akan kedaluwarsa pada ${DateFormat('d MMM').format(newItem.expirationDate)}",
        scheduledTime: newItem.expirationDate.subtract(const Duration(days: 3)),
      );
    }

    loadInventoryItems();
    Get.back();
    Get.snackbar(
      'Berhasil',
      '${newItem.name} berhasil ditambahkan ke kulkas',
      snackPosition: SnackPosition.TOP,
      backgroundColor: CupertinoColors.systemGreen,
      colorText: CupertinoColors.white,
    );
  }

  @override
  void onClose() {
    priceController.dispose();
    super.onClose();
  }
}
