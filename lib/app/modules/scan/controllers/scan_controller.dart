import 'dart:io';
import 'dart:async';
import 'package:light/light.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:leftovers/app/routes/app_pages.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class ScanController extends GetxController {
  final ImagePicker _picker = ImagePicker();

  var imageFile = Rx<File?>(null);
  var detectedItems = <String>[].obs;
  var isLoading = false.obs;
  
  var luxValue = 0.obs;
  Light? _light;
  StreamSubscription? _subscription;

  late Interpreter interpreter;
  late List<String> labels;

  late int inputSize;
  late int outputSize;

  @override
  void onInit() {
    super.onInit();
    loadModel();
    startLightSensor();
  }

  void startLightSensor() {
    _light = Light();
    try {
      _subscription = _light?.lightSensorStream.listen((int lux) {
        luxValue.value = lux;
      });
    } catch (e) {
      print("❌ ERROR startLightSensor: $e");
    }
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }

  // =========================
  // LOAD MODEL
  // =========================
  Future<void> loadModel() async {
    try {
      interpreter = await Interpreter.fromAsset('assets/model/model.tflite');

      final inputShape = interpreter.getInputTensor(0).shape;
      final outputShape = interpreter.getOutputTensor(0).shape;

      inputSize = inputShape[1];
      outputSize = outputShape[1];

      print("📥 Input shape: $inputShape");
      print("📤 Output shape: $outputShape");

      final labelData = await rootBundle.loadString('assets/model/labels.txt');

      labels = labelData.split('\n').where((e) => e.trim().isNotEmpty).toList();

      print("🏷 Labels loaded: ${labels.length}");
    } catch (e) {
      print("❌ ERROR loadModel: $e");
    }
  }

  // =========================
  // PICK IMAGE (KAMERA / GALERI)
  // =========================
  Future<void> pickImage({required bool fromCamera}) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
        imageQuality: 80,
      );

      if (pickedFile == null) {
        print("❌ tidak ada gambar diambil");
        return;
      }

      imageFile.value = File(pickedFile.path);

      // Bersihkan hasil deteksi sebelumnya jika user mengganti gambar
      detectedItems.clear();
    } catch (e) {
      print("❌ ERROR pickImage: $e");
      Get.snackbar("Error", "Gagal mengambil gambar");
    }
  }

  // =========================
  // SCAN MAKANAN (PROSES TFLITE)
  // =========================
  Future<void> scanFood() async {
    if (imageFile.value == null) {
      Get.snackbar("Peringatan", "Silakan pilih gambar terlebih dahulu");
      return;
    }

    print("📸 tombol scan ditekan, mulai mendeteksi...");
    await detectFood(imageFile.value!);
  }

  // =========================
  // DETECT FOOD (LOGIKA INTI ANDA)
  // =========================
  Future<void> detectFood(File image) async {
    print("🚀 detectFood mulai");
    isLoading.value = true;

    try {
      // 1. Read image
      final bytes = await image.readAsBytes();
      print("📦 image bytes loaded");

      final oriImage = img.decodeImage(bytes);

      if (oriImage == null) {
        print("❌ decode gagal");
        Get.snackbar("Error", "Gagal membaca gambar");
        isLoading.value = false;
        return;
      }

      print("🧠 image decoded");

      // 2. Resize
      final resized = img.copyResize(
        oriImage,
        width: inputSize,
        height: inputSize,
      );

      print("📏 resize selesai ($inputSize)");

      // 3. Convert to tensor
      var input = List.generate(
        1,
        (_) => List.generate(
          inputSize,
          (y) => List.generate(inputSize, (x) {
            final p = resized.getPixel(x, y);
            return [
              (p.r - 127.5) / 127.5,
              (p.g - 127.5) / 127.5,
              (p.b - 127.5) / 127.5,
            ];
          }),
        ),
      );

      print("📊 tensor siap");

      // 4. Output buffer
      var output = List.filled(outputSize, 0.0).reshape([1, outputSize]);

      print("🎯 output buffer siap");

      // 5. RUN MODEL
      print("⚡ mulai inference...");

      interpreter.run(input, output);

      print("✅ inference selesai");

      // 6. Process result
      List<double> scores = List<double>.from(output[0]);

      List<Map<String, dynamic>> results = [];

      for (int i = 0; i < scores.length; i++) {
        results.add({
          "label": i < labels.length ? labels[i] : "unknown",
          "score": scores[i],
        });
      }

      results.sort((a, b) => b["score"].compareTo(a["score"]));

      print("🔥 top result: ${results.first}");

      // Filter hasil yang tingkat kepercayaannya > 10%
      final filtered = results.where((e) => e["score"] > 0.1).take(3).toList();

      detectedItems.value = filtered
          .map(
            (e) =>
                "${formatLabel(e["label"])} (${(e["score"] * 100).toStringAsFixed(1)}%)",
          )
          .toList();
    } catch (e, s) {
      print("❌ ERROR detectFood: $e");
      print("🧵 STACKTRACE:\n$s");
      Get.snackbar("Error", "Terjadi kesalahan saat memproses gambar");
    }

    isLoading.value = false;
    print("🏁 detectFood selesai");
  }

  // =========================
  // FORMAT LABEL
  // =========================
  String formatLabel(String raw) {
    raw = raw.toLowerCase();

    if (raw.contains("chicken")) return "Ayam";
    if (raw.contains("egg")) return "Telur";
    if (raw.contains("rice")) return "Nasi";
    if (raw.contains("banana")) return "Pisang";

    return raw; // Jika tidak ada translasi, kembalikan teks aslinya
  }

  // =========================
  // GENERATE RESEP (KE LLM)
  // =========================
  void generateRecipe() {
    if (detectedItems.isEmpty) return;

    // Ekstrak nama bahan tanpa persentase (misal: "Ayam (95.0%)" -> "Ayam")
    final ingredients = detectedItems.map((item) {
      return item.split(' (')[0].trim();
    }).toList();

    print("🍳 Memulai generate resep ke halaman Recipe...");
    print("📋 Bahan yang dikirim: ${ingredients.join(', ')}");

    Get.toNamed(Routes.RECIPE, arguments: {'ingredients': ingredients});
  }
}
