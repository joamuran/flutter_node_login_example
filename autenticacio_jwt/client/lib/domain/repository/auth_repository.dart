/// Defineix la interfície del repositori per a l'autenticació
abstract class AuthRepository {
  // Modificat. Ara retorna un string.
  Future<bool> login(String username, String password);

  getProtectedResource(
      String endpoint); // Defineix la funció logn que retorna un booleà
}
