import 'dart:async';
import 'dart:io';

import 'package:elo_vital/src/database/routine_local_repository.dart';
import 'package:elo_vital/src/enums/activity_type_enum.dart';
import 'package:elo_vital/src/enums/environment_enum.dart';
import 'package:elo_vital/src/models/routine_item_model.dart';
import 'package:elo_vital/src/services/routine_service.dart';
import 'package:elo_vital/src/utils/app_date_format.dart';
import 'package:elo_vital/src/utils/error_message_helper.dart';
import 'package:flutter/foundation.dart';

/// Controla a rotina do dia. Com USE_LOCAL_DATA=true (padrão) usa o SQLite;
/// com USE_LOCAL_DATA=false busca na API e, sem conexão, mostra o cache salvo.
class RoutineController extends ChangeNotifier {
  final RoutineLocalRepository routineLocalRepository;
  final RoutineService routineService;

  RoutineController({
    required this.routineLocalRepository,
    required this.routineService,
  });

  List<RoutineItemModel> items = [];
  bool isLoading = false;
  bool isOfflineMode = false;
  String? errorMessage;
  DateTime? lastSync;

  bool get _useLocalData => EnvironmentEnum.useLocalData.value == 'true';

  int get totalCount => items.length;

  int get doneCount => items.where((item) => item.isDone).length;

  /// Consulta de hoje que ainda não foi concluída (para o destaque do Início).
  RoutineItemModel? get todayAppointment {
    for (final item in items) {
      if (item.type == ActivityTypeEnum.appointment && !item.isDone) {
        return item;
      }
    }
    return null;
  }

  Future<void> loadToday(int userId) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    final today = AppDateFormat.startOfDay(DateTime.now());

    try {
      if (_useLocalData) {
        items = await routineLocalRepository.getDay(
          userId: userId,
          day: today,
          seedIfEmpty: true,
        );
        isOfflineMode = false;
      } else {
        await _loadFromApi(userId, today);
      }
      lastSync = DateTime.now();
    } catch (error) {
      errorMessage = ErrorMessageHelper.fromException(error);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Marca ou desmarca uma tarefa. A tela atualiza na hora e volta ao estado
  /// anterior se algo der errado.
  Future<void> setDone(RoutineItemModel item, bool isDone) async {
    final index = items.indexWhere((current) => current.id == item.id);
    if (index == -1) return;

    final previous = items[index];
    errorMessage = null;
    items[index] = previous.copyWith(isDone: isDone);
    notifyListeners();

    try {
      await routineLocalRepository.setDone(item.id, isDone);
      if (!_useLocalData) {
        // TODO(API): guardar numa fila de sincronização quando estiver offline.
        await routineService.setDone(item.id, isDone);
      }
    } catch (error) {
      items[index] = previous;
      errorMessage = ErrorMessageHelper.fromException(error);
    }
    notifyListeners();
  }

  /// Limpa os dados ao sair da conta.
  void clear() {
    items = [];
    isLoading = false;
    isOfflineMode = false;
    errorMessage = null;
    lastSync = null;
    notifyListeners();
  }

  Future<void> _loadFromApi(int userId, DateTime today) async {
    try {
      items = await routineService.fetchDay(today);
      await routineLocalRepository.replaceDay(
        userId: userId,
        day: today,
        items: items,
      );
      isOfflineMode = false;
    } on TimeoutException catch (error) {
      await _loadFromCache(userId, today, error);
    } on SocketException catch (error) {
      await _loadFromCache(userId, today, error);
    } on HttpException catch (error) {
      await _loadFromCache(userId, today, error);
    }
  }

  /// Sem conexão com a API: mostra o que ficou salvo no celular.
  Future<void> _loadFromCache(int userId, DateTime today, Object error) async {
    debugPrint('Sem API, usando o cache local: $error');
    items = await routineLocalRepository.getDay(userId: userId, day: today);
    isOfflineMode = true;
  }
}
