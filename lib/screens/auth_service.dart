import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthService {
  static const baseUrl = 'http://192.168.199.200:3000/api/user';

  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    final res = await http.post(
      Uri.parse('$baseUrl/login'),
      body: {'email': email, 'password': password},
    );

    if (res.statusCode == 200) {
      return json.decode(res.body);
    } else {
      throw Exception('Login gagal');
    }
  }

  static Future<Map<String, dynamic>> register(
    String username,
    String email,
    String password,
  ) async {
    final res = await http.post(
      Uri.parse('$baseUrl/register'),
      body: {'username': username, 'email': email, 'password': password},
    );

    if (res.statusCode == 200) {
      return json.decode(res.body);
    } else {
      throw Exception('Registrasi gagal');
    }
  }
}
