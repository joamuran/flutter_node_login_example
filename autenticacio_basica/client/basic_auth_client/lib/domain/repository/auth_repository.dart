/// Defineix la interfície del repositori per a l'autenticació
abstract class AuthRepository {
  Future<bool> login(String username,
      String password); // Defineix la funció logn que retorna un booleà
}
