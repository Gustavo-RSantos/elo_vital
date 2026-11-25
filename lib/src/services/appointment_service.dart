import 'dart:convert';
import 'dart:io';

import 'package:elo_vital/src/enums/appointment_status_enum.dart';
import 'package:elo_vital/src/enums/environment_enum.dart';
import 'package:elo_vital/src/models/appointment_model.dart';
import 'package:elo_vital/src/services/auth_service.dart';
import 'package:http/http.dart' as http;

/// Consultas pela API (Spring Boot). Só é usado com USE_LOCAL_DATA=false.
///
/// Contrato sugerido (ajustar com o backend; as respostas seguem o formato
/// do AppointmentModel.fromJson):
/// GET   /appointments
/// POST  /appointments {"specialty", "doctorName", "scheduledAt", "location",
///                      "preparation", "reminderMinutes", "originAppointmentId"}
/// PATCH /appointments/{id}/status {"status", "postNotes"}
/// POST  /appointments/{id}/reschedule {"scheduledAt"} -> nova consulta (o
///       backend marca a original como "rescheduled")
class AppointmentService {
  static const Duration _timeout = Duration(seconds: 5);

  final AuthService authService;

  AppointmentService({required this.authService});

  Map<String, String> get _headers {
    final token = authService.accessToken;

    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<List<AppointmentModel>> fetchAll() async {
    final uri = Uri.parse('${EnvironmentEnum.apiBaseUrl.value}/appointments');

    final response = await http.get(uri, headers: _headers).timeout(_timeout);
    _checkStatus(response);

    final list = jsonDecode(utf8.decode(response.bodyBytes)) as List<dynamic>;
    return list
        .map((json) => AppointmentModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<AppointmentModel> add({
    required String specialty,
    String? doctorName,
    required DateTime scheduledAt,
    String? location,
    String? preparation,
    required List<int> reminderMinutes,
    int? originAppointmentId,
  }) {
    return _send('POST', '/appointments', {
      'specialty': specialty,
      'doctorName': doctorName,
      'scheduledAt': scheduledAt.toIso8601String(),
      'location': location,
      'preparation': preparation,
      'reminderMinutes': reminderMinutes,
      'originAppointmentId': originAppointmentId,
    });
  }

  Future<void> updateStatus(
    int id,
    AppointmentStatusEnum status, {
    String? postNotes,
  }) async {
    await _send('PATCH', '/appointments/$id/status', {
      'status': status.name,
      'postNotes': postNotes,
    });
  }

  Future<AppointmentModel> reschedule(int id, DateTime newScheduledAt) {
    return _send('POST', '/appointments/$id/reschedule', {
      'scheduledAt': newScheduledAt.toIso8601String(),
    });
  }

  Future<AppointmentModel> _send(
    String method,
    String path,
    Map<String, Object?> body,
  ) async {
    final uri = Uri.parse('${EnvironmentEnum.apiBaseUrl.value}$path');
    final request = http.Request(method, uri)
      ..headers.addAll(_headers)
      ..body = jsonEncode(body);

    final streamed = await request.send().timeout(_timeout);
    final response = await http.Response.fromStream(streamed);
    _checkStatus(response);

    if (response.bodyBytes.isEmpty) {
      // Respostas sem corpo (ex.: PATCH de status) não devolvem a consulta.
      return AppointmentModel.fromJson(const {
        'id': 0,
        'specialty': '',
        'scheduledAt': '1970-01-01T00:00:00',
        'status': 'scheduled',
      });
    }
    return AppointmentModel.fromJson(
      jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>,
    );
  }

  void _checkStatus(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw HttpException('Erro ${response.statusCode} ao falar com o servidor.');
    }
  }
}
