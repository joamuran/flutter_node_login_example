import 'dart:convert';

// NOU: Importem la nostra llibreria per al client HTTP
import 'package:basic_auth_client/infrastructure/http_service.dart';
import 'package:http/http.dart' as http;

// NOU: Importem la llibreria sharedPreferences
import 'package:shared_preferences/shared_preferences.dart';

class AuthRemoteDataSource {
  // NOU: Instància del client HTTP personalitzat
  late final HttpService _httpService;

  //final String baseUrl;
  //AuthRemoteDataSource(this.baseUrl); // Constructor

  // NOU: Constructor, que inicialitza HttpService
  //      amb la url de base.
  AuthRemoteDataSource(String baseUrl) {
    _httpService = HttpService(baseUrl);
  }
  // Podría simplificar-se amb una llista d'inicialització
  // AuthRemoteDataSource(String baseUrl) : _httpService = HttpService(baseUrl);

  Future<bool> login(String username, String password) async {
    // NOU: Modifiquem les peticions http per tal d'utilitzar
    //      el nostre servei.
    final response = await _httpService.post(
      '/auth/login',
      {"username": username, "password": password},
    );

    if (response.statusCode == 200) {
      // NOU: Obtenim el token de la resposta
      final data = jsonDecode(response.body);

      // NOU:Guardem el token a SharedPreferences
      // Obtenim una instància de sharesPreferences
      final prefs = await SharedPreferences.getInstance();
      // Guardem el token
      await prefs.setString('jwt', data['token']);

      // I validem l'autenticació
      return true; // Retorna el token rebut del servidor
    } else {
      throw Exception('Error d’autenticació');
    }
  }

  Future<http.Response> getProtectedResource(String endpoint) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt');

    if (token == null) throw Exception("L'usuari no està autenticat");

    return _httpService.get(endpoint, headers: {
      "Authorization": "Bearer $token",
    });
  }
}
