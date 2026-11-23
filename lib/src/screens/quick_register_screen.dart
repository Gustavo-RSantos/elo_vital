import 'package:elo_vital/src/enums/activity_type_enum.dart';
import 'package:elo_vital/src/enums/measurement_type_enum.dart';
import 'package:elo_vital/src/screens/register_measurement_screen.dart';
import 'package:elo_vital/src/screens/water_screen.dart';
import 'package:elo_vital/src/theme/app_colors.dart';
import 'package:elo_vital/src/widgets/register_option_widget.dart';
import 'package:flutter/material.dart';

/// Aba "Registrar": atalhos para registrar pressão, glicemia e água a qualquer
/// momento, mesmo fora da rotina.
class QuickRegisterScreen extends StatelessWidget {
  const QuickRegisterScreen({super.key});

  void _open(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    const measurement = ActivityTypeEnum.measurement;
    const water = ActivityTypeEnum.water;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('O que você quer registrar?', style: textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text(
                'Escolha uma opção.',
                style: textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              RegisterOptionWidget(
                icon: MeasurementTypeEnum.bloodPressure.icon,
                color: measurement.color,
                backgroundColor: measurement.backgroundColor,
                title: 'Pressão arterial',
                subtitle: 'Anote a máxima e a mínima',
                onTap: () => _open(
                  context,
                  const RegisterMeasurementScreen(),
                ),
              ),
              const SizedBox(height: 12),
              RegisterOptionWidget(
                icon: MeasurementTypeEnum.glucose.icon,
                color: measurement.color,
                backgroundColor: measurement.backgroundColor,
                title: 'Glicemia',
                subtitle: 'Anote o valor e quando mediu',
                onTap: () => _open(
                  context,
                  const RegisterMeasurementScreen(
                    initialType: MeasurementTypeEnum.glucose,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              RegisterOptionWidget(
                icon: water.icon,
                color: water.color,
                backgroundColor: water.backgroundColor,
                title: 'Água',
                subtitle: 'Registre o que você bebeu',
                onTap: () => _open(context, const WaterScreen()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
