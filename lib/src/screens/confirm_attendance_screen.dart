import 'package:elo_vital/src/controller/appointment_controller.dart';
import 'package:elo_vital/src/models/appointment_model.dart';
import 'package:elo_vital/src/screens/new_appointment_screen.dart';
import 'package:elo_vital/src/theme/app_colors.dart';
import 'package:elo_vital/src/widgets/app_text_field_widget.dart';
import 'package:elo_vital/src/widgets/error_message_widget.dart';
import 'package:elo_vital/src/widgets/loading_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// "Fui à consulta": registra que a pessoa foi, guarda o que o médico disse e
/// pergunta se ela quer marcar o retorno.
class ConfirmAttendanceScreen extends StatefulWidget {
  const ConfirmAttendanceScreen({super.key, required this.appointment});

  final AppointmentModel appointment;

  @override
  State<ConfirmAttendanceScreen> createState() =>
      _ConfirmAttendanceScreenState();
}

class _ConfirmAttendanceScreenState extends State<ConfirmAttendanceScreen> {
  final notesController = TextEditingController();
  bool saved = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AppointmentController>().clearError();
    });
  }

  @override
  void dispose() {
    notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    final controller = context.read<AppointmentController>();
    final notes = notesController.text.trim();

    final success = await controller.confirmAttendance(
      widget.appointment,
      postNotes: notes.isEmpty ? null : notes,
    );
    if (!mounted || !success) return;

    setState(() => saved = true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fui à consulta')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: saved ? _buildSaved(context) : _buildForm(context),
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Como foi a consulta de ${widget.appointment.specialty}?',
          style: textTheme.headlineSmall,
        ),
        const SizedBox(height: 20),
        AppTextFieldWidget(
          controller: notesController,
          label: 'O que o médico disse? (opcional)',
          hint: 'Ex.: pediu exames, mudou a dose do remédio',
          textCapitalization: TextCapitalization.sentences,
          maxLines: 4,
        ),
        const SizedBox(height: 24),
        Consumer<AppointmentController>(
          builder: (context, controller, child) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (controller.errorMessage != null) ...[
                  ErrorMessageWidget(message: controller.errorMessage!),
                  const SizedBox(height: 16),
                ],
                LoadingButtonWidget(
                  label: 'Salvar',
                  isLoading: controller.isSaving,
                  onPressed: _save,
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Voltar'),
        ),
      ],
    );
  }

  Widget _buildSaved(BuildContext context) {
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
                'Consulta registrada!',
                textAlign: TextAlign.center,
                style: textTheme.headlineMedium,
              ),
              const SizedBox(height: 12),
              Text(
                'Quer marcar o retorno?',
                textAlign: TextAlign.center,
                style: textTheme.titleMedium,
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
                    NewAppointmentScreen(returnOf: widget.appointment),
              ),
            );
          },
          child: const Text('Marcar retorno'),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Agora não'),
        ),
      ],
    );
  }
}
