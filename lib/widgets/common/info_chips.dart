import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flag/flag.dart';

Widget buildInfoChip(String text, BuildContext context,
    {bool highlight = false, IconData? icon}) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
    decoration: BoxDecoration(
      color: highlight
          ? Theme.of(context).colorScheme.primaryContainer
          : Theme.of(context).colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(12.r),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(
            icon,
            size: 10.r,
            color: highlight
                ? Theme.of(context).colorScheme.onPrimaryContainer
                : Theme.of(context).colorScheme.primary,
          ),
          SizedBox(width: 3.w),
        ],
        Text(
          text,
          style: TextStyle(
            fontSize: 10.sp,
            fontWeight: FontWeight.w500,
            color: highlight
                ? Theme.of(context).colorScheme.onPrimaryContainer
                : Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    ),
  );
}

Widget buildInfoChipWithFlag(
    String country, String? countryCode, BuildContext context,
    {bool showName = true}) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(12.r),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (countryCode != null && countryCode.isNotEmpty) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(2.r),
            child: Flag.fromString(
              countryCode,
              height: 10.r,
              width: 10.r * 4 / 3,
            ),
          ),
          if (showName) SizedBox(width: 4.w),
        ],
        if (showName)
          Text(
            country,
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
      ],
    ),
  );
}

Widget buildChristmasChip(BuildContext context) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
    decoration: BoxDecoration(
      color: const Color(0xFF1B5E20),
      borderRadius: BorderRadius.circular(12.r),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '🎄',
          style: TextStyle(fontSize: 9.sp),
        ),
        SizedBox(width: 3.w),
        Text(
          'Juleøl',
          style: TextStyle(
            fontSize: 10.sp,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ],
    ),
  );
}
