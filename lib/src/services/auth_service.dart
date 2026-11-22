import 'dart:convert';
import 'dart:io';

import 'package:elo_vital/src/enums/environment_enum.dart';
import 'package:elo_vital/src/models/user_model.dart';
import 'package:elo_vital/src/services/auth_exception.dart';
import 'package:elo_vital/src/utils/app_date_format.dart';
import 'package:http/http.dart' as http;

/// Login e cadastro pela API (Spring Boot). Só é usado quando o app roda com
/// --dart-define=USE_LOCAL_DATA=false. Enquanto a API não existe, o app usa o
/// AuthLocalRepository.
///
/// Contrato sugerido (ajustar com o backend):
/// POST /auth/login    {"email", "password"}
/// POST /auth/register {"name", "email", "password", "birthDate", "profile"}
/// Resposta: {"accessToken": "...", "user": {"id", "name", "email", "birthDate"}}
class AuthService {
  static const Duration _timeout = Duration(seconds: 5);

  /// Token JWT da sessão atual. Os próximos services o enviam no cabeçalho
  /// Authorization. TODO: guardar o token com segurança para restaurar a sessão.
  String? accessToken;

  Future<UserModel> login({required String email, required String password}) {
    return _post('/auth/login', {'email': email, 'password': password});
  }

  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    required DateTime birthDate,
  }) {
    return _post('/auth/register', {
      'name': name,
      'email': email,
      'password': password,
      'birthDate': AppDateFormat.isoDate(birthDate),
      'profile': 'IDOSO',
    });
  }

  Future<UserModel> _post(String path, Map<String, Object?> body) async {
    final uri = Uri.parse('${EnvironmentEnum.apiBaseUrl.value}$path');

    final response = await http
        .post(
          uri,
          headers: const {'Content-Type': 'application/json'},
          body: jsonEncode(body),
        )
        .timeout(_timeout);

    if (response.statusCode == 401) {
      throw const AuthException('E-mail ou senha incorretos.');
    }
    if (response.statusCode == 409) {
      throw const AuthException('Já existe uma conta com este e-mail.');
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw HttpException('Erro ${response.statusCode} ao falar com o servidor.');
    }

    final json =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    accessToken = json['accessToken'] as String?;
    return UserModel.fromJson(json['user'] as Map<String, dynamic>);
  }
}
