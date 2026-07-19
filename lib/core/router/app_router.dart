import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/auth_wrapper.dart';
import '../../features/game/presentation/screens/game_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/levels/presentation/screens/level_select_screen.dart';
import '../../features/levels/presentation/screens/level_map_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import '../../features/shop/presentation/screens/shop_screen.dart';
import '../../features/leaderboard/presentation/screens/leaderboard_screen.dart';
import '../../features/daily_reward/presentation/screens/daily_reward_screen.dart';
import '../../features/achievements/presentation/screens/achievements_screen.dart';
import '../../features/premium/presentation/screens/premium_screen.dart';

/// Centralized route definitions
class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String auth = '/auth';
  static const String login = '/login';
  static const String home = '/home';
  static const String game = '/game/:levelId';
  static const String levelMap = '/levels/map';
  static const String levelSelect = '/levels/select';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String shop = '/shop';
  static const String leaderboard = '/leaderboard';
  static const String dailyReward = '/daily-reward';
  static const String achievements = '/achievements';
  static const String premium = '/premium';
}

/// Application router configuration
class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: false,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.auth,
        name: 'auth',
        builder: (context, state) => const AuthWrapper(),
        routes: [
          GoRoute(
            path: 'login',
            name: 'login',
            builder: (context, state) => const LoginScreen(),
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        builder: (context, state) => const HomeScreen(),
        routes: [
          GoRoute(
            path: 'profile',
            name: 'profile',
            builder: (context, state) => const ProfileScreen(),
          ),
          GoRoute(
            path: 'settings',
            name: 'settings',
            builder: (context, state) => const SettingsScreen(),
          ),
          GoRoute(
            path: 'shop',
            name: 'shop',
            builder: (context, state) => const ShopScreen(),
          ),
          GoRoute(
            path: 'leaderboard',
            name: 'leaderboard',
            builder: (context, state) => const LeaderboardScreen(),
          ),
          GoRoute(
            path: 'achievements',
            name: 'achievements',
            builder: (context, state) => const AchievementsScreen(),
          ),
          GoRoute(
            path: 'premium',
            name: 'premium',
            builder: (context, state) => const PremiumScreen(),
          ),
          GoRoute(
            path: 'levels',
            name: 'level-select',
            builder: (context, state) => const LevelSelectScreen(),
            routes: [
              GoRoute(
                path: 'map',
                name: 'level-map',
                builder: (context, state) => const LevelMapScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.game,
        name: 'game',
        builder: (context, state) {
          final levelId = int.parse(state.pathParameters['levelId']!);
          return GameScreen(levelId: levelId);
        },
      ),
      GoRoute(
        path: AppRoutes.dailyReward,
        name: 'daily-reward',
        builder: (context, state) => const DailyRewardScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('الصفحة غير موجودة: ${state.error}'),
      ),
    ),
  );
}
