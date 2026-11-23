import 'package:elo_vital/src/controller/auth_controller.dart';
import 'package:elo_vital/src/controller/routine_controller.dart';
import 'package:elo_vital/src/controller/water_controller.dart';
import 'package:elo_vital/src/enums/routine_status_enum.dart';
import 'package:elo_vital/src/models/routine_item_model.dart';
import 'package:elo_vital/src/theme/app_colors.dart';
import 'package:elo_vital/src/utils/app_date_format.dart';
import 'package:elo_vital/src/utils/app_number_format.dart';
import 'package:elo_vital/src/widgets/error_message_widget.dart';
import 'package:elo_vital/src/widgets/water_glass_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Água do dia: meta, copo que se enche, botões "+200 ml" e "+300 ml" e a lista
/// de registros. Se veio de uma tarefa da rotina, ela é marcada como feita.
class WaterScreen extends StatefulWidget {
  const WaterScreen({super.key, this.routineItem});

  final RoutineItemModel? routineItem;

  @override
  State<WaterScreen> createState() => _WaterScreenState();
}

class _WaterScreenState extends State<WaterScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    if (!mounted) return;

    final userId = context.read<AuthController>().currentUser?.id;
    if (userId == null) return;

    await context.read<WaterController>().loadToday(userId);
  }

  Future<void> _add(int amountMl) async {
    final userId = context.read<AuthController>().currentUser?.id;
    if (userId == null) return;

    final waterController = context.read<WaterController>();
    final routineController = context.read<RoutineController>();

    final success = await waterController.addWater(
      userId: userId,
      amountMl: amountMl,
    );

    final routineItem = widget.routineItem;
    if (success && routineItem != null) {
      await routineController.setStatus(routineItem, RoutineStatusEnum.done);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Água')),
      body: SafeArea(
        child: Consumer<WaterController>(
          builder: (context, waterController, child) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Meta de hoje: ${AppNumberFormat.ml(WaterController.dailyGoalMl)}',
                    textAlign: TextAlign.center,
                    style: textTheme.titleMedium,
                  ),
                  const SizedBox(height: 24),
                  Center(child: WaterGlassWidget(progress: waterController.progress)),
                  const SizedBox(height: 24),
                  Text(
                    '${AppNumberFormat.ml(waterController.totalMl)} de '
                    '${AppNumberFormat.ml(WaterController.dailyGoalMl)}',
                    textAlign: TextAlign.center,
                    style: textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${(waterController.progress * 100).round()}% da meta',
                    textAlign: TextAlign.center,
                    style: textTheme.bodyLarge,
                  ),
                  if (waterController.isGoalReached) ...[
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_circle, color: AppColors.success),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            'Meta de hoje alcançada! Parabéns.',
                            style: textTheme.bodyMedium?.copyWith(
                              color: AppColors.successText,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 24),
                  if (waterController.errorMessage != null) ...[
                    ErrorMessageWidget(message: waterController.errorMessage!),
                    const SizedBox(height: 16),
                  ],
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _add(200),
                          child: const Text('+200 ml'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _add(300),
                          child: const Text('+300 ml'),
                        ),
                      ),
                    ],
                  ),
                  if (waterController.logs.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: waterController.undoLast,
                      child: Text(
                        'Desfazer o último registro '
                        '(${AppNumberFormat.ml(waterController.logs.last.amountMl)})',
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text('Registros de hoje', style: textTheme.titleLarge),
                    const SizedBox(height: 12),
                    for (final log in waterController.logs.reversed)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.water_drop_outlined,
                              color: AppColors.lavender,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              AppDateFormat.time(log.loggedAt),
                              style: textTheme.titleSmall,
                            ),
                            const Spacer(),
                            Text(
                              AppNumberFormat.ml(log.amountMl),
                              style: textTheme.bodyLarge,
                            ),
                          ],
                        ),
                      ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
