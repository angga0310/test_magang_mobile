import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:perpustakaan_magang/database/api.dart';
import 'package:perpustakaan_magang/model/user.dart';

class ApiService {
  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    final response = await http.post(
      Uri.parse('${Api.login}'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'email': email,
        'password': password,
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final user = User.fromJson(data['user']);
      return {'success': true, 'user': user};
    } else {
      return {'success': false, 'message': 'Login gagal'};
    }
  }
}
