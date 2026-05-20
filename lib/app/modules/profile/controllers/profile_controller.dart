import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:leftovers/app/modules/profile/controllers/profile_service.dart';
import '../../../services/appwrite_service.dart';
import '../../auth/services/auth_service.dart';

class ProfileController extends GetxController {

  //profile
  final AppwriteService _appwrite = AppwriteService();
  final ImagePicker _picker = ImagePicker();
  var profilePhotoId = "".obs;
  late String userId;
  final ProfileService _profileService = Get.put(ProfileService());
  //logout
  final _authService = Get.find<AuthService>();
  final _box = Hive.box('sessionBox');

  var isLoading = false.obs;
  // Ambil nama pengguna dari Hive
  var userName = "".obs;

  @override
  void onInit() {
    super.onInit();
    // Ambil nama dari Hive yang disimpan saat login
    userName.value = _box.get('username', defaultValue: "User");
    getUserId();
  }

  void getUserId(){
    isLoading.value = true;
    final String token = Hive.box('sessionBox').get('token');
    Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
    userId = decodedToken['id'].toString();
    isLoading.value = false;
  }

  Future<void> pickImage() async {
    isLoading.value = true;
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 50,
      );

      if (pickedFile == null) return;
      // 1. Upload ke Appwrite
      final String? fileId = await _appwrite.uploadProfileImage(pickedFile, userId);
      if (fileId == null) throw Exception("Upload Appwrite Gagal");

      // 2. Sinkronisasi ke Express (Panggil dari ProfileService)
      await _profileService.syncPhotoIdToExpress(fileId);

      final String imageUrl = _appwrite.getImageUrl(fileId);

      // B. Paksa Flutter menghapus URL tersebut dari memori
      await NetworkImage(imageUrl).evict();

      // 3. Update State & UI
      profilePhotoId.value = fileId;
      Hive.box('sessionBox').put('profilePhotoId', fileId);

      Get.snackbar("Sukses", "Foto profil diperbarui!");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void logout() {
    _authService.logout();
  }
}