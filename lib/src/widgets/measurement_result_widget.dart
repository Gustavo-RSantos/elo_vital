import 'package:elo_vital/src/models/measurement_model.dart';
import 'package:elo_vital/src/utils/health_classifier.dart';
import 'package:flutter/material.dart';

/// Resultado de uma medição salva: "Normal" ou "Atenção", sempre com ícone e
/// texto, o valor, uma explicação curta e o aviso de que é só uma referência.
class MeasurementResultWidget extends StatelessWidget {
  const MeasurementResultWidget({
    super.key,
    required this.measurement,
    required this.onDone,
    required this.onRegisterAnother,
  });

  final MeasurementModel measurement;
  final VoidCallback onDone;
  final VoidCallback onRegisterAnother;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final status = measurement.status;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          liveRegion: true,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: status.backgroundColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Icon(status.icon, size: 72, color: status.color),
                const SizedBox(height: 12),
                Text(
                  status.label,
                  style: textTheme.headlineMedium?.copyWith(
                    color: status.textColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${measurement.type.label}: ${measurement.valueLabel}',
                  textAlign: TextAlign.center,
                  style: textTheme.titleMedium?.copyWith(
                    color: status.textColor,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  HealthClassifier.messageFor(status),
                  textAlign: TextAlign.center,
                  style: textTheme.bodyLarge?.copyWith(color: status.textColor),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          HealthClassifier.disclaimer,
          textAlign: TextAlign.center,
          style: textTheme.bodySmall,
        ),
        const SizedBox(height: 24),
        ElevatedButton(onPressed: onDone, child: const Text('Concluir')),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: onRegisterAnother,
          child: const Text('Registrar outra medição'),
        ),
      ],
    );
  }
}
