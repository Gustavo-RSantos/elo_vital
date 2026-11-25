import 'dart:async';
import 'dart:io';

import 'package:elo_vital/src/controller/appointment_controller.dart';
import 'package:elo_vital/src/database/routine_local_repository.dart';
import 'package:elo_vital/src/enums/activity_type_enum.dart';
import 'package:elo_vital/src/enums/appointment_status_enum.dart';
import 'package:elo_vital/src/enums/environment_enum.dart';
import 'package:elo_vital/src/enums/routine_status_enum.dart';
import 'package:elo_vital/src/models/routine_item_model.dart';
import 'package:elo_vital/src/services/routine_service.dart';
import 'package:elo_vital/src/utils/app_date_format.dart';
import 'package:elo_vital/src/utils/error_message_helper.dart';
import 'package:flutter/foundation.dart';

/// Controla a rotina do dia. Com USE_LOCAL_DATA=true (padrão) usa o SQLite;
/// com USE_LOCAL_DATA=false busca na API e, sem conexão, mostra o cache salvo.
///
/// As consultas de hoje não ficam na rotina salva: elas vêm da agenda de
/// consultas (AppointmentController) e entram na lista na hora.
class RoutineController extends ChangeNotifier {
  final RoutineLocalRepository routineLocalRepository;
  final RoutineService routineService;
  final AppointmentController appointmentController;

  RoutineController({
    required this.routineLocalRepository,
    required this.routineService,
    required this.appointmentController,
  }) {
    // Quando uma consulta muda, a rotina do Início se atualiza.
    appointmentController.addListener(notifyListeners);
  }

  List<RoutineItemModel> _storedItems = [];
  bool isLoading = false;
  bool isOfflineMode = false;
  String? errorMessage;
  DateTime? lastSync;

  bool get _useLocalData => EnvironmentEnum.useLocalData.value == 'true';

  /// Rotina salva + consultas de hoje, em ordem de horário.
  List<RoutineItemModel> get items {
    final merged = [..._storedItems, ..._todayAppointmentItems()];
    merged.sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
    return merged;
  }

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
        _storedItems = await routineLocalRepository.getDay(
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

  /// Muda a situação de uma tarefa (feita, pulada ou pendente). A tela
  /// atualiza na hora e volta ao estado anterior se algo der errado.
  /// As consultas não passam por aqui (são atualizadas pela agenda).
  Future<void> setStatus(
    RoutineItemModel item,
    RoutineStatusEnum status,
  ) async {
    final index = _storedItems.indexWhere((current) => current.id == item.id);
    if (index == -1) return;

    final previous = _storedItems[index];
    errorMessage = null;
    _storedItems[index] = previous.copyWith(status: status);
    notifyListeners();

    try {
      await routineLocalRepository.setStatus(item.id, status);
      if (!_useLocalData) {
        // TODO(API): guardar numa fila de sincronização quando estiver offline.
        await routineService.setStatus(item.id, status);
      }
    } catch (error) {
      _storedItems[index] = previous;
      errorMessage = ErrorMessageHelper.fromException(error);
    }
    notifyListeners();
  }

  /// Atalho para marcar como feita (true) ou voltar para pendente (false).
  Future<void> setDone(RoutineItemModel item, bool isDone) {
    return setStatus(
      item,
      isDone ? RoutineStatusEnum.done : RoutineStatusEnum.pending,
    );
  }

  /// Limpa os dados ao sair da conta.
  void clear() {
    _storedItems = [];
    isLoading = false;
    isOfflineMode = false;
    errorMessage = null;
    lastSync = null;
    notifyListeners();
  }

  @override
  void dispose() {
    appointmentController.removeListener(notifyListeners);
    super.dispose();
  }

  /// Consultas de hoje (agendadas ou realizadas) no formato da rotina. O id é
  /// negativo para nunca bater com o id de uma tarefa salva.
  List<RoutineItemModel> _todayAppointmentItems() {
    return appointmentController
        .forDay(DateTime.now())
        .where(
          (item) =>
              item.status == AppointmentStatusEnum.scheduled ||
              item.status == AppointmentStatusEnum.completed,
        )
        .map(
          (item) => RoutineItemModel(
            id: -item.id,
            type: ActivityTypeEnum.appointment,
            title: item.specialty,
            subtitle: item.summaryLine,
            scheduledAt: item.scheduledAt,
            status: item.status == AppointmentStatusEnum.completed
                ? RoutineStatusEnum.done
                : RoutineStatusEnum.pending,
            appointmentId: item.id,
          ),
        )
        .toList();
  }

  Future<void> _loadFromApi(int userId, DateTime today) async {
    try {
      _storedItems = await routineService.fetchDay(today);
      await routineLocalRepository.replaceDay(
        userId: userId,
        day: today,
        items: _storedItems,
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
    _storedItems = await routineLocalRepository.getDay(
      userId: userId,
      day: today,
    );
    isOfflineMode = true;
  }
}
