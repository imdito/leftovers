import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app/data/models/inventory_model.dart';
import 'app/routes/app_pages.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(InventoryItemAdapter());
  await Hive.openBox<InventoryItem>('inventoryBox');
  
  runApp(
    GetMaterialApp(
      title: "Application",
      debugShowCheckedModeBanner: false,
      initialRoute: Routes.AUTH_REGISTER,
      getPages: AppPages.routes,
    ),
  );
}
