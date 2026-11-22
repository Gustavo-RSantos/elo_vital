import 'package:elo_vital/src/controller/auth_controller.dart';
import 'package:elo_vital/src/controller/routine_controller.dart';
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

    await context.read<RoutineController>().loadToday(userId);
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
          AppointmentHighlightWidget(item: appointment),
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
              onComplete: () => routineController.setDone(item, true),
              onUndo: () => routineController.setDone(item, false),
            ),
          ),
      ],
    );
  }
}
