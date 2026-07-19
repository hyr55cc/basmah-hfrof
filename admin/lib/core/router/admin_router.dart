import 'package:go_router/go_router.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/levels/screens/admin_levels_screen.dart';
import '../../features/users/screens/admin_users_screen.dart';
import '../../features/analytics/screens/admin_analytics_screen.dart';
import '../../features/notifications/screens/admin_notifications_screen.dart';
import '../../features/revenue/screens/admin_revenue_screen.dart';
import '../../features/auth/screens/admin_login_screen.dart';
import '../../layout/admin_shell.dart';

class AdminRouter {
  AdminRouter._();
  static final GoRouter router = GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const AdminLoginScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => AdminShell(child: child),
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/levels',
            builder: (context, state) => const AdminLevelsScreen(),
          ),
          GoRoute(
            path: '/users',
            builder: (context, state) => const AdminUsersScreen(),
          ),
          GoRoute(
            path: '/analytics',
            builder: (context, state) => const AdminAnalyticsScreen(),
          ),
          GoRoute(
            path: '/notifications',
            builder: (context, state) => const AdminNotificationsScreen(),
          ),
          GoRoute(
            path: '/revenue',
            builder: (context, state) => const AdminRevenueScreen(),
          ),
        ],
      ),
    ],
  );
}
