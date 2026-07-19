import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AdminShell extends StatelessWidget {
  const AdminShell({required this.child, super.key});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة تحكم لغز الكلمات'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () => context.go('/login'),
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: child,
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          const DrawerHeader(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text('لوحة التحكم',
                    style: TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text('إدارة لعبة لغز الكلمات'),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard_rounded),
            title: const Text('الرئيسية'),
            onTap: () => context.go('/'),
          ),
          ListTile(
            leading: const Icon(Icons.flag_rounded),
            title: const Text('المستويات'),
            onTap: () => context.go('/levels'),
          ),
          ListTile(
            leading: const Icon(Icons.people_rounded),
            title: const Text('المستخدمون'),
            onTap: () => context.go('/users'),
          ),
          ListTile(
            leading: const Icon(Icons.analytics_rounded),
            title: const Text('التحليلات'),
            onTap: () => context.go('/analytics'),
          ),
          ListTile(
            leading: const Icon(Icons.notifications_rounded),
            title: const Text('الإشعارات'),
            onTap: () => context.go('/notifications'),
          ),
          ListTile(
            leading: const Icon(Icons.attach_money_rounded),
            title: const Text('الإيرادات'),
            onTap: () => context.go('/revenue'),
          ),
        ],
      ),
    );
  }
}
