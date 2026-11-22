import 'package:elo_vital/src/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Pontinhos que mostram em qual página a pessoa está (a ativa fica mais larga).
class PageIndicatorWidget extends StatelessWidget {
  const PageIndicatorWidget({
    super.key,
    required this.count,
    required this.currentIndex,
  });

  final int count;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Página ${currentIndex + 1} de $count',
      child: ExcludeSemantics(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(count, (index) {
            final isActive = index == currentIndex;

            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: isActive ? 32 : 12,
              height: 12,
              decoration: BoxDecoration(
                color: isActive ? AppColors.primary : AppColors.lavender,
                borderRadius: BorderRadius.circular(6),
              ),
            );
          }),
        ),
      ),
    );
  }
}
