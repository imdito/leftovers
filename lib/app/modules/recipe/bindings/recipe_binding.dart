import 'package:get/get.dart';
import '../controllers/recipe_controller.dart';

class RecipeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RecipeController>(
      () => RecipeController(),
      fenix:
          true, // ← tambah ini, controller tidak akan di-dispose saat navigasi
    );
  }
}
