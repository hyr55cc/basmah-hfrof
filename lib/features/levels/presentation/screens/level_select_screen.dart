import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../game/presentation/providers/game_providers.dart';

class LevelSelectScreen extends ConsumerStatefulWidget {
  const LevelSelectScreen({super.key});

  @override
  ConsumerState<LevelSelectScreen> createState() => _LevelSelectScreenState();
}

class _LevelSelectScreenState extends ConsumerState<LevelSelectScreen> {
  int _currentPage = 0;
  static const int _levelsPerPage = 30;

  @override
  Widget build(BuildContext context) {
    final currentUserAsync = ref.watch(currentUserProvider);
    final maxUnlocked = currentUserAsync.valueOrNull?.maxUnlockedLevel ?? 1;

    final totalLevelsShown = (_currentPage + 1) * _levelsPerPage;

    return Scaffold(
      appBar: AppBar(
        title: const Text('اختر المستوى'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_forward_ios_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradientLight,
        ),
        child: Column(
          children: [
            // Page info
            Padding(
              padding: const EdgeInsets.all(16),
              child: GlassContainer(
                padding: const EdgeInsets.all(12),
                borderRadius: 16,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _InfoChip(
                      icon: Icons.lock_open_rounded,
                      label: 'مفتوح',
                      value: '$maxUnlocked',
                      color: AppColors.success,
                    ),
                    _InfoChip(
                      icon: Icons.flag_rounded,
                      label: 'الحالي',
                      value: '${currentUserAsync.valueOrNull?.currentLevel ?? 1}',
                      color: AppColors.primary,
                    ),
                    _InfoChip(
                      icon: Icons.emoji_events_rounded,
                      label: 'الأعلى',
                      value: '$totalLevelsShown',
                      color: AppColors.gold,
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1,
                ),
                itemCount: _levelsPerPage,
                itemBuilder: (context, index) {
                  final levelId =
                      (_currentPage * _levelsPerPage) + index + 1;
                  final isUnlocked = levelId <= maxUnlocked;
                  final isCompleted =
                      levelId < (currentUserAsync.valueOrNull?.currentLevel ?? 1);
                  return _LevelTile(
                    levelId: levelId,
                    isUnlocked: isUnlocked,
                    isCompleted: isCompleted,
                    onTap: isUnlocked
                        ? () => context.goNamed(
                              'game',
                              pathParameters: {'levelId': '$levelId'},
                            )
                        : null,
                  );
                },
              ),
            ),
            // Pagination
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: _currentPage > 0
                        ? () => setState(() => _currentPage--)
                        : null,
                    icon: const Icon(Icons.arrow_back_ios_rounded),
                  ),
                  Text(
                    'الصفحة ${_currentPage + 1}',
                    style: AppTextStyles.titleMedium,
                  ),
                  IconButton(
                    onPressed: () => setState(() => _currentPage++),
                    icon: const Icon(Icons.arrow_forward_ios_rounded),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 4),
            Text(
              value,
              style: AppTextStyles.titleLarge.copyWith(
                color: color,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(label, style: AppTextStyles.bodySmall),
      ],
    );
  }
}

class _LevelTile extends StatelessWidget {
  const _LevelTile({
    required this.levelId,
    required this.isUnlocked,
    required this.isCompleted,
    required this.onTap,
  });
  final int levelId;
  final bool isUnlocked;
  final bool isCompleted;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            gradient: isCompleted
                ? AppColors.oceanGradient
                : isUnlocked
                    ? AppColors.primaryGradient
                    : null,
            color: !isUnlocked ? AppColors.cardLight : null,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isUnlocked
                  ? Colors.transparent
                  : AppColors.borderLight,
              width: 1.5,
            ),
            boxShadow: isUnlocked
                ? [
                    BoxShadow(
                      color: (isCompleted
                              ? AppColors.tertiary
                              : AppColors.primary)
                          .withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (isCompleted)
                const Positioned(
                  top: 4,
                  right: 4,
                  child: Icon(
                    Icons.check_circle_rounded,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              if (!isUnlocked)
                const Icon(
                  Icons.lock_rounded,
                  color: AppColors.textDisabledLight,
                  size: 20,
                ),
              if (isUnlocked)
                Text(
                  '$levelId',
                  style: AppTextStyles.titleLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
