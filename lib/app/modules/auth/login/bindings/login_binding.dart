import 'package:get/get.dart';
import '../../../../data/providers/auth_provider.dart';
import '../../../../data/repositories/auth_repository.dart';
import '../controllers/login_controller.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthProvider>(() => AuthProvider());
    Get.lazyPut<AuthRepository>(() => AuthRepository(Get.find()));
    Get.lazyPut<LoginController>(() => LoginController(repository: Get.find()));
  }
}