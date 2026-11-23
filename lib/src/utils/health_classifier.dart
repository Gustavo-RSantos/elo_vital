import 'package:elo_vital/src/enums/glucose_moment_enum.dart';
import 'package:elo_vital/src/enums/reading_status_enum.dart';

/// Classifica as medições em "Normal" ou "Atenção".
///
/// IMPORTANTE: são faixas gerais de referência, só para orientar a pessoa. Elas
/// devem ser validadas com um profissional de saúde antes do uso real, e não
/// substituem a orientação do médico.
class HealthClassifier {
  HealthClassifier._();

  /// Pressão normal: máxima abaixo de 130 e mínima abaixo de 85, sem ficar
  /// baixa demais (máxima abaixo de 90 ou mínima abaixo de 60).
  static ReadingStatusEnum bloodPressure({
    required int systolic,
    required int diastolic,
  }) {
    if (systolic < 90 || diastolic < 60) return ReadingStatusEnum.attention;
    if (systolic >= 130 || diastolic >= 85) return ReadingStatusEnum.attention;
    return ReadingStatusEnum.normal;
  }

  /// Em jejum ou antes da refeição: de 70 a 99 mg/dL.
  /// Depois da refeição: de 70 a 139 mg/dL.
  static ReadingStatusEnum glucose({
    required int value,
    required GlucoseMomentEnum moment,
  }) {
    final upperLimit = moment == GlucoseMomentEnum.afterMeal ? 140 : 100;
    if (value < 70 || value >= upperLimit) return ReadingStatusEnum.attention;
    return ReadingStatusEnum.normal;
  }

  static String messageFor(ReadingStatusEnum status) {
    return switch (status) {
      ReadingStatusEnum.normal => 'Muito bem! Este valor está dentro do esperado.',
      ReadingStatusEnum.attention =>
        'Este valor está fora do esperado. Se você sentir algo diferente ou se '
            'isso se repetir, procure o seu médico.',
    };
  }

  static const String disclaimer =
      'Esta classificação é só uma referência e não substitui a orientação do '
      'seu médico.';
}
