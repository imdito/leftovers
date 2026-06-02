import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:leftovers/app/routes/app_pages.dart';

class Recipe {
  final String name;
  final String imageUrl;
  final String emoji;
  final String description;
  final List<String> ingredients;
  final List<String> steps;
  final String cookTime;
  final String difficulty;
  final String category;

  Recipe({
    required this.name,
    required this.imageUrl,
    required this.emoji,
    required this.description,
    required this.ingredients,
    required this.steps,
    required this.cookTime,
    required this.difficulty,
    required this.category,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      name: json['name'] ?? '',
      imageUrl: '', // diisi setelah fetch Pixabay
      emoji: json['emoji'] ?? '🍽️',
      description: json['description'] ?? '',
      ingredients: List<String>.from(json['ingredients'] ?? []),
      steps: List<String>.from(json['steps'] ?? []),
      cookTime: json['cook_time'] ?? '30 menit',
      difficulty: json['difficulty'] ?? 'Mudah',
      category: json['category'] ?? 'Masakan',
    );
  }

  Recipe copyWith({String? imageUrl}) {
    return Recipe(
      name: name,
      imageUrl: imageUrl ?? this.imageUrl,
      emoji: emoji,
      description: description,
      ingredients: ingredients,
      steps: steps,
      cookTime: cookTime,
      difficulty: difficulty,
      category: category,
    );
  }
}

class RecipeController extends GetxController {
  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments;
    List<String>? initialIngredients;

    if (args is List<String>) {
      initialIngredients = args.cast<String>();
    } else if (args is Map<String, dynamic> && args['ingredients'] is List) {
      initialIngredients = (args['ingredients'] as List).cast<String>();
    }

    if (initialIngredients != null && initialIngredients.isNotEmpty) {
      activeTab.value = 0;
      ingredients.assignAll(initialIngredients);
      generateRecipesFromIngredients();
    }
  }

  // ─── State ────────────────────────────────────────────
  final isLoading = false.obs;
  final isLoadingDetail = false.obs;
  final recipes = <Recipe>[].obs;
  final selectedRecipe = Rxn<Recipe>();
  final errorMessage = ''.obs;
  final searchQuery = ''.obs;

  // Input bahan dari user
  final ingredientController = TextEditingController();
  final ingredients = <String>[].obs;

  // Search resep by nama
  final searchController = TextEditingController();

  // Tab: 0 = dari bahan, 1 = cari resep
  final activeTab = 0.obs;

  // API keys
  static final _apiKey = dotenv.env['OPENROUTER_API_KEY'];
  static final _pixabayKey = dotenv.env['PIXABAY_API_KEY'];

  // Urutan fallback: kalau model pertama rate-limited, otomatis coba model berikutnya
  static const _fallbackModels = [
    // cepat + pintar untuk JSON
    'google/gemini-2.0-flash-exp:free',
    'qwen/qwen3-14b:free',
    'z-ai/glm-4.5-air:free',

    // fallback kualitas
    'openai/gpt-oss-20b:free',
    'mistralai/mistral-7b-instruct:free',

    // emergency fallback
    'meta-llama/llama-3.2-3b-instruct:free',
  ];

  @override
  void onClose() {
    ingredientController.dispose();
    searchController.dispose();
    super.onClose();
  }

  // ─── 1. Tambah bahan ke list ───────────────────────────
  void addIngredient() {
    final text = ingredientController.text.trim();
    if (text.isEmpty) return;
    if (!ingredients.contains(text)) {
      ingredients.add(text);
    }
    ingredientController.clear();
  }

  void removeIngredient(String item) {
    ingredients.remove(item);
  }

  // ─── 2. Generate resep dari bahan (LLM) ───────────────
  Future<void> generateRecipesFromIngredients() async {
    if (ingredients.isEmpty) {
      Get.snackbar(
        'Oops!',
        'Tambahkan minimal 1 bahan dulu ya',
        backgroundColor: Colors.orange[100],
        colorText: Colors.orange[900],
      );
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';
    recipes.clear();
    selectedRecipe.value = null;

    try {
      final bahan = ingredients.join(', ');
      final prompt =
          '''
Kamu adalah chef profesional Indonesia. Berdasarkan bahan-bahan berikut yang ada di rumah dan mungkin akan segera basi: $bahan

Berikan 3 rekomendasi resep masakan yang bisa dibuat dari bahan-bahan tersebut (boleh kombinasi dengan bahan dapur umum seperti garam, minyak, bawang).

PENTING: Balas HANYA dengan JSON valid, tanpa teks lain, tanpa markdown, tanpa backtick.

Format JSON yang harus dikembalikan:
{"recipes":[{"name":"Nama Masakan","emoji":"🍛","description":"Deskripsi singkat 1 kalimat","ingredients":["bahan 1 secukupnya","bahan 2 100gr"],"steps":["Langkah 1","Langkah 2","Langkah 3"],"cook_time":"20 menit","difficulty":"Mudah","category":"Masakan Indonesia"}]}
''';

      final response = await _callOpenRouterAPI(prompt);
      await _parseAndSetRecipes(response);
    } catch (e) {
      errorMessage.value = 'Gagal generate resep: $e';
    } finally {
      isLoading.value = false;
    }
  }

  // ─── 3. Cari resep by nama/keyword ────────────────────
  Future<void> searchRecipes() async {
    final query = searchController.text.trim();
    if (query.isEmpty) {
      Get.snackbar(
        'Oops!',
        'Masukkan nama masakan atau bahan dulu',
        backgroundColor: Colors.orange[100],
        colorText: Colors.orange[900],
      );
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';
    recipes.clear();
    selectedRecipe.value = null;

    try {
      final prompt =
          '''
Kamu adalah chef profesional Indonesia. Berikan 3 resep masakan berdasarkan kata kunci: "$query"

PENTING: Balas HANYA dengan JSON valid, tanpa teks lain, tanpa markdown, tanpa backtick.

Format JSON yang harus dikembalikan:
{"recipes":[{"name":"Nama Masakan","emoji":"🍛","description":"Deskripsi singkat 1 kalimat","ingredients":["bahan 1 secukupnya","bahan 2 100gr"],"steps":["Langkah 1","Langkah 2","Langkah 3"],"cook_time":"20 menit","difficulty":"Mudah","category":"Masakan Indonesia"}]}
''';

      final response = await _callOpenRouterAPI(prompt);
      await _parseAndSetRecipes(response);
    } catch (e) {
      errorMessage.value = 'Gagal mencari resep: $e';
    } finally {
      isLoading.value = false;
    }
  }

  // ─── 4. Get detail resep lengkap ─────────────────────
  Future<void> getRecipeDetail(Recipe recipe) async {
    print('>>> tap registered: ${recipe.name}');
    selectedRecipe.value = recipe;
    print('>>> navigating to: ${Routes.RECIPE_DETAIL}');
    Get.toNamed(Routes.RECIPE_DETAIL);
  }

  // ─── Pixabay image search ─────────────────────────────
  Future<String> _searchFoodImage(String recipeName) async {
    if (_pixabayKey == null || _pixabayKey!.isEmpty) return '';
    try {
      // Coba query bahasa Indonesia dulu, fallback ke English
      for (final query in [recipeName, '$recipeName food']) {
        final url = Uri.parse(
          'https://pixabay.com/api/'
          '?key=$_pixabayKey'
          '&q=${Uri.encodeComponent(query)}'
          '&image_type=photo'
          '&category=food'
          '&min_width=400'
          '&per_page=3'
          '&safesearch=true',
        );

        final response = await http
            .get(url)
            .timeout(const Duration(seconds: 10));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final hits = data['hits'] as List;
          if (hits.isNotEmpty) {
            return hits[0]['webformatURL']?.toString() ?? '';
          }
        }
      }
    } catch (_) {}
    return ''; // fallback ke emoji di view
  }

  // ─── OpenRouter API call dengan fallback otomatis ────
  Future<String> _callOpenRouterAPI(String prompt) async {
    final url = Uri.parse('https://openrouter.ai/api/v1/chat/completions');

    Object? lastError;

    for (final model in _fallbackModels) {
      try {
        debugPrint('🔄 Trying model: $model');

        final response = await http
            .post(
              url,
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer $_apiKey',
              },
              body: json.encode({
                'model': model,
                'max_tokens': 2000,
                'temperature': 0.7,
                'messages': [
                  {'role': 'user', 'content': prompt},
                ],
              }),
            )
            .timeout(const Duration(seconds: 60));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);

          debugPrint('✅ Success with $model');

          return data['choices'][0]['message']['content'];
        }

        debugPrint('❌ $model failed: ${response.statusCode}');

        lastError = 'HTTP ${response.statusCode}: ${response.body}';

        continue;
      } catch (e) {
        debugPrint('❌ $model error: $e');

        lastError = e;

        // INI YANG PENTING
        // lanjut model berikutnya
        continue;
      }
    }

    throw Exception('Semua model gagal. Last error: $lastError');
  }

  // ─── Parse JSON + fetch gambar paralel ────────────────
  Future<void> _parseAndSetRecipes(String responseText) async {
    try {
      String cleaned = responseText
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();

      final start = cleaned.indexOf('{');
      final end = cleaned.lastIndexOf('}');

      if (start != -1 && end != -1) {
        cleaned = cleaned.substring(start, end + 1);
      }

      final data = json.decode(cleaned);

      // Tampilkan resep dulu tanpa gambar (cepat)
      final rawList = (data['recipes'] as List)
          .map((r) => Recipe.fromJson(r))
          .toList();
      recipes.assignAll(rawList);

      if (recipes.isEmpty) {
        errorMessage.value = 'Tidak ada resep ditemukan.';
        return;
      }

      // Fetch semua gambar secara paralel di background
      final imageUrls = await Future.wait(
        rawList.map((r) => _searchFoodImage(r.name)),
      );

      // Update list dengan gambar yang sudah dapat
      final updatedList = rawList.asMap().entries.map((entry) {
        return entry.value.copyWith(imageUrl: imageUrls[entry.key]);
      }).toList();

      recipes.assignAll(updatedList);
    } catch (e) {
      errorMessage.value = 'Gagal memproses resep dari AI: $e';
    }
  }

  // ─── Helper ────────────────────────────────────────────
  Color difficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'mudah':
        return Colors.green;
      case 'sedang':
        return Colors.orange;
      case 'sulit':
        return Colors.red;
      default:
        return Colors.green;
    }
  }
}
