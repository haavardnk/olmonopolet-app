import 'package:flutter/material.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../services/app_launcher.dart';
import '../../utils/environment.dart';
import '../../utils/date_utils.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  late AdaptiveThemeMode? _themeMode = AdaptiveThemeMode.light;
  void _getTheme() async {
    final savedThemeMode = await AdaptiveTheme.getThemeMode();
    setState(() {
      _themeMode = savedThemeMode;
    });
  }

  @override
  void initState() {
    _getTheme();
    super.initState();
  }

  IconData _getThemeIcon() {
    switch (_themeMode) {
      case AdaptiveThemeMode.light:
        return Icons.light_mode;
      case AdaptiveThemeMode.dark:
        return Icons.dark_mode;
      case AdaptiveThemeMode.system:
      default:
        return Icons.brightness_auto;
    }
  }

  String _getThemeLabel() {
    switch (_themeMode) {
      case AdaptiveThemeMode.light:
        return 'Lys';
      case AdaptiveThemeMode.dark:
        return 'Mørk';
      case AdaptiveThemeMode.system:
      default:
        return 'System';
    }
  }

  void _showThemeSelector(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      backgroundColor: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: colors.onSurfaceVariant.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              'Velg tema',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 16.h),
            _buildThemeOption(
              context,
              icon: Icons.light_mode,
              label: 'Lys',
              isSelected: _themeMode == AdaptiveThemeMode.light,
              onTap: () {
                setState(() => _themeMode = AdaptiveThemeMode.light);
                AdaptiveTheme.of(context).setLight();
                Navigator.pop(context);
              },
            ),
            _buildThemeOption(
              context,
              icon: Icons.dark_mode,
              label: 'Mørk',
              isSelected: _themeMode == AdaptiveThemeMode.dark,
              onTap: () {
                setState(() => _themeMode = AdaptiveThemeMode.dark);
                AdaptiveTheme.of(context).setDark();
                Navigator.pop(context);
              },
            ),
            _buildThemeOption(
              context,
              icon: Icons.brightness_auto,
              label: 'System',
              isSelected: _themeMode == AdaptiveThemeMode.system,
              onTap: () {
                setState(() => _themeMode = AdaptiveThemeMode.system);
                AdaptiveTheme.of(context).setSystem();
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final colors = Theme.of(context).colorScheme;
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? colors.primary : colors.onSurfaceVariant,
      ),
      title: Text(
        label,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          color: isSelected ? colors.primary : null,
        ),
      ),
      trailing: isSelected ? Icon(Icons.check, color: colors.primary) : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            // Header with logo and app name
            Padding(
              padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 16.h),
              child: Row(
                children: [
                  Container(
                    width: 56.r,
                    height: 56.r,
                    decoration: BoxDecoration(
                      color: colors.primaryContainer,
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12.r),
                        child: Image.asset(
                          'assets/images/logo_transparent.png',
                          width: 44.r,
                          height: 44.r,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Row(
                    children: [
                      Text(
                        'Ølmonopolet',
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (isHolidaySeason()) ...[
                        SizedBox(width: 8.w),
                        Text(
                          '🎄',
                          style: TextStyle(fontSize: 20.sp),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            Divider(
              height: 1,
              indent: 24.w,
              endIndent: 24.w,
              color: colors.outlineVariant,
            ),

            SizedBox(height: 8.h),

            // Menu items
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                child: Column(
                  children: [
                    _buildMenuItem(
                      context,
                      icon: _getThemeIcon(),
                      label: 'Tema',
                      trailing: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: colors.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Text(
                          _getThemeLabel(),
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ),
                      onTap: () => _showThemeSelector(context),
                    ),
                    SizedBox(height: 4.h),
                    _buildMenuItem(
                      context,
                      icon: Icons.facebook,
                      label: 'Følg på Facebook',
                      onTap: () => AppLauncher.launchFacebook(),
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.email_outlined,
                      label: 'Gi tilbakemelding',
                      onTap: () => launchUrl(
                        Uri.parse('mailto:${Environment.feedbackEmail}'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    final colors = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
          child: Row(
            children: [
              Container(
                width: 40.r,
                height: 40.r,
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  icon,
                  size: 20.r,
                  color: colors.onSurfaceVariant,
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (trailing != null) trailing,
              if (trailing == null)
                Icon(
                  Icons.chevron_right,
                  size: 20.r,
                  color: colors.onSurfaceVariant.withValues(alpha: 0.5),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
