import 'dart:convert';
import '../providers/auth_provider.dart';

class AuthRepository {
  final AuthProvider api;

  AuthRepository(this.api);

  Future<Map<String, dynamic>> register(String name, String email, String password) async {
    final response = await api.register(name, email, password);
    print("🌐 Status Code Server: ${response.statusCode}");
    print("📄 Raw Body Server: ${response.body}");
    return jsonDecode(response.body);
  }
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await api.login(email, password);
    final data = jsonDecode(response.body);

    // Sisipkan status code agar controller tahu apakah request sukses (200) atau gagal (401)
    data['statusCode'] = response.statusCode;
    return data;
  }
}