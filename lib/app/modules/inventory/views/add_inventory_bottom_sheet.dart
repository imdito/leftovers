import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../data/services/currency_service.dart';
import '../controllers/inventory_controller.dart';

class AddInventoryBottomSheet extends GetView<InventoryController> {
  const AddInventoryBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final currency = CurrencyService();

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
            bottom: 12
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Tambah Makanan", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),

              // Input Nama
              TextField(
                controller: controller.nameController,
                decoration: InputDecoration(
                  labelText: "Nama Makanan (mis: Dada Ayam)",
                  prefixIcon: const Icon(Icons.fastfood_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),

              // Input Harga
              TextField(
                controller: controller.priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Harga (${currency.symbol})",
                  prefixIcon: const Icon(Icons.payments_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),

              // Pilihan Kategori
              const Text("Kategori", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Obx(() => Wrap(
                spacing: 8,
                children: controller.categories.map((cat) {
                  return ChoiceChip(
                    label: Text(cat),
                    selected: controller.selectedCategory.value == cat,
                    onSelected: (selected) {
                      if (selected) controller.selectedCategory.value = cat;
                    },
                    selectedColor: Colors.green.shade100,
                    checkmarkColor: Colors.green.shade800,
                  );
                }).toList(),
              )),
              const SizedBox(height: 16),

              // Input Quantity
              const Text("Jumlah", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Obx(() => Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: controller.quantity.value > 1
                          ? () => controller.decrementQuantity()
                          : null,
                    ),
                    Text(
                      '${controller.quantity.value}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () => controller.incrementQuantity(),
                    ),
                  ],
                ),
              )),
              const SizedBox(height: 16),

              // Pemilihan Tanggal Kedaluwarsa
              const Text("Tanggal Kedaluwarsa", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Obx(() => InkWell(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now().add(const Duration(days: 3)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    controller.setTanggal(date);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        controller.selectedDate.value == null
                            ? "Pilih Tanggal Kedaluwarsa"
                            : DateFormat('dd MMM yyyy').format(controller.selectedDate.value!),
                        style: TextStyle(
                          fontSize: 16,
                          color: controller.selectedDate.value == null ? Colors.grey : Colors.black87,
                        ),
                      ),
                      const Icon(Icons.calendar_today, color: Color(0xFF2E7D32)),
                    ],
                  ),
                ),
              )),
              const SizedBox(height: 24),

              // Tombol Simpan
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: controller.addItem,
                  child: const Text("Simpan ke Kulkas", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}