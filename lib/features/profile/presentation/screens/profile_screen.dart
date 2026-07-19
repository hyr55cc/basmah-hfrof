import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/coin_display.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../domain/repositories/auth_repository.dart';
import '../../../game/presentation/providers/game_providers.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});
  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _nameController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveName() async {
    if (_nameController.text.isEmpty) return;
    setState(() => _isLoading = true);
    final useCase = UpdateProfile(sl<AuthRepository>());
    final result = await useCase(
      UpdateProfileParams(displayName: _nameController.text.trim()),
    );
    if (!mounted) return;
    setState(() => _isLoading = false);
    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failure.message)),
        );
      },
      (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم تحديث الاسم')),
        );
        ref.invalidate(currentUserProvider);
      },
    );
  }

  Future<void> _signOut() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تسجيل الخروج'),
        content: const Text('هل تريد تسجيل الخروج؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('تسجيل الخروج'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await sl<AuthRepository>().signOut();
      if (!mounted) return;
      context.goNamed('auth');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider).valueOrNull;
    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('الملف الشخصي'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_forward_ios_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradientLight,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Profile header
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppColors.primaryGradient,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          user.displayName?.initials ?? '👤',
                          style: AppTextStyles.displaySmall.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user.displayName ?? 'لاعب',
                      style: AppTextStyles.headlineMedium,
                    ),
                    if (user.isPremium) ...[
                      const SizedBox(height: 4),
                      AppBadge(
                        text: 'عضو مميز',
                        color: AppColors.gold,
                        icon: Icons.workspace_premium_rounded,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Stats grid
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.6,
                children: [
                  StatTile(
                    label: 'العملات',
                    value: '${user.coins}',
                    icon: Icons.monetization_on_rounded,
                    color: AppColors.gold,
                  ),
                  StatTile(
                    label: 'الجواهر',
                    value: '${user.gems}',
                    icon: Icons.diamond_rounded,
                    color: AppColors.tertiary,
                  ),
                  StatTile(
                    label: 'المستوى الحالي',
                    value: '${user.currentLevel}',
                    icon: Icons.flag_rounded,
                    color: AppColors.primary,
                  ),
                  StatTile(
                    label: 'الكلمات المكتشفة',
                    value: '${user.totalWordsFound}',
                    icon: Icons.text_fields_rounded,
                    color: AppColors.secondary,
                  ),
                  StatTile(
                    label: 'الكلمات الإضافية',
                    value: '${user.totalBonusWords}',
                    icon: Icons.auto_awesome_rounded,
                    color: AppColors.tertiary,
                  ),
                  StatTile(
                    label: 'النقاط',
                    value: '${user.totalScore}',
                    icon: Icons.star_rounded,
                    color: AppColors.gold,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Edit name
              AppCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'تعديل الاسم',
                      style: AppTextStyles.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        hintText: user.displayName ?? 'أدخل اسمك',
                        prefixIcon: const Icon(Icons.edit_rounded),
                      ),
                    ),
                    const SizedBox(height: 12),
                    PrimaryButton(
                      text: 'حفظ',
                      isLoading: _isLoading,
                      onPressed: _saveName,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Actions
              AppCard(
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.settings_rounded),
                      title: const Text('الإعدادات'),
                      trailing: const Icon(Icons.arrow_forward_ios_rounded),
                      onTap: () => context.goNamed('settings'),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.help_outline_rounded),
                      title: const Text('المساعدة والدعم'),
                      trailing: const Icon(Icons.arrow_forward_ios_rounded),
                      onTap: () {},
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(
                        Icons.logout_rounded,
                        color: AppColors.error,
                      ),
                      title: const Text(
                        'تسجيل الخروج',
                        style: TextStyle(color: AppColors.error),
                      ),
                      onTap: _signOut,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
