import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/primary_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingPage> _pages = const [
    _OnboardingPage(
      icon: Icons.connect_without_contact_rounded,
      title: 'اربط الحروف',
      description:
          'اسحب بإصبعك لربط الحروف العربية وكوّن كلمات في كل مستوى',
      color: AppColors.primary,
    ),
    _OnboardingPage(
      icon: Icons.menu_book_rounded,
      title: 'قاموس عربي شامل',
      description:
          'أكثر من 300,000 كلمة عربية مع دعم تطبيع الحروف وإزالة التشكيل',
      color: AppColors.tertiary,
    ),
    _OnboardingPage(
      icon: Icons.monetization_on_rounded,
      title: 'اكسب المكافآت',
      description:
          'اجمع العملات وأكمل المستويات وافتح الإنجازات والمكافآت اليومية',
      color: AppColors.gold,
    ),
    _OnboardingPage(
      icon: Icons.emoji_events_rounded,
      title: 'تنافس مع الآخرين',
      description:
          'اصعد إلى قمة لوحة المتصدرين وتنافس مع لاعبين من كل العالم العربي',
      color: AppColors.secondary,
    ),
  ];

  void _next() {
    if (_currentPage == _pages.length - 1) {
      context.goNamed('auth');
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _skip() {
    context.goNamed('auth');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradientLight,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Skip button
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextAppButton(
                      text: 'تخطي',
                      onPressed: _skip,
                    ),
                  ],
                ),
              ),
              // Pages
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _pages.length,
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  itemBuilder: (context, index) =>
                      _OnboardingPageView(page: _pages[index]),
                ),
              ),
              // Indicator
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: SmoothPageIndicator(
                  controller: _pageController,
                  count: _pages.length,
                  effect: ExpandingDotsEffect(
                    activeDotColor: AppColors.primary,
                    dotColor: AppColors.borderLight,
                    dotHeight: 8,
                    dotWidth: 8,
                    spacing: 6,
                    expansionFactor: 4,
                  ),
                ),
              ),
              // CTA
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: PrimaryButton(
                  text:
                      _currentPage == _pages.length - 1 ? 'ابدأ الآن' : 'التالي',
                  icon: _currentPage == _pages.length - 1
                      ? Icons.check_rounded
                      : Icons.arrow_forward_rounded,
                  onPressed: _next,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingPage {
  const _OnboardingPage({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
  final IconData icon;
  final String title;
  final String description;
  final Color color;
}

class _OnboardingPageView extends StatelessWidget {
  const _OnboardingPageView({required this.page});
  final _OnboardingPage page;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  page.color.withOpacity(0.8),
                  page.color,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: page.color.withOpacity(0.4),
                  blurRadius: 40,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: Icon(
              page.icon,
              size: 100,
              color: Colors.white,
            ),
          ).animate()
            .scale(
              duration: 800.ms,
              curve: Curves.elasticOut,
            )
            .then()
            .shimmer(
              duration: 1500.ms,
              color: Colors.white.withOpacity(0.3),
            ),
          const SizedBox(height: 48),
          Text(
            page.title,
            style: AppTextStyles.displaySmall.copyWith(
              color: page.color,
            ),
            textAlign: TextAlign.center,
          ).animate()
            .fadeIn(duration: 600.ms)
            .slideY(begin: 0.3, end: 0),
          const SizedBox(height: 16),
          Text(
            page.description,
            style: AppTextStyles.bodyLarge,
            textAlign: TextAlign.center,
          ).animate(delay: 200.ms)
            .fadeIn(duration: 600.ms)
            .slideY(begin: 0.3, end: 0),
        ],
      ),
    );
  }
}
