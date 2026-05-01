import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ProfileService extends GetxService {
  Future<void> syncPhotoIdToExpress(String fileId) async {
    final String token = Hive.box('sessionbox').get('token');
    final String baseUrl = dotenv.env['EXPRESS_API_URL']!;

    final response = await http.put(
      Uri.parse('$baseUrl/profile/update-photo'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'profile_photo': fileId}),
    );

    if (response.statusCode != 200) {
      throw Exception("Gagal sinkron ke Express: ${response.body}");
    }
  }
}