import 'package:elo_vital/src/controller/appointment_controller.dart';
import 'package:elo_vital/src/controller/auth_controller.dart';
import 'package:elo_vital/src/controller/measurement_controller.dart';
import 'package:elo_vital/src/controller/routine_controller.dart';
import 'package:elo_vital/src/controller/water_controller.dart';
import 'package:elo_vital/src/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Configurações (provisória): mostra a conta e permite sair. As opções de
/// fonte, alto contraste e contatos de emergência virão em um bloco futuro.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Sair da conta?'),
          content: const Text(
            'Você precisará entrar de novo para ver a sua rotina.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Sair'),
            ),
          ],
        );
      },
    );
    if (confirmed != true || !mounted) return;

    final authController = context.read<AuthController>();
    final routineController = context.read<RoutineController>();
    final measurementController = context.read<MeasurementController>();
    final waterController = context.read<WaterController>();
    final appointmentController = context.read<AppointmentController>();
    await authController.logout();
    routineController.clear();
    measurementController.clear();
    waterController.clear();
    appointmentController.clear();
    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final user = context.watch<AuthController>().currentUser;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Configurações', style: textTheme.headlineMedium),
              const SizedBox(height: 24),
              Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: const Icon(Icons.person_outline, size: 36),
                  title: Text(user?.name ?? '', style: textTheme.titleSmall),
                  subtitle: Text(user?.email ?? '', style: textTheme.bodySmall),
                ),
              ),
              const SizedBox(height: 24),
              OutlinedButton(
                onPressed: _logout,
                child: const Text('Sair da conta'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
