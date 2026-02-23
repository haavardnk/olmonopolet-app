import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../providers/auth.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final auth = context.watch<Auth>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
          child: Column(
            children: [
              SizedBox(height: 16.h),
              _buildAvatar(auth, colors),
              SizedBox(height: 16.h),
              if (auth.displayName.isNotEmpty)
                Text(
                  auth.displayName,
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              if (auth.email != null) ...[
                SizedBox(height: 4.h),
                Text(
                  auth.email!,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
              SizedBox(height: 32.h),

              _buildSectionHeader('Tilkoblede kontoer', colors),
              SizedBox(height: 8.h),
              _buildProviderTile(
                icon: Icons.email_outlined,
                label: 'E-post',
                connected: auth.hasEmailProvider,
                colors: colors,
              ),
              _buildProviderTile(
                icon: Icons.g_mobiledata,
                label: 'Google',
                connected: auth.hasGoogleProvider,
                colors: colors,
              ),
              _buildProviderTile(
                icon: Icons.apple,
                label: 'Apple',
                connected: auth.hasAppleProvider,
                colors: colors,
              ),

              SizedBox(height: 32.h),
              _buildSectionHeader('Konto', colors),
              SizedBox(height: 8.h),

              _buildActionTile(
                icon: Icons.logout,
                label: 'Logg ut',
                colors: colors,
                onTap: () => _handleSignOut(context),
              ),
              SizedBox(height: 8.h),
              _buildActionTile(
                icon: Icons.delete_forever_outlined,
                label: 'Slett konto',
                colors: colors,
                destructive: true,
                onTap: () => _handleDeleteAccount(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(Auth auth, ColorScheme colors) {
    if (auth.photoUrl != null) {
      return CircleAvatar(
        radius: 48.r,
        backgroundImage: NetworkImage(auth.photoUrl!),
        backgroundColor: colors.primaryContainer,
      );
    }

    return CircleAvatar(
      radius: 48.r,
      backgroundColor: colors.primaryContainer,
      child: Text(
        auth.displayName.isNotEmpty
            ? auth.displayName[0].toUpperCase()
            : '?',
        style: TextStyle(
          fontSize: 36.sp,
          fontWeight: FontWeight.bold,
          color: colors.onPrimaryContainer,
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, ColorScheme colors) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13.sp,
          fontWeight: FontWeight.w600,
          color: colors.onSurfaceVariant,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildProviderTile({
    required IconData icon,
    required String label,
    required bool connected,
    required ColorScheme colors,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 4.h),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: ListTile(
        leading: Icon(icon, color: colors.onSurfaceVariant),
        title: Text(label, style: TextStyle(fontSize: 15.sp)),
        trailing: connected
            ? Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  'Tilkoblet',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: colors.onPrimaryContainer,
                  ),
                ),
              )
            : Text(
                'Ikke tilkoblet',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: colors.onSurfaceVariant,
                ),
              ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String label,
    required ColorScheme colors,
    required VoidCallback onTap,
    bool destructive = false,
  }) {
    final color = destructive ? colors.error : colors.onSurface;

    return Container(
      decoration: BoxDecoration(
        color: destructive
            ? colors.errorContainer.withValues(alpha: 0.3)
            : colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(
          label,
          style: TextStyle(
            fontSize: 15.sp,
            color: color,
            fontWeight: destructive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        trailing: Icon(Icons.chevron_right, color: color.withValues(alpha: 0.5)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        onTap: onTap,
      ),
    );
  }

  void _handleSignOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logg ut'),
        content: const Text('Er du sikker på at du vil logge ut?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Avbryt'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await context.read<Auth>().signOut();
              if (context.mounted) Navigator.of(context).pop();
            },
            child: const Text('Logg ut'),
          ),
        ],
      ),
    );
  }

  void _handleDeleteAccount(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Slett konto'),
        content: const Text(
          'Er du sikker på at du vil slette kontoen din? '
          'Denne handlingen kan ikke angres.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Avbryt'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await context.read<Auth>().deleteAccount();
                if (context.mounted) Navigator.of(context).pop();
              } on FirebaseAuthException catch (_) {
                if (context.mounted) {
                  _showReauthDialog(context);
                }
              } catch (_) {
                if (context.mounted) {
                  _showReauthDialog(context);
                }
              }
            },
            child: const Text('Slett'),
          ),
        ],
      ),
    );
  }

  void _showReauthDialog(BuildContext context) {
    final auth = context.read<Auth>();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Bekreft identitet'),
        content: const Text(
          'Du må logge inn på nytt for å slette kontoen din.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Avbryt'),
          ),
          if (auth.hasGoogleProvider)
            TextButton(
              onPressed: () async {
                Navigator.pop(ctx);
                try {
                  await auth.reauthenticateWithGoogle();
                  await auth.deleteAccount();
                  if (context.mounted) Navigator.of(context).pop();
                } catch (_) {}
              },
              child: const Text('Google'),
            ),
          if (auth.hasAppleProvider)
            TextButton(
              onPressed: () async {
                Navigator.pop(ctx);
                try {
                  await auth.reauthenticateWithApple();
                  await auth.deleteAccount();
                  if (context.mounted) Navigator.of(context).pop();
                } catch (_) {}
              },
              child: const Text('Apple'),
            ),
        ],
      ),
    );
  }
}
