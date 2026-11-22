import 'package:elo_vital/src/controller/auth_controller.dart';
import 'package:elo_vital/src/enums/start_destination_enum.dart';
import 'package:elo_vital/src/screens/login_screen.dart';
import 'package:elo_vital/src/screens/main_screen.dart';
import 'package:elo_vital/src/screens/onboarding_screen.dart';
import 'package:elo_vital/src/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Tela de abertura: logo completa (que já traz o slogan) e a faixa em
/// gradiente da marca na base. Depois de 3 segundos, segue para o Onboarding,
/// o Login ou a tela principal, conforme a sessão e o que a pessoa já viu.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const Duration _splashDuration = Duration(seconds: 3);

  @override
  void initState() {
    super.initState();
    _goToNextScreen();
  }

  Future<void> _goToNextScreen() async {
    final authController = context.read<AuthController>();

    // Carrega o destino enquanto a Splash é exibida.
    final destinationFuture = authController.loadStartDestination();
    await Future.delayed(_splashDuration);
    final destination = await destinationFuture;
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => _screenFor(destination)),
    );
  }

  Widget _screenFor(StartDestinationEnum destination) {
    return switch (destination) {
      StartDestinationEnum.onboarding => const OnboardingScreen(),
      StartDestinationEnum.login => const LoginScreen(),
      StartDestinationEnum.main => const MainScreen(),
    };
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: 1),
                duration: const Duration(milliseconds: 900),
                curve: Curves.easeOut,
                builder: (context, value, child) {
                  return Opacity(opacity: value, child: child);
                },
                child: Image.asset(
                  'assets/images/elo_vital_logo.png',
                  width: width * 0.85,
                  semanticLabel:
                      'Elo Vital, conectando vidas, fortalecendo cuidados',
                ),
              ),
            ),
          ),
          const DecoratedBox(
            decoration: BoxDecoration(gradient: AppColors.brandGradient),
            child: SizedBox(height: 10, width: double.infinity),
          ),
        ],
      ),
    );
  }
}
