import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../domain/repositories/auth_repository.dart';
import '../../../../services/analytics/analytics_service.dart';
import '../../domain/usecases/auth_usecases.dart' as auth;
import '../../../../domain/usecases/usecases.dart' show NoParams;

/// Auth screen - shows login options
class AuthWrapper extends ConsumerStatefulWidget {
  const AuthWrapper({super.key});

  @override
  ConsumerState<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends ConsumerState<AuthWrapper> {
  bool _isLoading = false;
  String? _error;

  Future<void> _signInAnonymously() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    final useCase = auth.SignInAnonymously(sl<AuthRepository>());
    final result = await useCase(const NoParams());
    result.fold(
      (failure) {
        setState(() {
          _isLoading = false;
          _error = failure.message;
        });
      },
      (authResult) {
        sl<AnalyticsService>().logLogin('anonymous');
        if (mounted) context.goNamed('home');
      },
    );
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    final useCase = auth.SignInWithGoogle(sl<AuthRepository>());
    final result = await useCase(const NoParams());
    result.fold(
      (failure) {
        setState(() {
          _isLoading = false;
          _error = failure.message;
        });
      },
      (authResult) {
        sl<AnalyticsService>().logLogin('google');
        if (mounted) context.goNamed('home');
      },
    );
  }

  Future<void> _signInWithApple() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    final useCase = auth.SignInWithApple(sl<AuthRepository>());
    final result = await useCase(const NoParams());
    result.fold(
      (failure) {
        setState(() {
          _isLoading = false;
          _error = failure.message;
        });
      },
      (authResult) {
        sl<AnalyticsService>().logLogin('apple');
        if (mounted) context.goNamed('home');
      },
    );
  }

  void _navigateToLogin() {
    context.goNamed('login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary,
              AppColors.primaryDark,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                // Logo
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'كل',
                      style: TextStyle(
                        fontSize: 56,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'لغز الكلمات',
                  style: AppTextStyles.displaySmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'لعبة ألغاز الكلمات العربية',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: Colors.white.withOpacity(0.85),
                  ),
                ),
                const Spacer(),
                if (_error != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.error.withOpacity(0.5),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.error_outline_rounded,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _error!,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                // Google sign in
                _SocialButton(
                  text: 'متابعة مع Google',
                  icon: 'G',
                  color: Colors.white,
                  textColor: AppColors.textPrimaryLight,
                  onPressed: _isLoading ? null : _signInWithGoogle,
                ),
                const SizedBox(height: 12),
                // Apple sign in
                _SocialButton(
                  text: 'متابعة مع Apple',
                  icon: '',
                  color: Colors.black,
                  textColor: Colors.white,
                  onPressed: _isLoading ? null : _signInWithApple,
                  iconWidget: const Icon(
                    Icons.apple_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 12),
                // Email sign in
                _SocialButton(
                  text: 'متابعة بالبريد الإلكتروني',
                  iconWidget: const Icon(
                    Icons.email_rounded,
                    color: AppColors.primary,
                    size: 24,
                  ),
                  color: Colors.white,
                  textColor: AppColors.primary,
                  onPressed: _isLoading ? null : _navigateToLogin,
                ),
                const SizedBox(height: 12),
                // Guest sign in
                TextAppButton(
                  text: 'متابعة كضيف',
                  icon: Icons.person_outline_rounded,
                  color: Colors.white,
                  onPressed: _isLoading ? null : _signInAnonymously,
                ),
                if (_isLoading) ...[
                  const SizedBox(height: 24),
                  const CircularProgressIndicator(
                    color: Colors.white,
                  ),
                ],
                const SizedBox(height: 24),
                Text(
                  'بتسجيل الدخول، فأنت توافق على شروط الاستخدام وسياسة الخصوصية',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.white.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.text,
    this.icon,
    this.iconWidget,
    required this.color,
    required this.textColor,
    required this.onPressed,
  });

  final String text;
  final String? icon;
  final Widget? iconWidget;
  final Color color;
  final Color textColor;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (iconWidget != null) ...[
                iconWidget!,
                const SizedBox(width: 12),
              ] else if (icon != null && icon!.isNotEmpty) ...[
                Container(
                  width: 28,
                  height: 28,
                  alignment: Alignment.center,
                  child: Text(
                    icon!,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Text(
                text,
                style: AppTextStyles.labelLarge.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
