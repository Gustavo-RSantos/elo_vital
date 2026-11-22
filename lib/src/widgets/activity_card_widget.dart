import 'package:elo_vital/src/enums/activity_type_enum.dart';
import 'package:elo_vital/src/models/routine_item_model.dart';
import 'package:elo_vital/src/theme/app_colors.dart';
import 'package:elo_vital/src/utils/app_date_format.dart';
import 'package:flutter/material.dart';

/// Cartão de uma tarefa da rotina: faixa lateral e ícone na cor do tipo,
/// horário, título e o botão grande de ação ("Tomei", "Medir", "Registrar"...).
class ActivityCardWidget extends StatelessWidget {
  const ActivityCardWidget({
    super.key,
    required this.item,
    required this.onComplete,
    required this.onUndo,
  });

  final RoutineItemModel item;
  final VoidCallback onComplete;
  final VoidCallback onUndo;

  /// Consultas não têm botão aqui: o "Fui à consulta" vem no bloco de Consultas.
  String? get _actionLabel {
    return switch (item.type) {
      ActivityTypeEnum.medicine => 'Tomei',
      ActivityTypeEnum.measurement => 'Medir',
      ActivityTypeEnum.water => 'Registrar',
      ActivityTypeEnum.exercise => 'Fiz',
      ActivityTypeEnum.appointment => null,
    };
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final actionLabel = _actionLabel;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 8, color: item.type.color),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          AppDateFormat.time(item.scheduledAt),
                          style: textTheme.titleMedium,
                        ),
                        const SizedBox(width: 12),
                        _TypeChipWidget(type: item.type),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(item.title, style: textTheme.titleSmall),
                    const SizedBox(height: 2),
                    Text(item.subtitle, style: textTheme.bodySmall),
                    if (actionLabel != null) ...[
                      const SizedBox(height: 12),
                      if (item.isDone)
                        Row(
                          children: [
                            const Icon(
                              Icons.check_circle,
                              color: AppColors.success,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Feito',
                              style: textTheme.titleSmall?.copyWith(
                                color: AppColors.successText,
                              ),
                            ),
                            const Spacer(),
                            TextButton(
                              onPressed: onUndo,
                              child: const Text('Desfazer'),
                            ),
                          ],
                        )
                      else
                        ElevatedButton(
                          onPressed: onComplete,
                          child: Text(actionLabel),
                        ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypeChipWidget extends StatelessWidget {
  const _TypeChipWidget({required this.type});

  final ActivityTypeEnum type;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: type.backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(type.icon, size: 18, color: type.color),
          const SizedBox(width: 6),
          Text(
            type.label,
            style: textTheme.labelMedium?.copyWith(color: type.textColor),
          ),
        ],
      ),
    );
  }
}
