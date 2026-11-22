import 'package:elo_vital/src/enums/activity_type_enum.dart';

/// Uma tarefa da rotina do dia: remédio, medição, água, exercício ou consulta.
class RoutineItemModel {
  final int id;
  final ActivityTypeEnum type;
  final String title;
  final String subtitle;
  final DateTime scheduledAt;
  final bool isDone;

  const RoutineItemModel({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.scheduledAt,
    required this.isDone,
  });

  RoutineItemModel copyWith({bool? isDone}) {
    return RoutineItemModel(
      id: id,
      type: type,
      title: title,
      subtitle: subtitle,
      scheduledAt: scheduledAt,
      isDone: isDone ?? this.isDone,
    );
  }

  /// Contrato sugerido com a API: {"id": 1, "type": "medicine", "title": "...",
  /// "subtitle": "...", "scheduledAt": "2026-11-20T07:30:00", "done": false}.
  /// Os valores de `type` são os nomes do ActivityTypeEnum. Ajustar com o backend.
  factory RoutineItemModel.fromJson(Map<String, dynamic> json) {
    return RoutineItemModel(
      id: json['id'] as int,
      type: ActivityTypeEnum.values.byName(json['type'] as String),
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      scheduledAt: DateTime.parse(json['scheduledAt'] as String),
      isDone: json['done'] as bool,
    );
  }
}
