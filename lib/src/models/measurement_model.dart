import 'package:elo_vital/src/enums/glucose_moment_enum.dart';
import 'package:elo_vital/src/enums/measurement_type_enum.dart';
import 'package:elo_vital/src/enums/reading_status_enum.dart';
import 'package:elo_vital/src/utils/health_classifier.dart';

/// Uma medição de saúde: pressão arterial ou glicemia.
class MeasurementModel {
  final int id;
  final MeasurementTypeEnum type;
  final int? systolic;
  final int? diastolic;
  final int? glucose;
  final GlucoseMomentEnum? glucoseMoment;
  final DateTime measuredAt;

  const MeasurementModel({
    required this.id,
    required this.type,
    this.systolic,
    this.diastolic,
    this.glucose,
    this.glucoseMoment,
    required this.measuredAt,
  });

  /// Normal ou Atenção, calculado a partir dos valores.
  ReadingStatusEnum get status {
    if (type == MeasurementTypeEnum.bloodPressure) {
      return HealthClassifier.bloodPressure(
        systolic: systolic!,
        diastolic: diastolic!,
      );
    }
    return HealthClassifier.glucose(value: glucose!, moment: glucoseMoment!);
  }

  /// Ex.: "120 / 80 mmHg" ou "95 mg/dL".
  String get valueLabel {
    if (type == MeasurementTypeEnum.bloodPressure) {
      return '$systolic / $diastolic mmHg';
    }
    return '$glucose mg/dL';
  }

  /// Contrato sugerido com a API: {"id", "type": "bloodPressure" | "glucose",
  /// "systolic", "diastolic", "glucose", "glucoseMoment": "fasting" | ...,
  /// "measuredAt": "2026-11-20T09:00:00"}. Ajustar com o backend.
  factory MeasurementModel.fromJson(Map<String, dynamic> json) {
    final moment = json['glucoseMoment'] as String?;

    return MeasurementModel(
      id: json['id'] as int,
      type: MeasurementTypeEnum.values.byName(json['type'] as String),
      systolic: json['systolic'] as int?,
      diastolic: json['diastolic'] as int?,
      glucose: json['glucose'] as int?,
      glucoseMoment: moment == null
          ? null
          : GlucoseMomentEnum.values.byName(moment),
      measuredAt: DateTime.parse(json['measuredAt'] as String),
    );
  }
}
