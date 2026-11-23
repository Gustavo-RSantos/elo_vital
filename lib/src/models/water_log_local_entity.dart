import 'package:elo_vital/src/models/water_log_model.dart';

/// Linha da tabela `water_logs` do SQLite.
class WaterLogLocalEntity {
  final int? id;
  final int userId;
  final int amountMl;
  final DateTime loggedAt;

  const WaterLogLocalEntity({
    this.id,
    required this.userId,
    required this.amountMl,
    required this.loggedAt,
  });

  factory WaterLogLocalEntity.fromMap(Map<String, Object?> map) {
    return WaterLogLocalEntity(
      id: map['id'] as int,
      userId: map['user_id'] as int,
      amountMl: map['amount_ml'] as int,
      loggedAt: DateTime.parse(map['logged_at'] as String),
    );
  }

  Map<String, Object?> toMap() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'amount_ml': amountMl,
      'logged_at': loggedAt.toIso8601String(),
    };
  }

  WaterLogModel toModel() {
    return WaterLogModel(id: id!, amountMl: amountMl, loggedAt: loggedAt);
  }
}
