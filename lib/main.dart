import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app/data/models/inventory_model.dart';
import 'app/data/models/session_box.dart';
import 'app/data/services/notification_service.dart';
import 'app/modules/auth/services/auth_service.dart';
import 'app/routes/app_pages.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await Hive.initFlutter();
  Hive.registerAdapter(InventoryItemAdapter());
  await Hive.openBox<InventoryItem>('inventoryBox');
  await Hive.openBox('sessionBox');
  await Hive.openBox('gamificationBox');

  final authService = Get.put(AuthService());

  runApp(
    GetMaterialApp(
      title: "Application",
      debugShowCheckedModeBanner: false,
      initialRoute: authService.isSessionValid ? Routes.HOME : Routes.AUTH_LOGIN,
      getPages: AppPages.routes,
    ),
  );
}
