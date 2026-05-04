import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:leftovers/app/routes/app_pages.dart';

class Recipe {
  final String name;
  final String imageUrl;
  final String description;
  final List<String> ingredients;
  final List<String> steps;
  final String cookTime;
  final String difficulty;
  final String category;

  Recipe({
    required this.name,
    required this.imageUrl,
    required this.description,
    required this.ingredients,
    required this.steps,
    required this.cookTime,
    required this.difficulty,
    required this.category,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    final name = json['name'] ?? '';
    final imageUrl =
        'https://source.unsplash.com/featured/?${name.replaceAll(' ', ',')}';
    return Recipe(
      name: name,
      imageUrl: imageUrl,
      description: json['description'] ?? '',
      ingredients: List<String>.from(json['ingredients'] ?? []),
      steps: List<String>.from(json['steps'] ?? []),
      cookTime: json['cook_time'] ?? '30 menit',
      difficulty: json['difficulty'] ?? 'Mudah',
      category: json['category'] ?? 'Masakan',
    );
  }
}

class RecipeController extends GetxController {
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

  // OpenRouter API key
  static final _apiKey =  dotenv.env['OPENROUTER_API_KEY'];

  // Urutan fallback: kalau model pertama rate-limited, otomatis coba model berikutnya
  static const _fallbackModels = [
    'google/gemma-3-27b-it:free',
    'google/gemma-3n-e4b-it:free',
    'google/gemma-3-12b-it:free',
    'meta-llama/llama-3.2-3b-instruct:free',
    'qwen/qwen3-next-80b-a3b-instruct:free',
    'openai/gpt-oss-20b:free',
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

Berikan 6 rekomendasi resep masakan yang bisa dibuat dari bahan-bahan tersebut (boleh kombinasi dengan bahan dapur umum seperti garam, minyak, bawang).

PENTING: Balas HANYA dengan JSON valid, tanpa teks lain, tanpa markdown, tanpa backtick.

Format JSON yang harus dikembalikan:
{"recipes":[{"name":"Nama Masakan","emoji":"🍛","description":"Deskripsi singkat 1 kalimat","ingredients":["bahan 1 secukupnya","bahan 2 100gr"],"steps":["Langkah 1","Langkah 2","Langkah 3"],"cook_time":"20 menit","difficulty":"Mudah","category":"Masakan Indonesia"}]}
''';

      final response = await _callAnthropicAPI(prompt);
      _parseAndSetRecipes(response);
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
Kamu adalah chef profesional Indonesia. Berikan 6 resep masakan berdasarkan kata kunci: "$query"

PENTING: Balas HANYA dengan JSON valid, tanpa teks lain, tanpa markdown, tanpa backtick.

Format JSON yang harus dikembalikan:
{"recipes":[{"name":"Nama Masakan","emoji":"🍛","description":"Deskripsi singkat 1 kalimat","ingredients":["bahan 1 secukupnya","bahan 2 100gr"],"steps":["Langkah 1","Langkah 2","Langkah 3"],"cook_time":"20 menit","difficulty":"Mudah","category":"Masakan Indonesia"}]}
''';

      final response = await _callAnthropicAPI(prompt);
      _parseAndSetRecipes(response);
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

  // ─── OpenRouter API call dengan fallback otomatis ────
  Future<String> _callAnthropicAPI(String prompt) async {
    final url = Uri.parse('https://openrouter.ai/api/v1/chat/completions');
    Exception? lastError;

    for (final model in _fallbackModels) {
      try {
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
                'messages': [
                  {'role': 'user', 'content': prompt},
                ],
              }),
            )
            .timeout(const Duration(seconds: 30));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          return data['choices'][0]['message']['content'];
        } else if (response.statusCode == 429) {
          // Rate limited — coba model berikutnya
          lastError = Exception('Rate limited: $model');
          continue;
        } else {
          throw Exception(
            'API error: ${response.statusCode} - ${response.body}',
          );
        }
      } catch (e) {
        if (e is Exception && e.toString().contains('Rate limited')) {
          lastError = e;
          continue;
        }
        rethrow;
      }
    }

    throw lastError ??
        Exception('Semua model sedang tidak tersedia, coba lagi nanti.');
  }

  // ─── Parse JSON response dari LLM ─────────────────────
  void _parseAndSetRecipes(String responseText) {
    try {
      // Bersihkan kalau ada backtick atau markdown
      String cleaned = responseText
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();

      final data = json.decode(cleaned);
      final list = (data['recipes'] as List)
          .map((r) => Recipe.fromJson(r))
          .toList();

      recipes.assignAll(list);

      if (recipes.isEmpty) {
        errorMessage.value = 'Tidak ada resep ditemukan.';
      }
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
