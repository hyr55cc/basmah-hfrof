import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../domain/entities/shop.dart';
import '../../../../domain/repositories/shop_repository.dart';
import '../../../../services/ads/ad_service.dart';
import '../../../game/presentation/providers/game_providers.dart';

class DailyRewardScreen extends ConsumerStatefulWidget {
  const DailyRewardScreen({super.key});

  @override
  ConsumerState<DailyRewardScreen> createState() => _DailyRewardScreenState();
}

class _DailyRewardScreenState extends ConsumerState<DailyRewardScreen> {
  DailyRewardStatus? _status;
  List<DailyReward> _rewards = [];
  bool _isLoading = true;
  bool _isClaiming = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final shopRepo = sl<ShopRepository>();
    final userId = sl<dynamic>().auth.currentUser?.uid;
    if (userId == null) return;
    final rewardsResult = await shopRepo.getDailyRewards();
    final statusResult = await shopRepo.getDailyRewardStatus(userId);
    if (!mounted) return;
    setState(() {
      _rewards = rewardsResult.fold((_) => [], (r) => r);
      _status = statusResult.fold((_) => null, (s) => s);
      _isLoading = false;
    });
  }

  Future<void> _claim() async {
    if (_status == null || !_status!.canClaimToday) return;
    setState(() => _isClaiming = true);
    final userId = sl<dynamic>().auth.currentUser?.uid;
    if (userId == null) return;
    final result =
        await sl<ShopRepository>().claimDailyReward(userId);
    if (!mounted) return;
    setState(() => _isClaiming = false);
    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failure.message)),
        );
      },
      (reward) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('🎉 تم استلام المكافأة!'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.card_giftcard_rounded,
                  color: AppColors.gold,
                  size: 80,
                ),
                const SizedBox(height: 16),
                if (reward.coins > 0)
                  Text('+${reward.coins} عملة',
                      style: AppTextStyles.headlineSmall),
                if (reward.gems > 0) Text('+${reward.gems} جوهرة'),
                if (reward.hints > 0) Text('+${reward.hints} تلميح'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _load();
                  ref.invalidate(currentUserProvider);
                },
                child: const Text('رائع'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _watchAd() async {
    final adService = sl<AdService>();
    final success = await adService.showRewarded(
      onRewarded: (amount, type) async {
        final userId = sl<dynamic>().auth.currentUser?.uid;
        if (userId == null) return;
        await sl<dynamic>().addCoins(userId, 50);
        if (mounted) {
          ref.invalidate(currentUserProvider);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('حصلت على 50 عملة!')),
          );
        }
      },
    );
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لا يوجد إعلان متاح حاليًا')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المكافأة اليومية'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_forward_ios_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.gold, AppColors.secondary],
          ),
        ),
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.white),
              )
            : SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      Text(
                        'سلسلة المكافآت',
                        style: AppTextStyles.displaySmall.copyWith(
                          color: Colors.white,
                        ),
                      ).animate().fadeIn().slideY(begin: -0.3, end: 0),
                      const SizedBox(height: 8),
                      Text(
                        'سجل دخول كل يوم لتحصل على مكافآت أكبر',
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                        textAlign: TextAlign.center,
                      ).animate().fadeIn(delay: 200.ms),
                      const SizedBox(height: 24),
                      // Days grid
                      Expanded(
                        child: GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 0.9,
                          ),
                          itemCount: _rewards.length,
                          itemBuilder: (context, index) {
                            final reward = _rewards[index];
                            final isToday = _status != null &&
                                _status!.canClaimToday &&
                                reward.day ==
                                    (_status!.currentStreak % 7) + 1;
                            final isClaimed = _status != null &&
                                !_status!.canClaimToday &&
                                reward.day ==
                                    (_status!.currentStreak % 7) + 1;
                            return _DayTile(
                              reward: reward,
                              isToday: isToday,
                              isClaimed: isClaimed,
                            );
                          },
                        ),
                      ),
                      // Action buttons
                      PrimaryButton(
                        text: _status?.canClaimToday == true
                            ? 'استلام المكافأة'
                            : 'تم الاستلام - عد غدًا',
                        icon: Icons.card_giftcard_rounded,
                        onPressed: _status?.canClaimToday == true && !_isClaiming
                            ? _claim
                            : null,
                        isLoading: _isClaiming,
                      ),
                      const SizedBox(height: 8),
                      SecondaryButton(
                        text: 'شاهد إعلانًا للحصول على 50 عملة',
                        icon: Icons.play_circle_outline_rounded,
                        onPressed: _watchAd,
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

class _DayTile extends StatelessWidget {
  const _DayTile({
    required this.reward,
    required this.isToday,
    required this.isClaimed,
  });
  final DailyReward reward;
  final bool isToday;
  final bool isClaimed;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isToday
            ? Colors.white
            : isClaimed
                ? Colors.white.withOpacity(0.6)
                : Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: isToday
            ? Border.all(color: Colors.white, width: 3)
            : null,
        boxShadow: isToday
            ? [
                BoxShadow(
                  color: Colors.white.withOpacity(0.5),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'يوم ${reward.day}',
            style: AppTextStyles.labelMedium.copyWith(
              color: isToday
                  ? AppColors.secondary
                  : isClaimed
                      ? AppColors.textSecondaryLight
                      : Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Icon(
            Icons.monetization_on_rounded,
            color: isToday
                ? AppColors.gold
                : isClaimed
                    ? AppColors.textDisabledLight
                    : Colors.white,
            size: 32,
          ),
          const SizedBox(height: 4),
          Text(
            '+${reward.coins}',
            style: AppTextStyles.titleSmall.copyWith(
              color: isToday
                  ? AppColors.goldDark
                  : isClaimed
                      ? AppColors.textDisabledLight
                      : Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (reward.gems > 0)
            Text(
              '+${reward.gems} 💎',
              style: AppTextStyles.bodySmall.copyWith(
                color: isToday
                    ? AppColors.tertiary
                    : isClaimed
                        ? AppColors.textDisabledLight
                        : Colors.white,
              ),
            ),
          if (isClaimed)
            const Icon(
              Icons.check_circle_rounded,
              color: AppColors.success,
              size: 16,
            ),
        ],
      ),
    );
  }
}
