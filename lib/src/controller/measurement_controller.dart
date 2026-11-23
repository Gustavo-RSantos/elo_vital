import 'package:elo_vital/src/database/measurement_local_repository.dart';
import 'package:elo_vital/src/enums/environment_enum.dart';
import 'package:elo_vital/src/enums/glucose_moment_enum.dart';
import 'package:elo_vital/src/models/measurement_model.dart';
import 'package:elo_vital/src/services/measurement_service.dart';
import 'package:elo_vital/src/utils/error_message_helper.dart';
import 'package:flutter/foundation.dart';

/// Controla as medições de pressão e glicemia. Com USE_LOCAL_DATA=true
/// (padrão) usa o SQLite; com USE_LOCAL_DATA=false usa a API.
class MeasurementController extends ChangeNotifier {
  static const int _recentLimit = 5;

  final MeasurementLocalRepository measurementLocalRepository;
  final MeasurementService measurementService;

  MeasurementController({
    required this.measurementLocalRepository,
    required this.measurementService,
  });

  List<MeasurementModel> recentMeasurements = [];
  bool isSaving = false;
  String? errorMessage;

  bool get _useLocalData => EnvironmentEnum.useLocalData.value == 'true';

  Future<void> loadRecent(int userId) async {
    errorMessage = null;

    try {
      if (_useLocalData) {
        recentMeasurements = await measurementLocalRepository.getRecent(
          userId: userId,
          limit: _recentLimit,
        );
      } else {
        try {
          recentMeasurements = await measurementService.fetchRecent(
            limit: _recentLimit,
          );
        } catch (error) {
          // Sem conexão com a API: mostra o que ficou salvo no celular.
          debugPrint('Sem API, usando o cache local: $error');
          recentMeasurements = await measurementLocalRepository.getRecent(
            userId: userId,
            limit: _recentLimit,
          );
        }
      }
    } catch (error) {
      errorMessage = ErrorMessageHelper.fromException(error);
    }
    notifyListeners();
  }

  Future<MeasurementModel?> saveBloodPressure({
    required int userId,
    required int systolic,
    required int diastolic,
  }) {
    return _save(() {
      final measuredAt = DateTime.now();

      if (_useLocalData) {
        return measurementLocalRepository.addBloodPressure(
          userId: userId,
          systolic: systolic,
          diastolic: diastolic,
          measuredAt: measuredAt,
        );
      }
      return measurementService.addBloodPressure(
        systolic: systolic,
        diastolic: diastolic,
        measuredAt: measuredAt,
      );
    });
  }

  Future<MeasurementModel?> saveGlucose({
    required int userId,
    required int value,
    required GlucoseMomentEnum moment,
  }) {
    return _save(() {
      final measuredAt = DateTime.now();

      if (_useLocalData) {
        return measurementLocalRepository.addGlucose(
          userId: userId,
          value: value,
          moment: moment,
          measuredAt: measuredAt,
        );
      }
      return measurementService.addGlucose(
        value: value,
        moment: moment,
        measuredAt: measuredAt,
      );
    });
  }

  void clearError() {
    if (errorMessage == null) return;
    errorMessage = null;
    notifyListeners();
  }

  /// Limpa os dados ao sair da conta.
  void clear() {
    recentMeasurements = [];
    isSaving = false;
    errorMessage = null;
    notifyListeners();
  }

  Future<MeasurementModel?> _save(
    Future<MeasurementModel> Function() action,
  ) async {
    isSaving = true;
    errorMessage = null;
    notifyListeners();

    try {
      final measurement = await action();
      recentMeasurements = [
        measurement,
        ...recentMeasurements,
      ].take(_recentLimit).toList();
      return measurement;
    } catch (error) {
      errorMessage = ErrorMessageHelper.fromException(error);
      return null;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }
}
