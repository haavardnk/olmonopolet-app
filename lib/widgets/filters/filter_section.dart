import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FilterSection extends StatelessWidget {
  final String title;
  final IconData? icon;
  final String? subtitle;
  final String? resetLabel;
  final VoidCallback? onReset;
  final Widget child;
  final EdgeInsets padding;

  const FilterSection({
    super.key,
    required this.title,
    this.icon,
    this.subtitle,
    this.resetLabel,
    this.onReset,
    required this.child,
    this.padding = const EdgeInsets.symmetric(vertical: 6),
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: 16.r, color: colors.primary),
                      SizedBox(width: 6.w),
                    ],
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: colors.primary,
                      ),
                    ),
                    if (subtitle != null) ...[
                      SizedBox(width: 6.w),
                      Text(
                        subtitle!,
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (onReset != null && resetLabel != null)
                GestureDetector(
                  onTap: onReset,
                  child: Text(
                    resetLabel!,
                    style: TextStyle(fontSize: 12.sp, color: colors.primary),
                  ),
                ),
            ],
          ),
          SizedBox(height: 6.h),
          child,
        ],
      ),
    );
  }
}
