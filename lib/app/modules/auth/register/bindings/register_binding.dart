import 'package:get/get.dart';
import '../../../../data/providers/auth_provider.dart';
import '../../../../data/repositories/auth_repository.dart';
import '../controllers/register_controller.dart';

class RegisterBinding extends Bindings {
  @override
  void dependencies() {
    // 1. Siapkan Provider
    Get.lazyPut<AuthProvider>(() => AuthProvider());

    // 2. Siapkan Repository (membutuhkan Provider)
    Get.lazyPut<AuthRepository>(() => AuthRepository(Get.find()));

    // 3. Siapkan Controller (membutuhkan Repository)
    Get.lazyPut<RegisterController>(() => RegisterController(repository: Get.find()));
  }
}