import 'package:elo_vital/src/enums/activity_type_enum.dart';
import 'package:elo_vital/src/models/routine_item_model.dart';

/// Linha da tabela `routine_items` do SQLite.
class RoutineItemLocalEntity {
  final int? id;
  final int userId;
  final ActivityTypeEnum type;
  final String title;
  final String subtitle;
  final DateTime scheduledAt;
  final bool isDone;

  const RoutineItemLocalEntity({
    this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.scheduledAt,
    required this.isDone,
  });

  factory RoutineItemLocalEntity.fromMap(Map<String, Object?> map) {
    return RoutineItemLocalEntity(
      id: map['id'] as int,
      userId: map['user_id'] as int,
      type: ActivityTypeEnum.values.byName(map['type'] as String),
      title: map['title'] as String,
      subtitle: map['subtitle'] as String,
      scheduledAt: DateTime.parse(map['scheduled_at'] as String),
      isDone: (map['is_done'] as int) == 1,
    );
  }

  factory RoutineItemLocalEntity.fromModel(
    RoutineItemModel model, {
    required int userId,
  }) {
    return RoutineItemLocalEntity(
      id: model.id,
      userId: userId,
      type: model.type,
      title: model.title,
      subtitle: model.subtitle,
      scheduledAt: model.scheduledAt,
      isDone: model.isDone,
    );
  }

  Map<String, Object?> toMap() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'type': type.name,
      'title': title,
      'subtitle': subtitle,
      'scheduled_at': scheduledAt.toIso8601String(),
      'is_done': isDone ? 1 : 0,
    };
  }

  RoutineItemModel toModel() {
    return RoutineItemModel(
      id: id!,
      type: type,
      title: title,
      subtitle: subtitle,
      scheduledAt: scheduledAt,
      isDone: isDone,
    );
  }
}
