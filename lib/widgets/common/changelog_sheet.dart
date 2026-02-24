import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'drag_handle.dart';

import '../../assets/changelog_data.dart';
import '../../models/changelog.dart';

const String _changelogSeenKey = 'changelog_seen_version';

Future<void> showChangelogIfNeeded(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();
  final seenVersion = prefs.getString(_changelogSeenKey) ?? '';
  final latest = changelogVersions.first;

  if (seenVersion == latest.version) return;

  await prefs.setString(_changelogSeenKey, latest.version);

  if (!context.mounted) return;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
    ),
    builder: (sheetContext) => _ChangelogSheet(version: latest),
  );
}

class _ChangelogSheet extends StatelessWidget {
  final ChangelogVersion version;

  const _ChangelogSheet({required this.version});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 24.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const DragHandle(),
            SizedBox(height: 20.h),
            Icon(
              Icons.auto_awesome,
              size: 32.r,
              color: colors.primary,
            ),
            SizedBox(height: 12.h),
            Text(
              version.title,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              'Versjon ${version.version}',
              style: TextStyle(
                fontSize: 13.sp,
                color: colors.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 20.h),
            ...version.entries.map((entry) => _buildEntry(entry, colors)),
            SizedBox(height: 16.h),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pop(context),
                style: FilledButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: const Text('Flott!'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEntry(ChangelogEntry entry, ColorScheme colors) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44.r,
            height: 44.r,
            decoration: BoxDecoration(
              color: colors.primaryContainer,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              entry.icon,
              size: 22.r,
              color: colors.onPrimaryContainer,
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.title,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  entry.description,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: colors.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
