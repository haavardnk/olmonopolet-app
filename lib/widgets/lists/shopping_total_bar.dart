import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ShoppingTotalBar extends StatelessWidget {
  final double totalPrice;
  final int itemCount;
  final int totalUnits;
  final int? inStockCount;

  const ShoppingTotalBar({
    super.key,
    required this.totalPrice,
    required this.itemCount,
    required this.totalUnits,
    this.inStockCount,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;

    return Container(
      margin: EdgeInsets.fromLTRB(12.w, 4.h, 12.w, 8.h + bottomPadding),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Kr ${totalPrice.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                '$itemCount produkter${totalUnits != itemCount ? ' ($totalUnits stk)' : ''}',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const Spacer(),
          if (inStockCount != null)
            _buildStockBadge(colors),
        ],
      ),
    );
  }

  Widget _buildStockBadge(ColorScheme colors) {
    final Color badgeColor;
    final IconData badgeIcon;
    if (inStockCount == itemCount) {
      badgeColor = Colors.green;
      badgeIcon = Icons.check_circle;
    } else if (inStockCount == 0) {
      badgeColor = Colors.red;
      badgeIcon = Icons.cancel;
    } else {
      badgeColor = Colors.amber;
      badgeIcon = Icons.remove_circle;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(badgeIcon, size: 14.r, color: badgeColor),
          SizedBox(width: 4.w),
          Text(
            '$inStockCount/$itemCount',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: badgeColor,
            ),
          ),
        ],
      ),
    );
  }
}
