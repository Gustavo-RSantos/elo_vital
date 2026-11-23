import 'package:elo_vital/src/enums/glucose_moment_enum.dart';
import 'package:elo_vital/src/enums/measurement_type_enum.dart';
import 'package:elo_vital/src/models/measurement_model.dart';

/// Linha da tabela `measurements` do SQLite.
class MeasurementLocalEntity {
  final int? id;
  final int userId;
  final MeasurementTypeEnum type;
  final int? systolic;
  final int? diastolic;
  final int? glucose;
  final GlucoseMomentEnum? glucoseMoment;
  final DateTime measuredAt;

  const MeasurementLocalEntity({
    this.id,
    required this.userId,
    required this.type,
    this.systolic,
    this.diastolic,
    this.glucose,
    this.glucoseMoment,
    required this.measuredAt,
  });

  factory MeasurementLocalEntity.fromMap(Map<String, Object?> map) {
    final moment = map['glucose_moment'] as String?;

    return MeasurementLocalEntity(
      id: map['id'] as int,
      userId: map['user_id'] as int,
      type: MeasurementTypeEnum.values.byName(map['type'] as String),
      systolic: map['systolic'] as int?,
      diastolic: map['diastolic'] as int?,
      glucose: map['glucose'] as int?,
      glucoseMoment: moment == null
          ? null
          : GlucoseMomentEnum.values.byName(moment),
      measuredAt: DateTime.parse(map['measured_at'] as String),
    );
  }

  Map<String, Object?> toMap() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'type': type.name,
      'systolic': systolic,
      'diastolic': diastolic,
      'glucose': glucose,
      'glucose_moment': glucoseMoment?.name,
      'measured_at': measuredAt.toIso8601String(),
    };
  }

  MeasurementModel toModel() {
    return MeasurementModel(
      id: id!,
      type: type,
      systolic: systolic,
      diastolic: diastolic,
      glucose: glucose,
      glucoseMoment: glucoseMoment,
      measuredAt: measuredAt,
    );
  }
}
