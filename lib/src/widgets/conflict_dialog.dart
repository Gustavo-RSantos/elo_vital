import 'package:flutter/material.dart';

/// Avisa que já existe algo marcado perto do horário escolhido e pergunta se a
/// pessoa quer continuar. Devolve true se ela escolher continuar.
Future<bool?> showConflictDialog(BuildContext context, List<String> conflicts) {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      final textTheme = Theme.of(context).textTheme;

      return AlertDialog(
        title: const Text('Atenção ao horário'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Você já tem um remédio ou consulta neste horário. '
                'Deseja continuar?',
                style: textTheme.bodyLarge,
              ),
              const SizedBox(height: 12),
              for (final conflict in conflicts)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text('• $conflict', style: textTheme.bodyMedium),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Voltar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Continuar'),
          ),
        ],
      );
    },
  );
}
