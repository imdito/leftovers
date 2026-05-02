import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthProvider {
  final String baseUrl = 'http://192.168.0.106:3000/api';

  Future<http.Response> register(String name, String email, String password) {
    return http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
      }),
    );
  }

  Future<http.Response> login(String email, String password) {
    return http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );
  }
}