import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../data/datasources/remote/firebase_datasource.dart';
import '../../../../domain/entities/achievement.dart';
import '../../../../domain/repositories/achievement_repository.dart';

final userAchievementsProvider =
    FutureProvider.autoDispose<List<AchievementProgress>>((ref) async {
  final userId = sl<FirebaseDatasource>().auth.currentUser?.uid;
  if (userId == null) return [];
  final result = await sl<AchievementRepository>().getUserProgress(userId);
  return result.fold((_) => [], (list) => list);
});

class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final achievementsAsync = ref.watch(userAchievementsProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('الإنجازات'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_forward_ios_rounded),
          onPressed: () => GoRouter.of(context).pop(),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradientLight,
        ),
        child: achievementsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) =>
              ErrorDisplay(message: 'فشل تحميل الإنجازات'),
          data: (achievements) {
            final completed = achievements.where((a) => a.completed).length;
            final total = achievements.length;
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Header
                AppCard(
                  padding: const EdgeInsets.all(16),
                  gradient: AppColors.primaryGradient,
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.emoji_events_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'إنجازاتك',
                              style: AppTextStyles.titleLarge
                                  .copyWith(color: Colors.white),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$completed من $total إنجاز',
                              style: AppTextStyles.bodyMedium
                                  .copyWith(color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                ...achievements.map((progress) => _AchievementTile(
                      progress: progress,
                      onClaim: () async {
                        final userId =
                            sl<FirebaseDatasource>().auth.currentUser?.uid;
                        if (userId == null) return;
                        final result = await sl<AchievementRepository>()
                            .claimReward(
                          userId: userId,
                          achievementId: progress.achievement.id,
                        );
                        if (context.mounted) {
                          result.fold(
                            (failure) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(failure.message)),
                              );
                            },
                            (coins) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'تم استلام $coins عملة! 🎉',
                                  ),
                                ),
                              );
                              ref.invalidate(userAchievementsProvider);
                            },
                          );
                        }
                      },
                    )),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _AchievementTile extends StatelessWidget {
  const _AchievementTile({required this.progress, required this.onClaim});
  final AchievementProgress progress;
  final VoidCallback onClaim;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AppCard(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: progress.completed
                    ? AppColors.success.withOpacity(0.15)
                    : AppColors.borderLight,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                progress.completed
                    ? Icons.emoji_events_rounded
                    : Icons.lock_outline_rounded,
                color: progress.completed
                    ? AppColors.success
                    : AppColors.textDisabledLight,
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    progress.achievement.title,
                    style: AppTextStyles.titleSmall.copyWith(
                      color: progress.completed
                          ? AppColors.textPrimaryLight
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    progress.achievement.description,
                    style: AppTextStyles.bodySmall,
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progress.progressPercent,
                      minHeight: 6,
                      backgroundColor: AppColors.borderLight,
                      valueColor: AlwaysStoppedAnimation(
                        progress.completed
                            ? AppColors.success
                            : AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${progress.current}/${progress.achievement.target}',
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (progress.completed && !progress.claimed)
              Container(
                decoration: BoxDecoration(
                  color: AppColors.gold,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onClaim,
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.monetization_on_rounded,
                            color: AppColors.goldDark,
                            size: 18,
                          ),
                          Text(
                            '+${progress.achievement.rewardCoins}',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.goldDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            else if (progress.claimed)
              const Icon(
                Icons.check_circle_rounded,
                color: AppColors.success,
                size: 28,
              ),
          ],
        ),
      ),
    );
  }
}
