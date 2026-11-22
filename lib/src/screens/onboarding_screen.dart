import 'package:elo_vital/src/controller/auth_controller.dart';
import 'package:elo_vital/src/models/onboarding_page_model.dart';
import 'package:elo_vital/src/screens/login_screen.dart';
import 'package:elo_vital/src/theme/app_colors.dart';
import 'package:elo_vital/src/widgets/onboarding_page_widget.dart';
import 'package:elo_vital/src/widgets/page_indicator_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Apresentação do app em 3 páginas, com "Continuar" e "Pular".
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController pageController = PageController();
  int currentPage = 0;

  static const List<OnboardingPageModel> _pages = [
    OnboardingPageModel(
      title: 'Sua rotina de cuidado',
      description:
          'Remédios, medições e água organizados em um só lugar, no seu ritmo.',
      icon: Icons.medication_outlined,
      color: AppColors.medicine,
      backgroundColor: AppColors.medicineSoft,
    ),
    OnboardingPageModel(
      title: 'Família sempre por perto',
      description:
          'Seu cuidador acompanha a sua rotina, e você decide quem pode ver.',
      icon: Icons.favorite_border,
      color: AppColors.measurement,
      backgroundColor: AppColors.measurementSoft,
    ),
    OnboardingPageModel(
      title: 'Consultas e remédios em dia',
      description: 'Lembretes claros para você não esquecer nenhum horário.',
      icon: Icons.event_available_outlined,
      color: AppColors.appointment,
      backgroundColor: AppColors.appointmentSoft,
    ),
  ];

  bool get _isLastPage => currentPage == _pages.length - 1;

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  Future<void> _goToLogin() async {
    // Guarda que o Onboarding já foi visto, para não mostrá-lo de novo.
    await context.read<AuthController>().markOnboardingSeen();
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  void _next() {
    if (_isLastPage) {
      _goToLogin();
      return;
    }
    pageController.nextPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 8, right: 16),
                // Mantém o espaço do "Pular" na última página para o layout
                // não pular de lugar.
                child: Visibility(
                  visible: !_isLastPage,
                  maintainSize: true,
                  maintainAnimation: true,
                  maintainState: true,
                  child: TextButton(
                    onPressed: _goToLogin,
                    child: const Text('Pular'),
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: pageController,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() => currentPage = index);
                },
                itemBuilder: (context, index) {
                  return OnboardingPageWidget(page: _pages[index]);
                },
              ),
            ),
            PageIndicatorWidget(
              count: _pages.length,
              currentIndex: currentPage,
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: ElevatedButton(
                onPressed: _next,
                child: Text(_isLastPage ? 'Começar' : 'Continuar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
