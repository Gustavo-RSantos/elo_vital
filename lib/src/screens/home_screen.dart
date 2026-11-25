import 'package:elo_vital/src/controller/appointment_controller.dart';
import 'package:elo_vital/src/controller/auth_controller.dart';
import 'package:elo_vital/src/controller/routine_controller.dart';
import 'package:elo_vital/src/enums/activity_type_enum.dart';
import 'package:elo_vital/src/enums/measurement_type_enum.dart';
import 'package:elo_vital/src/enums/routine_status_enum.dart';
import 'package:elo_vital/src/models/routine_item_model.dart';
import 'package:elo_vital/src/screens/appointment_detail_screen.dart';
import 'package:elo_vital/src/screens/confirm_medicine_screen.dart';
import 'package:elo_vital/src/screens/register_measurement_screen.dart';
import 'package:elo_vital/src/screens/water_screen.dart';
import 'package:elo_vital/src/utils/app_date_format.dart';
import 'package:elo_vital/src/widgets/activity_card_widget.dart';
import 'package:elo_vital/src/widgets/appointment_highlight_widget.dart';
import 'package:elo_vital/src/widgets/day_progress_card_widget.dart';
import 'package:elo_vital/src/widgets/error_message_widget.dart';
import 'package:elo_vital/src/widgets/home_header_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Início: a rotina do dia do idoso. Puxe a tela para baixo para atualizar.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadRoutine());
  }

  Future<void> _loadRoutine() async {
    if (!mounted) return;

    final userId = context.read<AuthController>().currentUser?.id;
    if (userId == null) return;

    // Carrega a rotina e a agenda de consultas juntas (as consultas de hoje
    // entram na lista do Início).
    await Future.wait([
      context.read<AppointmentController>().load(userId),
      context.read<RoutineController>().loadToday(userId),
    ]);
  }

  void _open(Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
  }

  /// Botão principal do cartão: remédio e exercício confirmam na hora; a
  /// medição e a água abrem a tela de registro.
  void _handleAction(RoutineItemModel item) {
    switch (item.type) {
      case ActivityTypeEnum.medicine:
      case ActivityTypeEnum.exercise:
        context.read<RoutineController>().setStatus(
          item,
          RoutineStatusEnum.done,
        );
      case ActivityTypeEnum.measurement:
        _open(
          RegisterMeasurementScreen(
            initialType: _measurementTypeFor(item),
            routineItem: item,
          ),
        );
      case ActivityTypeEnum.water:
        _open(WaterScreen(routineItem: item));
      case ActivityTypeEnum.appointment:
        _openAppointment(item.appointmentId);
    }
  }

  void _openAppointment(int? appointmentId) {
    if (appointmentId == null) return;
    _open(AppointmentDetailScreen(appointmentId: appointmentId));
  }

  /// Por enquanto o tipo vem do título. TODO(API): o backend deve informar o
  /// tipo da medição na própria tarefa.
  MeasurementTypeEnum _measurementTypeFor(RoutineItemModel item) {
    return item.title.toLowerCase().contains('glicemia')
        ? MeasurementTypeEnum.glucose
        : MeasurementTypeEnum.bloodPressure;
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthController>().currentUser;
    final now = DateTime.now();

    return Scaffold(
      body: Consumer<RoutineController>(
        builder: (context, routineController, child) {
          return RefreshIndicator(
            onRefresh: _loadRoutine,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              children: [
                HomeHeaderWidget(
                  userName: user?.firstName ?? '',
                  now: now,
                  syncLabel: AppDateFormat.syncLabel(
                    routineController.lastSync,
                    now,
                  ),
                  isOffline: routineController.isOfflineMode,
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: _buildContent(routineController),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent(RoutineController routineController) {
    final textTheme = Theme.of(context).textTheme;
    final items = routineController.items;

    if (routineController.isLoading && items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 48),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (routineController.errorMessage != null && items.isEmpty) {
      return ErrorMessageWidget(
        message: routineController.errorMessage!,
        onRetry: _loadRoutine,
      );
    }

    final appointment = routineController.todayAppointment;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (routineController.errorMessage != null) ...[
          ErrorMessageWidget(message: routineController.errorMessage!),
          const SizedBox(height: 16),
        ],
        if (appointment != null) ...[
          AppointmentHighlightWidget(
            item: appointment,
            onTap: () => _openAppointment(appointment.appointmentId),
          ),
          const SizedBox(height: 16),
        ],
        DayProgressCardWidget(
          doneCount: routineController.doneCount,
          totalCount: routineController.totalCount,
        ),
        const SizedBox(height: 24),
        Text('Sua rotina de hoje', style: textTheme.titleLarge),
        const SizedBox(height: 16),
        if (items.isEmpty)
          Text(
            'Você não tem tarefas para hoje.',
            style: textTheme.bodyLarge,
          ),
        for (final item in items)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ActivityCardWidget(
              item: item,
              onComplete: () => _handleAction(item),
              onUndo: () => routineController.setDone(item, false),
              onDetails: item.type == ActivityTypeEnum.medicine
                  ? () => _open(ConfirmMedicineScreen(item: item))
                  : null,
            ),
          ),
      ],
    );
  }
}
