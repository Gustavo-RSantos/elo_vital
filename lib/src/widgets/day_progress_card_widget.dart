import 'package:elo_vital/src/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Cartão "Seu dia": quantas tarefas foram feitas e a barra de progresso.
class DayProgressCardWidget extends StatelessWidget {
  const DayProgressCardWidget({
    super.key,
    required this.doneCount,
    required this.totalCount,
  });

  final int doneCount;
  final int totalCount;

  double get _progress => totalCount == 0 ? 0 : doneCount / totalCount;

  bool get _isAllDone => totalCount > 0 && doneCount == totalCount;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text('Seu dia', style: textTheme.titleMedium)),
                Text(
                  '${(_progress * 100).round()}%',
                  style: textTheme.titleMedium?.copyWith(color: AppColors.primary),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '$doneCount de $totalCount tarefas feitas',
              style: textTheme.bodyLarge,
            ),
            const SizedBox(height: 12),
            Semantics(
              label: 'Progresso do dia',
              value: '$doneCount de $totalCount tarefas feitas',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: _progress,
                  minHeight: 14,
                  color: AppColors.primary,
                  backgroundColor: AppColors.surfaceSoft,
                ),
              ),
            ),
            if (_isAllDone) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.check_circle, color: AppColors.success),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Parabéns! Você concluiu tudo por hoje.',
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.successText,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
