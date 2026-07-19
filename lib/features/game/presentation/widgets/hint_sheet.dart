import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../domain/repositories/user_repository.dart';
import '../../domain/entities/game_state.dart';

/// Bottom sheet for hint selection
class HintSheet extends ConsumerStatefulWidget {
  const HintSheet({
    required this.levelId,
    required this.onHintUsed,
    super.key,
  });

  final int levelId;
  final void Function(HintType) onHintUsed;

  @override
  ConsumerState<HintSheet> createState() => _HintSheetState();
}

class _HintSheetState extends ConsumerState<HintSheet> {
  int _userCoins = 0;
  int _userHints = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userId = sl<dynamic>().auth.currentUser?.uid;
    if (userId == null) return;
    final result = await sl<UserRepository>().getUser(userId);
    result.fold((_) => null, (user) {
      if (mounted) {
        setState(() {
          _userCoins = user.coins;
          _userHints = user.hints;
          _isLoading = false;
        });
      }
    });
  }

  void _useHint(HintType hintType) {
    if (_userCoins < hintType.coinCost && _userHints <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('لا تملك ما يكفي من العملات أو التلميحات'),
        ),
      );
      return;
    }
    widget.onHintUsed(hintType);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textDisabledLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'التلميحات',
                style: AppTextStyles.headlineSmall,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: AppColors.goldGradient,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.monetization_on_rounded,
                      color: AppColors.goldDark,
                      size: 18,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$_userCoins',
                      style: AppTextStyles.titleSmall.copyWith(
                        color: AppColors.goldDark,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _HintItem(
            icon: Icons.lightbulb_outline_rounded,
            iconColor: AppColors.gold,
            title: HintType.revealLetter.arabicName,
            description: 'اكشف حرفًا من إحدى الكلمات',
            cost: HintType.revealLetter.coinCost,
            userCoins: _userCoins,
            onTap: () => _useHint(HintType.revealLetter),
          ),
          _HintItem(
            icon: Icons.auto_awesome_rounded,
            iconColor: AppColors.tertiary,
            title: HintType.revealWord.arabicName,
            description: 'اكشف كلمة كاملة',
            cost: HintType.revealWord.coinCost,
            userCoins: _userCoins,
            onTap: () => _useHint(HintType.revealWord),
          ),
          _HintItem(
            icon: Icons.shuffle_rounded,
            iconColor: AppColors.primary,
            title: HintType.shuffle.arabicName,
            description: 'أعد ترتيب الحروف',
            cost: HintType.shuffle.coinCost,
            userCoins: _userCoins,
            onTap: () => _useHint(HintType.shuffle),
          ),
          _HintItem(
            icon: Icons.block_rounded,
            iconColor: AppColors.error,
            title: HintType.removeWrongLetter.arabicName,
            description: 'احذف حرفًا لا يدخل في أي إجابة',
            cost: HintType.removeWrongLetter.coinCost,
            userCoins: _userCoins,
            onTap: () => _useHint(HintType.removeWrongLetter),
          ),
          _HintItem(
            icon: Icons.skip_next_rounded,
            iconColor: AppColors.secondary,
            title: HintType.skipLevel.arabicName,
            description: 'تخطى هذا المستوى',
            cost: HintType.skipLevel.coinCost,
            userCoins: _userCoins,
            onTap: () => _useHint(HintType.skipLevel),
          ),
        ],
      ),
    );
  }
}

class _HintItem extends StatelessWidget {
  const _HintItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
    required this.cost,
    required this.userCoins,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;
  final int cost;
  final int userCoins;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final canAfford = userCoins >= cost;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: canAfford ? onTap : null,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.titleSmall.copyWith(
                          color: canAfford
                              ? AppColors.textPrimaryLight
                              : AppColors.textDisabledLight,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        description,
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: canAfford
                        ? AppColors.gold.withOpacity(0.15)
                        : AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.monetization_on_rounded,
                        color: canAfford
                            ? AppColors.goldDark
                            : AppColors.error,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$cost',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: canAfford
                              ? AppColors.goldDark
                              : AppColors.error,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
