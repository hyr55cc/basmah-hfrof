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
import '../../../../domain/entities/settings.dart';
import '../../../../domain/repositories/settings_repository.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});
  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  AppSettings? _settings;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final result = await sl<SettingsRepository>().getSettings();
    if (!mounted) return;
    setState(() {
      _settings = result.fold((_) => const AppSettings(), (s) => s);
      _isLoading = false;
    });
  }

  Future<void> _update(AppSettings updated) async {
    setState(() => _settings = updated);
    await sl<SettingsRepository>().updateSettings(updated);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _settings == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final settings = _settings!;
    return Scaffold(
      appBar: AppBar(
        title: const Text('الإعدادات'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_forward_ios_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradientLight,
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSection('المظهر', [
              _ThemeSelector(
                current: settings.themeMode,
                onChanged: (mode) =>
                    _update(settings.copyWith(themeMode: mode)),
              ),
              const SizedBox(height: 8),
              _LanguageSelector(
                current: settings.language,
                onChanged: (lang) =>
                    _update(settings.copyWith(language: lang)),
              ),
            ]),
            _buildSection('الصوت والاهتزاز', [
              SwitchListTile(
                value: settings.musicEnabled,
                onChanged: (v) => _update(settings.copyWith(musicEnabled: v)),
                title: const Text('الموسيقى'),
                secondary: const Icon(Icons.music_note_rounded),
              ),
              SwitchListTile(
                value: settings.soundEnabled,
                onChanged: (v) => _update(settings.copyWith(soundEnabled: v)),
                title: const Text('المؤثرات الصوتية'),
                secondary: const Icon(Icons.volume_up_rounded),
              ),
              SwitchListTile(
                value: settings.vibrationEnabled,
                onChanged: (v) =>
                    _update(settings.copyWith(vibrationEnabled: v)),
                title: const Text('الاهتزاز'),
                secondary: const Icon(Icons.vibration_rounded),
              ),
            ]),
            _buildSection('الإشعارات', [
              SwitchListTile(
                value: settings.notificationsEnabled,
                onChanged: (v) =>
                    _update(settings.copyWith(notificationsEnabled: v)),
                title: const Text('الإشعارات'),
                secondary: const Icon(Icons.notifications_rounded),
              ),
              SwitchListTile(
                value: settings.dailyReminderEnabled,
                onChanged: (v) =>
                    _update(settings.copyWith(dailyReminderEnabled: v)),
                title: const Text('تذكير يومي'),
                secondary: const Icon(Icons.alarm_rounded),
              ),
            ]),
            _buildSection('عام', [
              SwitchListTile(
                value: settings.analyticsEnabled,
                onChanged: (v) =>
                    _update(settings.copyWith(analyticsEnabled: v)),
                title: const Text('تحليلات الاستخدام'),
                secondary: const Icon(Icons.analytics_rounded),
              ),
              SwitchListTile(
                value: settings.dataSaverMode,
                onChanged: (v) =>
                    _update(settings.copyWith(dataSaverMode: v)),
                title: const Text('وضع توفير البيانات'),
                secondary: const Icon(Icons.data_saver_off_rounded),
              ),
            ]),
            _buildSection('الحساب والقانوني', [
              ListTile(
                leading: const Icon(Icons.privacy_tip_rounded),
                title: const Text('سياسة الخصوصية'),
                trailing: const Icon(Icons.arrow_forward_ios_rounded),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.gavel_rounded),
                title: const Text('شروط الاستخدام'),
                trailing: const Icon(Icons.arrow_forward_ios_rounded),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.shopping_bag_rounded),
                title: const Text('استعادة المشتريات'),
                onTap: () async {
                  final result =
                      await sl<dynamic>().restorePurchases('current');
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(result.fold(
                        (f) => f.message,
                        (_) => 'تمت استعادة المشتريات',
                      )),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.delete_forever_rounded,
                  color: AppColors.error,
                ),
                title: const Text(
                  'حذف الحساب',
                  style: TextStyle(color: AppColors.error),
                ),
                onTap: () => _confirmDelete(),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
          child: Text(
            title,
            style: AppTextStyles.titleSmall.copyWith(
              color: AppColors.primary,
            ),
          ),
        ),
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Future<void> _confirmDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف الحساب'),
        content: const Text(
          'سيتم حذف حسابك وبياناتك بشكل نهائي. هل أنت متأكد؟',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await sl<dynamic>().deleteAccount();
      if (!mounted) return;
      context.goNamed('auth');
    }
  }
}

class _ThemeSelector extends StatelessWidget {
  const _ThemeSelector({required this.current, required this.onChanged});
  final AppThemeMode current;
  final void Function(AppThemeMode) onChanged;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.palette_rounded),
      title: const Text('المظهر'),
      trailing: SegmentedButton<AppThemeMode>(
        segments: const [
          ButtonSegment(value: AppThemeMode.system, label: Text('تلقائي')),
          ButtonSegment(value: AppThemeMode.light, label: Text('فاتح')),
          ButtonSegment(value: AppThemeMode.dark, label: Text('داكن')),
        ],
        selected: {current},
        onSelectionChanged: (set) => onChanged(set.first),
        showSelectedIcon: false,
      ),
    );
  }
}

class _LanguageSelector extends StatelessWidget {
  const _LanguageSelector({required this.current, required this.onChanged});
  final AppLanguage current;
  final void Function(AppLanguage) onChanged;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.language_rounded),
      title: const Text('اللغة'),
      subtitle: Text(_label(current)),
      trailing: DropdownButton<AppLanguage>(
        value: current,
        underline: const SizedBox.shrink(),
        items: AppLanguage.values
            .map((l) => DropdownMenuItem(value: l, child: Text(_label(l))))
            .toList(),
        onChanged: (lang) {
          if (lang != null) onChanged(lang);
        },
      ),
    );
  }

  String _label(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.arabic:
        return 'العربية';
      case AppLanguage.english:
        return 'English';
      case AppLanguage.french:
        return 'Français';
      case AppLanguage.spanish:
        return 'Español';
    }
  }
}
