import 'package:elo_vital/src/enums/activity_type_enum.dart';
import 'package:elo_vital/src/enums/routine_status_enum.dart';

/// Uma tarefa da rotina do dia: remédio, medição, água, exercício ou consulta.
class RoutineItemModel {
  final int id;
  final ActivityTypeEnum type;
  final String title;
  final String subtitle;
  final DateTime scheduledAt;
  final RoutineStatusEnum status;

  /// Só nas consultas: id da consulta que originou esta tarefa (a tarefa é
  /// montada na hora a partir da agenda de consultas).
  final int? appointmentId;

  const RoutineItemModel({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.scheduledAt,
    required this.status,
    this.appointmentId,
  });

  bool get isDone => status == RoutineStatusEnum.done;

  bool get isSkipped => status == RoutineStatusEnum.skipped;

  RoutineItemModel copyWith({RoutineStatusEnum? status}) {
    return RoutineItemModel(
      id: id,
      type: type,
      title: title,
      subtitle: subtitle,
      scheduledAt: scheduledAt,
      status: status ?? this.status,
      appointmentId: appointmentId,
    );
  }

  /// Contrato sugerido com a API: {"id": 1, "type": "medicine", "title": "...",
  /// "subtitle": "...", "scheduledAt": "2026-11-20T07:30:00",
  /// "status": "pending" | "done" | "skipped"}.
  /// Os valores de `type` são os nomes do ActivityTypeEnum. Ajustar com o backend.
  factory RoutineItemModel.fromJson(Map<String, dynamic> json) {
    return RoutineItemModel(
      id: json['id'] as int,
      type: ActivityTypeEnum.values.byName(json['type'] as String),
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      scheduledAt: DateTime.parse(json['scheduledAt'] as String),
      status: RoutineStatusEnum.values.byName(json['status'] as String),
      appointmentId: json['appointmentId'] as int?,
    );
  }
}
