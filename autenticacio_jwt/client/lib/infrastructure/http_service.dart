import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart'; // Per IOClient

// Creem la classe HttpService, que serà la que ens `proporcione
// una implementació de la calsse HTTPCLient que accepte certificats no segurs.
class HttpService {
  final String baseUrl;

  // El constructor rep la URL de base
  HttpService(this.baseUrl);

  // Creem una funció que retorne un un client HTTP
  //personalitzat que accepte certificats autofirmats
  HttpClient createHttpClient() {
    final client = HttpClient(); // Creem el client

    client.badCertificateCallback =
        (X509Certificate cert, String host, int port) {
      // print("Certificat rebut: $host, Port: $port"); // Depuració
      return true; // Accepta certificats autofirmats, només en desenvolupament
    };
    return client;
  }

  // Implementació dels mètodes GET i POST

  // Mètode POST
  Future<http.Response> post(String endpoint, Map<String, dynamic> body) async {
    // Fem ús de la implementació de baix nivell IOClient:
    // Creem un IOClient, i li passem com a argument la funció
    // que crea el nostre client amb el mètode badCertificateCallback
    // Compte! Possiblement no funcione en web!
    final ioClient = IOClient(createHttpClient());
    final url = Uri.parse('$baseUrl$endpoint');

    return ioClient.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );
  }

  // Mètode GET

  /* Versió sense headers
  Future<http.Response> get(String endpoint) async {
    final ioClient = IOClient(createHttpClient());
    final url = Uri.parse('$baseUrl$endpoint');

    return ioClient.get(
      url,
      headers: {"Content-Type": "application/json"},
    );
  }*/

  Future<http.Response> get(String endpoint,
      {Map<String, String>? headers}) async {
    final ioClient =
        IOClient(createHttpClient()); // Usa el client personalitzat

    final url = Uri.parse('$baseUrl$endpoint');

    return ioClient.get(url, headers: headers);
  }
}
