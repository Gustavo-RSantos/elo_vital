import 'package:elo_vital/src/controller/auth_controller.dart';
import 'package:elo_vital/src/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Tela provisória do Bloco 2: confirma que o login funcionou e permite sair.
/// O Bloco 3 substitui este arquivo pela tela principal com a barra inferior.
class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    final authController = context.read<AuthController>();
    await authController.logout();
    if (!context.mounted) return;

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
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Olá, ${user?.firstName ?? ''}!',
                textAlign: TextAlign.center,
                style: textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Login funcionando. A tela principal será criada no Bloco 3.',
                textAlign: TextAlign.center,
                style: textTheme.bodyLarge,
              ),
              const SizedBox(height: 32),
              OutlinedButton(
                onPressed: () => _logout(context),
                child: const Text('Sair'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
