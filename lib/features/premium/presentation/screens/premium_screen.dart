import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/primary_button.dart';

class PremiumScreen extends ConsumerWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('العضوية المميزة'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_forward_ios_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.gold,
              AppColors.secondary,
              AppColors.primary,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.3),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.workspace_premium_rounded,
                    color: AppColors.gold,
                    size: 80,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'لغز الكلمات المميز',
                  style: AppTextStyles.displaySmall.copyWith(
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'استمتع بأفضل تجربة',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 32),
                // Benefits
                ..._buildBenefits(),
                const SizedBox(height: 32),
                // Plans
                _PlanCard(
                  title: 'سنوي',
                  price: '39.99',
                  period: 'سنويًا',
                  savings: 'وفّر 33٪',
                  popular: true,
                ),
                const SizedBox(height: 12),
                _PlanCard(
                  title: 'شهري',
                  price: '4.99',
                  period: 'شهريًا',
                ),
                const SizedBox(height: 24),
                PrimaryButton(
                  text: 'اشترك الآن',
                  icon: Icons.workspace_premium_rounded,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('جاري فتح عملية الدفع...')),
                    );
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  'يتم تجديد الاشتراك تلقائيًا. يمكنك إلغاء الاشتراك في أي وقت من إعدادات متجر التطبيقات.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.white.withOpacity(0.8),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildBenefits() {
    const benefits = [
      ['بدون إعلانات', Icons.block_rounded],
      ['تلميحات غير محدودة', Icons.lightbulb_rounded],
      ['عملات يومية مضاعفة', Icons.monetization_on_rounded],
      ['مستويات حصرية', Icons.flag_rounded],
      ['سمات مميزة', Icons.palette_rounded],
      ['دعم أولوية', Icons.support_agent_rounded],
    ];
    return benefits
        .map((b) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(b[1] as IconData,
                        color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    b[0] as String,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ))
        .toList();
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.title,
    required this.price,
    required this.period,
    this.savings,
    this.popular = false,
  });
  final String title;
  final String price;
  final String period;
  final String? savings;
  final bool popular;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: popular
            ? Border.all(color: AppColors.gold, width: 3)
            : null,
        boxShadow: popular
            ? [
                BoxShadow(
                  color: AppColors.gold.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.headlineSmall,
                    ),
                    if (popular) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.gold,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'الأفضل',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (savings != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    savings!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '\$',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.gold,
                    ),
                  ),
                  Text(
                    price,
                    style: AppTextStyles.displaySmall.copyWith(
                      color: AppColors.gold,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              Text(
                period,
                style: AppTextStyles.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
