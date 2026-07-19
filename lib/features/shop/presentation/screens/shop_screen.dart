import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../data/datasources/remote/firebase_datasource.dart';
import '../../../../domain/entities/shop.dart';
import '../../../../domain/repositories/shop_repository.dart';
import '../../../../services/iap/purchase_service.dart';
import '../../../game/presentation/providers/game_providers.dart';

final shopItemsProvider =
    FutureProvider.autoDispose<List<ShopItem>>((ref) async {
  final result = await sl<ShopRepository>().getShopItems();
  return result.fold((_) => <ShopItem>[], (l) => l);
});

class ShopScreen extends ConsumerStatefulWidget {
  const ShopScreen({super.key});

  @override
  ConsumerState<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends ConsumerState<ShopScreen> {
  ShopItemCategory _selectedCategory = ShopItemCategory.coins;

  @override
  Widget build(BuildContext context) {
    final itemsAsync = ref.watch(shopItemsProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('المتجر'),
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
            // Category tabs
            Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ShopItemCategory.values.map((cat) {
                    final isSelected = cat == _selectedCategory;
                    return Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: ChoiceChip(
                        label: Text(cat.arabicName),
                        selected: isSelected,
                        onSelected: (_) =>
                            setState(() => _selectedCategory = cat),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            Expanded(
              child: itemsAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (e, _) => ErrorDisplay(
                  message: 'فشل تحميل المتجر',
                ),
                data: (items) {
                  final filtered =
                      items.where((i) => i.category == _selectedCategory).toList();
                  if (filtered.isEmpty) {
                    return const EmptyState(
                      title: 'لا توجد منتجات',
                      icon: Icons.shopping_bag_rounded,
                    );
                  }
                  return GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.7,
                    ),
                    itemCount: filtered.length,
                    itemBuilder: (context, i) =>
                        _ShopItemCard(item: filtered[i]),
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

class _ShopItemCard extends ConsumerWidget {
  const _ShopItemCard({required this.item});
  final ShopItem item;

  Future<void> _purchase(BuildContext context, WidgetRef ref) async {
    final userId = sl<FirebaseDatasource>().auth.currentUser?.uid;
    if (userId == null) return;
    final result = await sl<ShopRepository>().processPurchase(
      userId: userId,
      productId: item.productId ?? item.id,
      transactionId: 'txn_${DateTime.now().millisecondsSinceEpoch}',
    );
    if (!context.mounted) return;
    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failure.message)),
        );
      },
      (_) {
        ref.invalidate(currentUserProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تمت عملية الشراء بنجاح!')),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = Color(item.color ?? 0xFF6C63FF);
    return AppCard(
      padding: const EdgeInsets.all(12),
      onTap: item.isSubscription
          ? null
          : () => _purchase(context, ref),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (item.popular || item.discountPercent > 0)
            Align(
              alignment: Alignment.topLeft,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.error,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  item.discountPercent > 0
                      ? 'خصم ${item.discountPercent}٪'
                      : 'الأكثر شعبية',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          const SizedBox(height: 8),
          Container(
            height: 60,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _iconForCategory(item.category),
              color: color,
              size: 36,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            item.title,
            style: AppTextStyles.titleSmall,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Expanded(
            child: Text(
              item.description,
              style: AppTextStyles.bodySmall,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              item.isSubscription
                  ? '${item.price.toStringAsFixed(2)} ${item.currency}/${item.subscriptionDurationDays} يوم'
                  : '${item.price.toStringAsFixed(2)} ${item.currency}',
              style: AppTextStyles.labelMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconForCategory(ShopItemCategory category) {
    switch (category) {
      case ShopItemCategory.coins:
        return Icons.monetization_on_rounded;
      case ShopItemCategory.hints:
        return Icons.lightbulb_rounded;
      case ShopItemCategory.removeAds:
        return Icons.block_rounded;
      case ShopItemCategory.premium:
        return Icons.workspace_premium_rounded;
      case ShopItemCategory.starterPack:
        return Icons.card_giftcard_rounded;
      case ShopItemCategory.special:
        return Icons.star_rounded;
    }
  }
}
