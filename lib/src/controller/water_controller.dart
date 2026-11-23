import 'package:elo_vital/src/database/water_local_repository.dart';
import 'package:elo_vital/src/enums/environment_enum.dart';
import 'package:elo_vital/src/models/water_log_model.dart';
import 'package:elo_vital/src/services/water_service.dart';
import 'package:elo_vital/src/utils/app_date_format.dart';
import 'package:elo_vital/src/utils/error_message_helper.dart';
import 'package:flutter/foundation.dart';

/// Controla a água bebida no dia. Com USE_LOCAL_DATA=true (padrão) usa o
/// SQLite; com USE_LOCAL_DATA=false usa a API.
class WaterController extends ChangeNotifier {
  /// Meta diária de água. TODO: deixar a pessoa (ou o médico) ajustar a meta.
  static const int dailyGoalMl = 2000;

  final WaterLocalRepository waterLocalRepository;
  final WaterService waterService;

  WaterController({
    required this.waterLocalRepository,
    required this.waterService,
  });

  List<WaterLogModel> logs = [];
  bool isLoading = false;
  String? errorMessage;

  bool get _useLocalData => EnvironmentEnum.useLocalData.value == 'true';

  int get totalMl => logs.fold<int>(0, (sum, log) => sum + log.amountMl);

  double get progress => (totalMl / dailyGoalMl).clamp(0.0, 1.0).toDouble();

  bool get isGoalReached => totalMl >= dailyGoalMl;

  Future<void> loadToday(int userId) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    final today = AppDateFormat.startOfDay(DateTime.now());

    try {
      if (_useLocalData) {
        logs = await waterLocalRepository.getDay(userId: userId, day: today);
      } else {
        try {
          logs = await waterService.fetchDay(today);
        } catch (error) {
          // Sem conexão com a API: mostra o que ficou salvo no celular.
          debugPrint('Sem API, usando o cache local: $error');
          logs = await waterLocalRepository.getDay(userId: userId, day: today);
        }
      }
    } catch (error) {
      errorMessage = ErrorMessageHelper.fromException(error);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addWater({required int userId, required int amountMl}) async {
    errorMessage = null;

    try {
      final loggedAt = DateTime.now();
      final log = _useLocalData
          ? await waterLocalRepository.add(
              userId: userId,
              amountMl: amountMl,
              loggedAt: loggedAt,
            )
          : await waterService.add(amountMl: amountMl, loggedAt: loggedAt);

      logs = [...logs, log];
      notifyListeners();
      return true;
    } catch (error) {
      errorMessage = ErrorMessageHelper.fromException(error);
      notifyListeners();
      return false;
    }
  }

  /// Desfaz o último registro (para o caso de um toque por engano).
  Future<void> undoLast() async {
    if (logs.isEmpty) return;
    errorMessage = null;

    final last = logs.last;
    try {
      if (_useLocalData) {
        await waterLocalRepository.delete(last.id);
      } else {
        await waterService.delete(last.id);
      }
      logs = logs.sublist(0, logs.length - 1);
    } catch (error) {
      errorMessage = ErrorMessageHelper.fromException(error);
    }
    notifyListeners();
  }

  void clearError() {
    if (errorMessage == null) return;
    errorMessage = null;
    notifyListeners();
  }

  /// Limpa os dados ao sair da conta.
  void clear() {
    logs = [];
    isLoading = false;
    errorMessage = null;
    notifyListeners();
  }
}
