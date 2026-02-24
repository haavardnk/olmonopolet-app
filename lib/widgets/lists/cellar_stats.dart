import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../models/user_list.dart';

class CellarStatsWidget extends StatelessWidget {
  final ListStats stats;

  const CellarStatsWidget({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6.w,
      runSpacing: 6.h,
      children: [
        _buildChip(
          context,
          Icons.inventory_2_outlined,
          '${stats.totalBottles} flasker',
        ),
        _buildChip(
          context,
          Icons.payments_outlined,
          'Kr ${stats.totalValue.toStringAsFixed(0)}',
        ),
        if (stats.oldestYear != null || stats.newestYear != null)
          _buildChip(
            context,
            Icons.calendar_today_outlined,
            _yearRange,
          ),
      ],
    );
  }

  String get _yearRange {
    if (stats.oldestYear != null && stats.newestYear != null) {
      if (stats.oldestYear == stats.newestYear) return '${stats.oldestYear}';
      return '${stats.oldestYear} – ${stats.newestYear}';
    }
    return stats.oldestYear?.toString() ??
        stats.newestYear?.toString() ??
        '-';
  }

  Widget _buildChip(BuildContext context, IconData icon, String text) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.r, color: colors.primary),
          SizedBox(width: 6.w),
          Text(
            text,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: colors.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
