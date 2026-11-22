/// Erro de autenticação com uma mensagem já pronta para o usuário.
class AuthException implements Exception {
  final String message;

  const AuthException(this.message);

  @override
  String toString() => message;
}
