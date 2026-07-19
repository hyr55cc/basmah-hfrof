import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../domain/entities/leaderboard.dart';
import '../../../../domain/repositories/leaderboard_repository.dart';
import '../../../game/presentation/providers/game_providers.dart';

final leaderboardProvider = FutureProvider.autoDispose
    .family<List<LeaderboardEntry>, LeaderboardType>((ref, type) async {
  final result = await sl<LeaderboardRepository>().getTopEntries(
    type: type,
    period: LeaderboardPeriod.allTime,
    limit: 100,
  );
  return result.fold((_) => <LeaderboardEntry>[], (l) => l);
});

class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key});
  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen> {
  LeaderboardType _selectedType = LeaderboardType.highestLevel;

  @override
  Widget build(BuildContext context) {
    final entriesAsync = ref.watch(leaderboardProvider(_selectedType));
    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة المتصدرين'),
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
            // Type selector
            Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: LeaderboardType.values.map((type) {
                    final isSelected = type == _selectedType;
                    return Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: ChoiceChip(
                        label: Text(type.arabicName),
                        selected: isSelected,
                        onSelected: (_) =>
                            setState(() => _selectedType = type),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            Expanded(
              child: entriesAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (e, _) => ErrorDisplay(
                  message: 'فشل تحميل لوحة المتصدرين',
                ),
                data: (entries) {
                  if (entries.isEmpty) {
                    return const EmptyState(
                      title: 'لا يوجد لاعبون بعد',
                      subtitle: 'كن أول من يصعد إلى القمة!',
                      icon: Icons.emoji_events_rounded,
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: entries.length,
                    itemBuilder: (context, i) {
                      return _LeaderboardTile(
                        entry: entries[i],
                        isTop3: i < 3,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LeaderboardTile extends StatelessWidget {
  const _LeaderboardTile({required this.entry, required this.isTop3});
  final LeaderboardEntry entry;
  final bool isTop3;

  Color get _rankColor {
    if (entry.rank == 1) return AppColors.gold;
    if (entry.rank == 2) return const Color(0xFFC0C0C0);
    if (entry.rank == 3) return const Color(0xFFCD7F32);
    return AppColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AppCard(
        padding: const EdgeInsets.all(12),
        gradient: entry.isCurrentUser ? AppColors.primaryGradient : null,
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isTop3
                    ? _rankColor
                    : entry.isCurrentUser
                        ? Colors.white
                        : AppColors.primary.withOpacity(0.15),
                border: isTop3
                    ? Border.all(color: _rankColor, width: 2)
                    : null,
              ),
              child: Center(
                child: isTop3
                    ? Icon(
                        Icons.emoji_events_rounded,
                        color: Colors.white,
                        size: 22,
                      )
                    : Text(
                        '${entry.rank}',
                        style: AppTextStyles.titleSmall.copyWith(
                          color: entry.isCurrentUser
                              ? AppColors.primary
                              : AppColors.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: entry.isCurrentUser
                    ? Colors.white.withOpacity(0.2)
                    : AppColors.primary.withOpacity(0.15),
              ),
              child: Center(
                child: Text(
                  entry.displayName.initials,
                  style: AppTextStyles.titleSmall.copyWith(
                    color: entry.isCurrentUser
                        ? Colors.white
                        : AppColors.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                entry.displayName,
                style: AppTextStyles.titleSmall.copyWith(
                  color: entry.isCurrentUser ? Colors.white : null,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: entry.isCurrentUser
                    ? Colors.white.withOpacity(0.25)
                    : AppColors.gold.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.star_rounded,
                    color: entry.isCurrentUser
                        ? Colors.white
                        : AppColors.gold,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${entry.score.compact}',
                    style: AppTextStyles.titleSmall.copyWith(
                      color: entry.isCurrentUser
                          ? Colors.white
                          : AppColors.goldDark,
                      fontWeight: FontWeight.w800,
                    ),
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
