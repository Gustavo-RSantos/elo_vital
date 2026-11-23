import 'package:elo_vital/src/controller/routine_controller.dart';
import 'package:elo_vital/src/enums/activity_type_enum.dart';
import 'package:elo_vital/src/enums/routine_status_enum.dart';
import 'package:elo_vital/src/models/routine_item_model.dart';
import 'package:elo_vital/src/theme/app_colors.dart';
import 'package:elo_vital/src/utils/app_date_format.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Detalhes de um remédio da rotina: confirmar que tomou ("Tomei"), pular a
/// dose ou desfazer. O botão "Tomei" do Início confirma direto, sem abrir esta tela.
class ConfirmMedicineScreen extends StatelessWidget {
  const ConfirmMedicineScreen({super.key, required this.item});

  final RoutineItemModel item;

  Future<void> _skip(BuildContext context, RoutineItemModel current) async {
    final routineController = context.read<RoutineController>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Pular este remédio?'),
          content: const Text(
            'Se puder, converse com o seu médico antes de pular uma dose.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Voltar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Sim, pular'),
            ),
          ],
        );
      },
    );
    if (confirmed != true) return;

    await routineController.setStatus(current, RoutineStatusEnum.skipped);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final routineController = context.watch<RoutineController>();
    final current = routineController.items.firstWhere(
      (element) => element.id == item.id,
      orElse: () => item,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Confirmar remédio')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Espaço da foto do medicamento (a foto virá em um bloco futuro).
              Center(
                child: Semantics(
                  label: 'Imagem do remédio',
                  child: Container(
                    width: 180,
                    height: 180,
                    decoration: const BoxDecoration(
                      color: AppColors.medicineSoft,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      ActivityTypeEnum.medicine.icon,
                      size: 96,
                      color: AppColors.medicine,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                current.title,
                textAlign: TextAlign.center,
                style: textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                current.subtitle,
                textAlign: TextAlign.center,
                style: textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.schedule, color: AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Text(
                    'Horário: ${AppDateFormat.time(current.scheduledAt)}',
                    style: textTheme.bodyLarge,
                  ),
                ],
              ),
              const SizedBox(height: 32),
              if (routineController.errorMessage != null) ...[
                Text(
                  routineController.errorMessage!,
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium?.copyWith(color: AppColors.error),
                ),
                const SizedBox(height: 16),
              ],
              if (current.isDone)
                _buildResult(
                  context,
                  current,
                  icon: Icons.check_circle,
                  color: AppColors.success,
                  title: 'Tudo certo!',
                  message: 'Você tomou o remédio ${current.title}.',
                )
              else if (current.isSkipped)
                _buildResult(
                  context,
                  current,
                  icon: Icons.skip_next_outlined,
                  color: AppColors.textSecondary,
                  title: 'Dose pulada',
                  message:
                      'Se puder, converse com o seu médico sobre as doses puladas.',
                )
              else ...[
                ElevatedButton(
                  onPressed: () => routineController.setStatus(
                    current,
                    RoutineStatusEnum.done,
                  ),
                  child: const Text('Tomei'),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () => _skip(context, current),
                  child: const Text('Pular'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResult(
    BuildContext context,
    RoutineItemModel current, {
    required IconData icon,
    required Color color,
    required String title,
    required String message,
  }) {
    final textTheme = Theme.of(context).textTheme;
    final routineController = context.read<RoutineController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          liveRegion: true,
          child: Column(
            children: [
              Icon(icon, size: 80, color: color),
              const SizedBox(height: 8),
              Text(title, style: textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: textTheme.bodyLarge,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Voltar ao início'),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () =>
              routineController.setStatus(current, RoutineStatusEnum.pending),
          child: const Text('Desfazer'),
        ),
      ],
    );
  }
}
