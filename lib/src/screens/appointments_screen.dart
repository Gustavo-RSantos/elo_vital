import 'package:elo_vital/src/controller/appointment_controller.dart';
import 'package:elo_vital/src/controller/auth_controller.dart';
import 'package:elo_vital/src/enums/appointment_status_enum.dart';
import 'package:elo_vital/src/models/appointment_model.dart';
import 'package:elo_vital/src/screens/appointment_detail_screen.dart';
import 'package:elo_vital/src/screens/new_appointment_screen.dart';
import 'package:elo_vital/src/theme/app_colors.dart';
import 'package:elo_vital/src/utils/app_date_format.dart';
import 'package:elo_vital/src/widgets/appointment_card_widget.dart';
import 'package:elo_vital/src/widgets/empty_state_widget.dart';
import 'package:elo_vital/src/widgets/error_message_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

/// Aba Consultas: calendário do mês com os dias de consulta marcados, e as
/// listas "Próximas" e "Anteriores".
class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  // Espaço no fim das listas para o botão "Nova consulta" não cobrir o último cartão.
  static const double _bottomSpace = 96;

  late DateTime focusedDay;
  late DateTime selectedDay;

  @override
  void initState() {
    super.initState();
    final today = AppDateFormat.startOfDay(DateTime.now());
    focusedDay = today;
    selectedDay = today;
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    if (!mounted) return;

    final userId = context.read<AuthController>().currentUser?.id;
    if (userId == null) return;

    await context.read<AppointmentController>().load(userId);
  }

  void _openDetail(AppointmentModel appointment) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            AppointmentDetailScreen(appointmentId: appointment.id),
      ),
    );
  }

  void _openNewAppointment() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NewAppointmentScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _openNewAppointment,
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add),
          label: Text(
            'Nova consulta',
            style: textTheme.labelLarge?.copyWith(color: Colors.white),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Consultas', style: textTheme.headlineMedium),
                ),
              ),
              TabBar(
                labelStyle: textTheme.labelLarge,
                unselectedLabelStyle: textTheme.labelLarge,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textSecondary,
                indicatorColor: AppColors.primary,
                dividerColor: AppColors.border,
                tabs: const [
                  Tab(text: 'Calendário'),
                  Tab(text: 'Próximas'),
                  Tab(text: 'Anteriores'),
                ],
              ),
              Expanded(
                child: Consumer<AppointmentController>(
                  builder: (context, controller, child) {
                    if (controller.isLoading && controller.appointments.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (controller.errorMessage != null &&
                        controller.appointments.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.all(24),
                        child: ErrorMessageWidget(
                          message: controller.errorMessage!,
                          onRetry: _load,
                        ),
                      );
                    }

                    return TabBarView(
                      children: [
                        _buildCalendarTab(controller),
                        _buildListTab(
                          appointments: controller.upcoming,
                          emptyTitle: 'Nenhuma consulta marcada',
                          emptyMessage: 'Que tal adicionar a próxima?',
                          showAction: true,
                        ),
                        _buildListTab(
                          appointments: controller.past,
                          emptyTitle: 'Nenhuma consulta anterior',
                          emptyMessage:
                              'As consultas que já passaram aparecem aqui.',
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCalendarTab(AppointmentController controller) {
    final textTheme = Theme.of(context).textTheme;
    final dayAppointments = controller.forDay(selectedDay);

    return RefreshIndicator(
      onRefresh: _load,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, _bottomSpace),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TableCalendar<AppointmentModel>(
              locale: 'pt_BR',
              firstDay: DateTime(2020),
              lastDay: DateTime(2100),
              focusedDay: focusedDay,
              rowHeight: 52,
              daysOfWeekHeight: 32,
              availableCalendarFormats: const {CalendarFormat.month: 'Mês'},
              selectedDayPredicate: (day) => isSameDay(selectedDay, day),
              eventLoader: (day) => controller
                  .forDay(day)
                  .where(
                    (item) =>
                        item.status == AppointmentStatusEnum.scheduled ||
                        item.status == AppointmentStatusEnum.completed,
                  )
                  .toList(),
              onDaySelected: (selected, focused) {
                setState(() {
                  selectedDay = selected;
                  focusedDay = focused;
                });
              },
              onPageChanged: (focused) => focusedDay = focused,
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextFormatter: (date, locale) =>
                    AppDateFormat.monthYear(date),
                titleTextStyle: textTheme.titleMedium!,
                leftChevronIcon: const Icon(
                  Icons.chevron_left,
                  size: 32,
                  color: AppColors.primary,
                ),
                rightChevronIcon: const Icon(
                  Icons.chevron_right,
                  size: 32,
                  color: AppColors.primary,
                ),
              ),
              daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle: textTheme.bodySmall!.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                weekendStyle: textTheme.bodySmall!.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              calendarStyle: CalendarStyle(
                outsideDaysVisible: false,
                defaultTextStyle: textTheme.bodyLarge!,
                weekendTextStyle: textTheme.bodyLarge!,
                todayDecoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary, width: 2),
                ),
                todayTextStyle: textTheme.bodyLarge!.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                ),
                selectedDecoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                selectedTextStyle: textTheme.bodyLarge!.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
                markerDecoration: const BoxDecoration(
                  color: AppColors.orchid,
                  shape: BoxShape.circle,
                ),
                markerSize: 8,
                markersMaxCount: 1,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              AppDateFormat.fullDate(selectedDay),
              style: textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            if (dayAppointments.isEmpty)
              Text(
                'Nenhuma consulta neste dia.',
                style: textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            for (final appointment in dayAppointments)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: AppointmentCardWidget(
                  appointment: appointment,
                  onTap: () => _openDetail(appointment),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildListTab({
    required List<AppointmentModel> appointments,
    required String emptyTitle,
    required String emptyMessage,
    bool showAction = false,
  }) {
    if (appointments.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.event_outlined,
        title: emptyTitle,
        message: emptyMessage,
        actionLabel: showAction ? 'Nova consulta' : null,
        onAction: showAction ? _openNewAppointment : null,
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, _bottomSpace),
        itemCount: appointments.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final appointment = appointments[index];
          return AppointmentCardWidget(
            appointment: appointment,
            onTap: () => _openDetail(appointment),
          );
        },
      ),
    );
  }
}
