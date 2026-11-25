import 'package:elo_vital/src/controller/appointment_controller.dart';
import 'package:elo_vital/src/enums/appointment_reminder_enum.dart';
import 'package:elo_vital/src/models/appointment_model.dart';
import 'package:elo_vital/src/screens/appointment_detail_screen.dart';
import 'package:elo_vital/src/theme/app_colors.dart';
import 'package:elo_vital/src/utils/app_date_format.dart';
import 'package:elo_vital/src/utils/app_pickers.dart';
import 'package:elo_vital/src/utils/form_validators.dart';
import 'package:elo_vital/src/widgets/app_text_field_widget.dart';
import 'package:elo_vital/src/widgets/conflict_dialog.dart';
import 'package:elo_vital/src/widgets/error_message_widget.dart';
import 'package:elo_vital/src/widgets/info_row_widget.dart';
import 'package:elo_vital/src/widgets/loading_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Marcar uma consulta em 4 passos, um de cada vez: consulta, data e hora,
/// local e preparo, e lembretes com o resumo. Com [returnOf], marca um retorno
/// (ou nova tentativa) já com os dados da consulta anterior.
class NewAppointmentScreen extends StatefulWidget {
  const NewAppointmentScreen({super.key, this.returnOf});

  final AppointmentModel? returnOf;

  @override
  State<NewAppointmentScreen> createState() => _NewAppointmentScreenState();
}

class _NewAppointmentScreenState extends State<NewAppointmentScreen> {
  static const int _lastStep = 3;
  static const List<String> _stepTitles = [
    'Qual é a consulta?',
    'Quando será?',
    'Onde será?',
    'Lembretes e resumo',
  ];
  static const List<String> _suggestions = [
    'Clínico geral',
    'Cardiologia',
    'Endocrinologia',
    'Oftalmologia',
    'Ortopedia',
    'Geriatria',
  ];

  final formKey = GlobalKey<FormState>();
  final specialtyController = TextEditingController();
  final doctorController = TextEditingController();
  final dateController = TextEditingController();
  final timeController = TextEditingController();
  final locationController = TextEditingController();
  final preparationController = TextEditingController();

  int step = 0;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  String? stepError;
  final Set<int> selectedReminders = {
    for (final reminder in AppointmentReminderEnum.values) reminder.minutes,
  };
  AppointmentModel? createdAppointment;

  DateTime? get _scheduledAt {
    final date = selectedDate;
    final time = selectedTime;
    if (date == null || time == null) return null;
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  @override
  void initState() {
    super.initState();

    final origin = widget.returnOf;
    if (origin != null) {
      specialtyController.text = origin.specialty;
      doctorController.text = origin.doctorName ?? '';
      locationController.text = origin.location ?? '';
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AppointmentController>().clearError();
    });
  }

  @override
  void dispose() {
    specialtyController.dispose();
    doctorController.dispose();
    dateController.dispose();
    timeController.dispose();
    locationController.dispose();
    preparationController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    FocusScope.of(context).unfocus();
    final picked = await AppPickers.pickFutureDate(
      context,
      initialDate: selectedDate,
      helpText: 'Data da consulta',
    );
    if (picked == null || !mounted) return;

    setState(() {
      selectedDate = picked;
      dateController.text = AppDateFormat.shortDate(picked);
      stepError = null;
    });
  }

  Future<void> _pickTime() async {
    FocusScope.of(context).unfocus();
    final picked = await AppPickers.pickTime(
      context,
      initialTime: selectedTime,
      helpText: 'Horário da consulta',
    );
    if (picked == null || !mounted) return;

    setState(() {
      selectedTime = picked;
      timeController.text = AppPickers.formatTime(picked);
      stepError = null;
    });
  }

  void _next() {
    FocusScope.of(context).unfocus();
    if (!formKey.currentState!.validate()) return;

    if (step == 1 && _scheduledAt!.isBefore(DateTime.now())) {
      setState(() {
        stepError = 'Escolha uma data e um horário que ainda não passaram.';
      });
      return;
    }

    setState(() {
      stepError = null;
      step++;
    });
  }

  void _back() {
    if (step == 0) {
      Navigator.pop(context);
      return;
    }
    setState(() {
      stepError = null;
      step--;
    });
  }

  Future<void> _save() async {
    final scheduledAt = _scheduledAt;
    if (scheduledAt == null) return;

    final controller = context.read<AppointmentController>();

    final conflicts = await controller.findConflicts(scheduledAt: scheduledAt);
    if (!mounted) return;
    if (conflicts.isNotEmpty) {
      final proceed = await showConflictDialog(context, conflicts);
      if (proceed != true || !mounted) return;
    }

    final created = await controller.add(
      specialty: specialtyController.text.trim(),
      doctorName: _nullIfEmpty(doctorController.text),
      scheduledAt: scheduledAt,
      location: _nullIfEmpty(locationController.text),
      preparation: _nullIfEmpty(preparationController.text),
      reminderMinutes: selectedReminders.toList()
        ..sort((a, b) => b.compareTo(a)),
      originAppointmentId: widget.returnOf?.id,
    );
    if (!mounted || created == null) return;

    setState(() => createdAppointment = created);
  }

  String? _nullIfEmpty(String text) {
    final trimmed = text.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  @override
  Widget build(BuildContext context) {
    final created = createdAppointment;

    return PopScope(
      canPop: step == 0 || created != null,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _back();
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Nova consulta')),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: created != null
                ? _buildSuccess(created)
                : _buildStep(context),
          ),
        ),
      ),
    );
  }

  Widget _buildStep(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Passo ${step + 1} de ${_lastStep + 1}', style: textTheme.bodySmall),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: (step + 1) / (_lastStep + 1),
            minHeight: 10,
            color: AppColors.primary,
            backgroundColor: AppColors.surfaceSoft,
          ),
        ),
        const SizedBox(height: 24),
        Text(_stepTitles[step], style: textTheme.headlineSmall),
        const SizedBox(height: 20),
        Form(
          key: formKey,
          child: switch (step) {
            0 => _buildSpecialtyStep(textTheme),
            1 => _buildDateStep(),
            2 => _buildPlaceStep(),
            _ => _buildRemindersStep(textTheme),
          },
        ),
        const SizedBox(height: 24),
        if (stepError != null) ...[
          ErrorMessageWidget(message: stepError!),
          const SizedBox(height: 16),
        ],
        Consumer<AppointmentController>(
          builder: (context, controller, child) {
            final isLast = step == _lastStep;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (isLast && controller.errorMessage != null) ...[
                  ErrorMessageWidget(message: controller.errorMessage!),
                  const SizedBox(height: 16),
                ],
                LoadingButtonWidget(
                  label: isLast ? 'Salvar consulta' : 'Continuar',
                  isLoading: isLast && controller.isSaving,
                  onPressed: isLast ? _save : _next,
                ),
                if (step > 0) ...[
                  const SizedBox(height: 12),
                  OutlinedButton(onPressed: _back, child: const Text('Voltar')),
                ],
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildSpecialtyStep(TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTextFieldWidget(
          controller: specialtyController,
          label: 'Especialidade',
          hint: 'Ex.: Cardiologia',
          textCapitalization: TextCapitalization.sentences,
          textInputAction: TextInputAction.next,
          validator: (value) => FormValidators.requiredField(
            value,
            'Digite a especialidade da consulta.',
          ),
        ),
        const SizedBox(height: 12),
        Text('Ou toque em uma sugestão:', style: textTheme.bodySmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final suggestion in _suggestions)
              ActionChip(
                label: Text(suggestion),
                onPressed: () {
                  setState(() => specialtyController.text = suggestion);
                },
                labelStyle: textTheme.labelMedium?.copyWith(
                  color: AppColors.appointmentText,
                ),
                backgroundColor: AppColors.appointmentSoft,
                side: BorderSide.none,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              ),
          ],
        ),
        const SizedBox(height: 24),
        AppTextFieldWidget(
          controller: doctorController,
          label: 'Nome do médico (opcional)',
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.done,
        ),
      ],
    );
  }

  Widget _buildDateStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTextFieldWidget(
          controller: dateController,
          label: 'Data',
          hint: 'Toque para escolher a data',
          readOnly: true,
          onTap: _pickDate,
          suffixIcon: const Icon(Icons.calendar_today_outlined),
          validator: (value) =>
              FormValidators.requiredField(value, 'Escolha a data da consulta.'),
        ),
        const SizedBox(height: 20),
        AppTextFieldWidget(
          controller: timeController,
          label: 'Horário',
          hint: 'Toque para escolher o horário',
          readOnly: true,
          onTap: _pickTime,
          suffixIcon: const Icon(Icons.schedule),
          validator: (value) => FormValidators.requiredField(
            value,
            'Escolha o horário da consulta.',
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTextFieldWidget(
          controller: locationController,
          label: 'Local (opcional)',
          hint: 'Ex.: Clínica Vida, Rua das Flores, 100',
          textCapitalization: TextCapitalization.sentences,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 20),
        AppTextFieldWidget(
          controller: preparationController,
          label: 'Preparo ou observações (opcional)',
          hint: 'Ex.: ir em jejum, levar os exames',
          textCapitalization: TextCapitalization.sentences,
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildRemindersStep(TextTheme textTheme) {
    final scheduledAt = _scheduledAt;
    final doctor = _nullIfEmpty(doctorController.text);
    final location = _nullIfEmpty(locationController.text);
    final preparation = _nullIfEmpty(preparationController.text);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Quando você quer ser lembrado?', style: textTheme.titleSmall),
        for (final reminder in AppointmentReminderEnum.values)
          CheckboxListTile(
            value: selectedReminders.contains(reminder.minutes),
            onChanged: (checked) {
              setState(() {
                if (checked == true) {
                  selectedReminders.add(reminder.minutes);
                } else {
                  selectedReminders.remove(reminder.minutes);
                }
              });
            },
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
            title: Text(reminder.label, style: textTheme.bodyLarge),
          ),
        const SizedBox(height: 16),
        Text('Resumo', style: textTheme.titleMedium),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                InfoRowWidget(
                  icon: Icons.medical_services_outlined,
                  label: 'Consulta',
                  value: specialtyController.text.trim(),
                ),
                if (doctor != null) ...[
                  const SizedBox(height: 16),
                  InfoRowWidget(
                    icon: Icons.person_outline,
                    label: 'Médico',
                    value: doctor,
                  ),
                ],
                if (scheduledAt != null) ...[
                  const SizedBox(height: 16),
                  InfoRowWidget(
                    icon: Icons.event_outlined,
                    label: 'Data e hora',
                    value:
                        '${AppDateFormat.fullDateWithYear(scheduledAt)} às '
                        '${AppDateFormat.time(scheduledAt)}',
                  ),
                ],
                if (location != null) ...[
                  const SizedBox(height: 16),
                  InfoRowWidget(
                    icon: Icons.place_outlined,
                    label: 'Local',
                    value: location,
                  ),
                ],
                if (preparation != null) ...[
                  const SizedBox(height: 16),
                  InfoRowWidget(
                    icon: Icons.info_outline,
                    label: 'Preparo',
                    value: preparation,
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccess(AppointmentModel created) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 24),
        Semantics(
          liveRegion: true,
          child: Column(
            children: [
              const Icon(Icons.check_circle, size: 96, color: AppColors.success),
              const SizedBox(height: 16),
              Text(
                'Consulta marcada!',
                textAlign: TextAlign.center,
                style: textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Consulta de ${created.specialty} marcada para '
                '${AppDateFormat.dayMonth(created.scheduledAt)} às '
                '${AppDateFormat.hourLabel(created.scheduledAt)}.',
                textAlign: TextAlign.center,
                style: textTheme.bodyLarge,
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    AppointmentDetailScreen(appointmentId: created.id),
              ),
            );
          },
          child: const Text('Ver consulta'),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Voltar às consultas'),
        ),
      ],
    );
  }
}
