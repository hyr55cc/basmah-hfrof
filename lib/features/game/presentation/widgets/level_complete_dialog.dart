import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/primary_button.dart';

class LevelCompleteDialog extends StatelessWidget {
  const LevelCompleteDialog({
    required this.levelId,
    required this.coinsEarned,
    required this.onNext,
    required this.onReplay,
    required this.onHome,
    super.key,
  });

  final int levelId;
  final int coinsEarned;
  final VoidCallback onNext;
  final VoidCallback onReplay;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Trophy animation
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.goldGradient,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.gold.withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.emoji_events_rounded,
                color: Colors.white,
                size: 56,
              ),
            ).animate()
              .scale(duration: 600.ms, curve: Curves.elasticOut)
              .then()
              .shimmer(duration: 1000.ms, color: Colors.white),
            const SizedBox(height: 20),
            Text(
              'أحسنت!',
              style: AppTextStyles.headlineLarge.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w900,
              ),
            ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.3, end: 0),
            const SizedBox(height: 8),
            Text(
              'أكملت المستوى $levelId',
              style: AppTextStyles.titleMedium,
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 500.ms),
            const SizedBox(height: 20),
            // Stars
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (i) {
                return Icon(
                  Icons.star_rounded,
                  color: AppColors.gold,
                  size: 36,
                ).animate(delay: (700 + i * 200).ms)
                    .scale(curve: Curves.elasticOut);
              }),
            ),
            const SizedBox(height: 20),
            // Coins earned
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.gold.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.gold.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.monetization_on_rounded,
                    color: AppColors.goldDark,
                    size: 28,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '+$coinsEarned',
                    style: AppTextStyles.headlineSmall.copyWith(
                      color: AppColors.goldDark,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'عملة',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.goldDark,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 1200.ms).scale(begin: const Offset(0.5, 0.5)),
            const SizedBox(height: 24),
            // Buttons
            PrimaryButton(
              text: 'المستوى التالي',
              icon: Icons.arrow_forward_rounded,
              onPressed: onNext,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextAppButton(
                    text: 'إعادة اللعب',
                    icon: Icons.replay_rounded,
                    onPressed: onReplay,
                  ),
                ),
                Expanded(
                  child: TextAppButton(
                    text: 'الرئيسية',
                    icon: Icons.home_rounded,
                    onPressed: onHome,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
