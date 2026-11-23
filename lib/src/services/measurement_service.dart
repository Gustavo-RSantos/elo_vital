import 'dart:convert';
import 'dart:io';

import 'package:elo_vital/src/enums/environment_enum.dart';
import 'package:elo_vital/src/enums/glucose_moment_enum.dart';
import 'package:elo_vital/src/models/measurement_model.dart';
import 'package:elo_vital/src/services/auth_service.dart';
import 'package:http/http.dart' as http;

/// Medições de saúde pela API. Só é usado com USE_LOCAL_DATA=false.
///
/// Contrato sugerido (ajustar com o backend):
/// POST /measurements/blood-pressure {"systolic", "diastolic", "measuredAt"}
/// POST /measurements/glucose        {"value", "moment", "measuredAt"}
/// GET  /measurements?limit=5
/// As respostas seguem o formato do MeasurementModel.fromJson.
class MeasurementService {
  static const Duration _timeout = Duration(seconds: 5);

  final AuthService authService;

  MeasurementService({required this.authService});

  Map<String, String> get _headers {
    final token = authService.accessToken;

    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<MeasurementModel> addBloodPressure({
    required int systolic,
    required int diastolic,
    required DateTime measuredAt,
  }) {
    return _post('/measurements/blood-pressure', {
      'systolic': systolic,
      'diastolic': diastolic,
      'measuredAt': measuredAt.toIso8601String(),
    });
  }

  Future<MeasurementModel> addGlucose({
    required int value,
    required GlucoseMomentEnum moment,
    required DateTime measuredAt,
  }) {
    return _post('/measurements/glucose', {
      'value': value,
      'moment': moment.name,
      'measuredAt': measuredAt.toIso8601String(),
    });
  }

  Future<List<MeasurementModel>> fetchRecent({int limit = 5}) async {
    final uri = Uri.parse(
      '${EnvironmentEnum.apiBaseUrl.value}/measurements?limit=$limit',
    );

    final response = await http.get(uri, headers: _headers).timeout(_timeout);
    _checkStatus(response);

    final list = jsonDecode(utf8.decode(response.bodyBytes)) as List<dynamic>;
    return list
        .map((json) => MeasurementModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<MeasurementModel> _post(String path, Map<String, Object?> body) async {
    final uri = Uri.parse('${EnvironmentEnum.apiBaseUrl.value}$path');

    final response = await http
        .post(uri, headers: _headers, body: jsonEncode(body))
        .timeout(_timeout);
    _checkStatus(response);

    return MeasurementModel.fromJson(
      jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>,
    );
  }

  void _checkStatus(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw HttpException('Erro ${response.statusCode} ao falar com o servidor.');
    }
  }
}
