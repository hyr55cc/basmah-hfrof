import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/coin_display.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../game/presentation/providers/game_providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserAsync = ref.watch(currentUserProvider);
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: AppColors.backgroundGradientLight,
              ),
            ),
          ),
          SafeArea(
            child: currentUserAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => ErrorDisplay(
                message: 'فشل تحميل البيانات',
                onRetry: () => ref.invalidate(currentUserProvider),
              ),
              data: (user) => CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: _buildHeader(context, user?.displayName ?? 'لاعب'),
                  ),
                  SliverToBoxAdapter(
                    child: _buildStatsRow(context, user),
                  ),
                  SliverToBoxAdapter(
                    child: _buildDailyRewardCard(context, ref),
                  ),
                  SliverToBoxAdapter(
                    child: _buildContinueLevelCard(context, user),
                  ),
                  SliverToBoxAdapter(
                    child: _buildQuickActions(context),
                  ),
                  SliverToBoxAdapter(
                    child: _buildSectionsGrid(context),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String name) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'مرحبًا 👋',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  name,
                  style: AppTextStyles.headlineMedium,
                ),
              ],
            ),
          ),
          // Profile button
          GestureDetector(
            onTap: () => context.goNamed('profile'),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.primaryGradient,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.person_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildStatsRow(BuildContext context, user) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: StatTile(
              label: 'العملات',
              value: '${user?.coins ?? 0}',
              icon: Icons.monetization_on_rounded,
              color: AppColors.gold,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: StatTile(
              label: 'المستوى',
              value: '${user?.currentLevel ?? 1}',
              icon: Icons.flag_rounded,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: StatTile(
              label: 'النقاط',
              value: '${user?.totalScore ?? 0}',
              icon: Icons.star_rounded,
              color: AppColors.secondary,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _buildDailyRewardCard(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: GlassContainer(
        padding: const EdgeInsets.all(16),
        borderRadius: 20,
        gradient: AppColors.sunsetGradient,
        onTap: () => context.goNamed('daily-reward'),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.25),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.card_giftcard_rounded,
                color: Colors.white,
                size: 30,
              ),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'مكافأتك اليومية',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'اجمع المكافآت كل يوم',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white,
              size: 18,
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 300.ms);
  }

  Widget _buildContinueLevelCard(BuildContext context, user) {
    final nextLevel = (user?.currentLevel ?? 1);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: AppCard(
        onTap: () => context.goNamed(
          'game',
          pathParameters: {'levelId': '$nextLevel'},
        ),
        padding: const EdgeInsets.all(20),
        gradient: AppColors.primaryGradient,
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.play_arrow_rounded,
                color: Colors.white,
                size: 36,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'مستوى $nextLevel',
                    style: AppTextStyles.headlineSmall.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'استمر في اللعب',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white.withOpacity(0.85),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 400.ms);
  }

  Widget _buildQuickActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          Expanded(
            child: _QuickAction(
              icon: Icons.shopping_bag_rounded,
              label: 'المتجر',
              color: AppColors.tertiary,
              onTap: () => context.goNamed('shop'),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _QuickAction(
              icon: Icons.leaderboard_rounded,
              label: 'المتصدرين',
              color: AppColors.secondary,
              onTap: () => context.goNamed('leaderboard'),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _QuickAction(
              icon: Icons.emoji_events_rounded,
              label: 'الإنجازات',
              color: AppColors.gold,
              onTap: () => context.goNamed('achievements'),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _QuickAction(
              icon: Icons.workspace_premium_rounded,
              label: 'المميزة',
              color: AppColors.primary,
              onTap: () => context.goNamed('premium'),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 500.ms);
  }

  Widget _buildSectionsGrid(BuildContext context) {
    final sections = [
      _SectionItem(
        icon: Icons.local_fire_department_rounded,
        title: 'المراحل الشائعة',
        subtitle: 'تحديات يومية',
        color: AppColors.error,
        onTap: () => context.goNamed('level-select'),
      ),
      _SectionItem(
        icon: Icons.style_rounded,
        title: 'بطاقات المستويات',
        subtitle: 'تصفح المراحل',
        color: AppColors.tertiary,
        onTap: () => context.goNamed('level-map'),
      ),
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Column(
        children: sections
            .map((s) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: AppCard(
                    onTap: s.onTap,
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: s.color.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(s.icon, color: s.color, size: 30),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                s.title,
                                style: AppTextStyles.titleMedium,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                s.subtitle,
                                style: AppTextStyles.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: AppColors.textSecondaryLight,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ))
            .toList(),
      ),
    ).animate().fadeIn(delay: 600.ms);
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppTextStyles.labelSmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _SectionItem {
  _SectionItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
}
