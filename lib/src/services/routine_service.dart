import 'dart:convert';
import 'dart:io';

import 'package:elo_vital/src/enums/environment_enum.dart';
import 'package:elo_vital/src/models/routine_item_model.dart';
import 'package:elo_vital/src/services/auth_service.dart';
import 'package:elo_vital/src/utils/app_date_format.dart';
import 'package:http/http.dart' as http;

/// Rotina do dia pela API (Spring Boot). Só é usado com
/// --dart-define=USE_LOCAL_DATA=false.
///
/// Contrato sugerido (ajustar com o backend):
/// GET   /routine?date=2026-11-20  ->  [{"id", "type", "title", "subtitle",
///                                      "scheduledAt", "done"}]
/// PATCH /routine/{id}  {"done": true}
class RoutineService {
  static const Duration _timeout = Duration(seconds: 5);

  final AuthService authService;

  RoutineService({required this.authService});

  Map<String, String> get _headers {
    final token = authService.accessToken;

    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<List<RoutineItemModel>> fetchDay(DateTime day) async {
    final uri = Uri.parse(
      '${EnvironmentEnum.apiBaseUrl.value}/routine?date=${AppDateFormat.isoDate(day)}',
    );

    final response = await http.get(uri, headers: _headers).timeout(_timeout);
    _checkStatus(response);

    final list = jsonDecode(utf8.decode(response.bodyBytes)) as List<dynamic>;
    return list
        .map((json) => RoutineItemModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> setDone(int id, bool isDone) async {
    final uri = Uri.parse('${EnvironmentEnum.apiBaseUrl.value}/routine/$id');

    final response = await http
        .patch(uri, headers: _headers, body: jsonEncode({'done': isDone}))
        .timeout(_timeout);
    _checkStatus(response);
  }

  void _checkStatus(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw HttpException('Erro ${response.statusCode} ao falar com o servidor.');
    }
  }
}
