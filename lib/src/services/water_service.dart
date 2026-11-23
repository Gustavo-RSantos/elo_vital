import 'dart:convert';
import 'dart:io';

import 'package:elo_vital/src/enums/environment_enum.dart';
import 'package:elo_vital/src/models/water_log_model.dart';
import 'package:elo_vital/src/services/auth_service.dart';
import 'package:elo_vital/src/utils/app_date_format.dart';
import 'package:http/http.dart' as http;

/// Registros de água pela API. Só é usado com USE_LOCAL_DATA=false.
///
/// Contrato sugerido (ajustar com o backend):
/// GET    /water?date=2026-11-20  ->  [{"id", "amountMl", "loggedAt"}]
/// POST   /water {"amountMl", "loggedAt"}  ->  {"id", "amountMl", "loggedAt"}
/// DELETE /water/{id}
class WaterService {
  static const Duration _timeout = Duration(seconds: 5);

  final AuthService authService;

  WaterService({required this.authService});

  Map<String, String> get _headers {
    final token = authService.accessToken;

    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<List<WaterLogModel>> fetchDay(DateTime day) async {
    final uri = Uri.parse(
      '${EnvironmentEnum.apiBaseUrl.value}/water?date=${AppDateFormat.isoDate(day)}',
    );

    final response = await http.get(uri, headers: _headers).timeout(_timeout);
    _checkStatus(response);

    final list = jsonDecode(utf8.decode(response.bodyBytes)) as List<dynamic>;
    return list
        .map((json) => WaterLogModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<WaterLogModel> add({
    required int amountMl,
    required DateTime loggedAt,
  }) async {
    final uri = Uri.parse('${EnvironmentEnum.apiBaseUrl.value}/water');

    final response = await http
        .post(
          uri,
          headers: _headers,
          body: jsonEncode({
            'amountMl': amountMl,
            'loggedAt': loggedAt.toIso8601String(),
          }),
        )
        .timeout(_timeout);
    _checkStatus(response);

    return WaterLogModel.fromJson(
      jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>,
    );
  }

  Future<void> delete(int id) async {
    final uri = Uri.parse('${EnvironmentEnum.apiBaseUrl.value}/water/$id');

    final response = await http
        .delete(uri, headers: _headers)
        .timeout(_timeout);
    _checkStatus(response);
  }

  void _checkStatus(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw HttpException('Erro ${response.statusCode} ao falar com o servidor.');
    }
  }
}
