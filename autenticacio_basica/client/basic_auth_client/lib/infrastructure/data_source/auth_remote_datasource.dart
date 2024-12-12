import 'dart:convert';

import 'package:http/http.dart' as http;

class AuthRemoteDataSource {
  final String baseUrl;
  AuthRemoteDataSource(this.baseUrl); // Constructor

  Future<bool> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({'username': username, 'password': password}),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Error d’autenticació');
    }
  }
}
