import 'package:elo_vital/src/enums/appointment_status_enum.dart';
import 'package:elo_vital/src/utils/app_date_format.dart';

/// Uma consulta médica. O médico é só um nome em texto (ele não tem login).
class AppointmentModel {
  final int id;
  final String specialty;
  final String? doctorName;
  final DateTime scheduledAt;
  final String? location;
  final String? preparation;
  final AppointmentStatusEnum status;
  final String? postNotes;

  /// Consulta que originou esta (remarcação ou retorno).
  final int? originAppointmentId;

  /// Antecedência dos lembretes, em minutos (ex.: 1440 e 120).
  final List<int> reminderMinutes;

  const AppointmentModel({
    required this.id,
    required this.specialty,
    this.doctorName,
    required this.scheduledAt,
    this.location,
    this.preparation,
    required this.status,
    this.postNotes,
    this.originAppointmentId,
    this.reminderMinutes = const [],
  });

  /// Ex.: "Dra. Helena Costa, Clínica Vida".
  String get summaryLine {
    final parts = [doctorName, location]
        .whereType<String>()
        .where((part) => part.trim().isNotEmpty)
        .toList();
    return parts.isEmpty ? 'Consulta' : parts.join(', ');
  }

  /// Agendada e ainda por vir.
  bool isUpcoming(DateTime now) {
    return status == AppointmentStatusEnum.scheduled &&
        !scheduledAt.isBefore(now);
  }

  /// Agendada, mas o horário já passou sem a pessoa confirmar se foi.
  bool isPastPending(DateTime now) {
    return status == AppointmentStatusEnum.scheduled &&
        scheduledAt.isBefore(now);
  }

  /// Ex.: "Hoje às 15h", "Amanhã às 9h30" ou "Faltam 3 dias".
  String? countdownLabel(DateTime now) {
    if (!isUpcoming(now)) return null;

    final days = AppDateFormat.daysBetween(now, scheduledAt);
    final hour = AppDateFormat.hourLabel(scheduledAt);
    if (days == 0) return 'Hoje às $hour';
    if (days == 1) return 'Amanhã às $hour';
    return 'Faltam $days dias';
  }

  AppointmentModel copyWith({
    AppointmentStatusEnum? status,
    String? postNotes,
  }) {
    return AppointmentModel(
      id: id,
      specialty: specialty,
      doctorName: doctorName,
      scheduledAt: scheduledAt,
      location: location,
      preparation: preparation,
      status: status ?? this.status,
      postNotes: postNotes ?? this.postNotes,
      originAppointmentId: originAppointmentId,
      reminderMinutes: reminderMinutes,
    );
  }

  /// Contrato sugerido com a API: {"id", "specialty", "doctorName",
  /// "scheduledAt": "2026-11-25T09:30:00", "location", "preparation",
  /// "status": "scheduled" | "completed" | "canceled" | "missed" |
  /// "rescheduled", "postNotes", "originAppointmentId",
  /// "reminderMinutes": [1440, 120]}. Ajustar com o backend.
  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      id: json['id'] as int,
      specialty: json['specialty'] as String,
      doctorName: json['doctorName'] as String?,
      scheduledAt: DateTime.parse(json['scheduledAt'] as String),
      location: json['location'] as String?,
      preparation: json['preparation'] as String?,
      status: AppointmentStatusEnum.values.byName(json['status'] as String),
      postNotes: json['postNotes'] as String?,
      originAppointmentId: json['originAppointmentId'] as int?,
      reminderMinutes: ((json['reminderMinutes'] as List<dynamic>?) ?? [])
          .map((minutes) => minutes as int)
          .toList(),
    );
  }
}
