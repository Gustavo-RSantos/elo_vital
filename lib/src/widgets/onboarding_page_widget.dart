import 'package:elo_vital/src/models/onboarding_page_model.dart';
import 'package:elo_vital/src/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Uma página do Onboarding: ilustração simples nas cores da marca, título e
/// texto curto.
class OnboardingPageWidget extends StatelessWidget {
  const OnboardingPageWidget({super.key, required this.page});

  final OnboardingPageModel page;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // A ilustração é decorativa, então fica fora da leitura de tela.
            ExcludeSemantics(
              child: SizedBox(
                width: 280,
                height: 280,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 230,
                      height: 230,
                      decoration: BoxDecoration(
                        color: page.backgroundColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Icon(page.icon, size: 110, color: page.color),
                    const Positioned(
                      top: 18,
                      right: 34,
                      child: _DotWidget(color: AppColors.lavender, size: 36),
                    ),
                    const Positioned(
                      bottom: 30,
                      left: 24,
                      child: _DotWidget(color: AppColors.orange, size: 28),
                    ),
                    const Positioned(
                      top: 70,
                      left: 8,
                      child: _DotWidget(color: AppColors.orchid, size: 20),
                    ),
                    const Positioned(
                      bottom: 12,
                      right: 50,
                      child: _DotWidget(color: AppColors.pink, size: 22),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
            Text(
              page.title,
              textAlign: TextAlign.center,
              style: textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            Text(
              page.description,
              textAlign: TextAlign.center,
              style: textTheme.bodyLarge?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DotWidget extends StatelessWidget {
  const _DotWidget({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
