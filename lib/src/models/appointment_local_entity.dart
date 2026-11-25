import 'package:elo_vital/src/enums/appointment_status_enum.dart';
import 'package:elo_vital/src/models/appointment_model.dart';

/// Linha da tabela `appointments` do SQLite. Os lembretes ficam na tabela
/// `appointment_reminders` e entram no model pelo repository.
class AppointmentLocalEntity {
  final int? id;
  final int userId;
  final String specialty;
  final String? doctorName;
  final DateTime scheduledAt;
  final String? location;
  final String? preparation;
  final AppointmentStatusEnum status;
  final String? postNotes;
  final int? originAppointmentId;

  const AppointmentLocalEntity({
    this.id,
    required this.userId,
    required this.specialty,
    this.doctorName,
    required this.scheduledAt,
    this.location,
    this.preparation,
    required this.status,
    this.postNotes,
    this.originAppointmentId,
  });

  factory AppointmentLocalEntity.fromMap(Map<String, Object?> map) {
    return AppointmentLocalEntity(
      id: map['id'] as int,
      userId: map['user_id'] as int,
      specialty: map['specialty'] as String,
      doctorName: map['doctor_name'] as String?,
      scheduledAt: DateTime.parse(map['scheduled_at'] as String),
      location: map['location'] as String?,
      preparation: map['preparation'] as String?,
      status: AppointmentStatusEnum.values.byName(map['status'] as String),
      postNotes: map['post_notes'] as String?,
      originAppointmentId: map['origin_appointment_id'] as int?,
    );
  }

  Map<String, Object?> toMap() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'specialty': specialty,
      'doctor_name': doctorName,
      'scheduled_at': scheduledAt.toIso8601String(),
      'location': location,
      'preparation': preparation,
      'status': status.name,
      'post_notes': postNotes,
      'origin_appointment_id': originAppointmentId,
    };
  }

  AppointmentModel toModel({required List<int> reminderMinutes}) {
    return AppointmentModel(
      id: id!,
      specialty: specialty,
      doctorName: doctorName,
      scheduledAt: scheduledAt,
      location: location,
      preparation: preparation,
      status: status,
      postNotes: postNotes,
      originAppointmentId: originAppointmentId,
      reminderMinutes: reminderMinutes,
    );
  }
}
