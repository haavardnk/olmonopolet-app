import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../assets/constants.dart';
import '../../models/release.dart';
import '../../providers/filter.dart';

class ProductOverviewReleaseProductSelection extends StatelessWidget {
  const ProductOverviewReleaseProductSelection({
    super.key,
    required this.release,
  });

  final Release? release;

  String _getDisplayName(String selection) {
    if (selection.isEmpty) return 'Alle produktutvalg';
    return productSelectionDisplayNameList[selection] ?? selection;
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final selections = ['', ...release!.productSelections];

    return Consumer<Filter>(
      builder: (context, filter, _) => Padding(
        padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
        child: InkWell(
          onTap: () => _showSelectionSheet(context, filter, selections),
          borderRadius: BorderRadius.circular(12.r),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.filter_list,
                  size: 18.r,
                  color: colors.onSurfaceVariant,
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    _getDisplayName(filter.releaseProductSelectionChoice),
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: filter.releaseProductSelectionChoice.isEmpty
                          ? colors.onSurfaceVariant
                          : colors.onSurface,
                    ),
                  ),
                ),
                Icon(
                  Icons.expand_more,
                  size: 20.r,
                  color: colors.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSelectionSheet(
    BuildContext context,
    Filter filter,
    List<String> selections,
  ) {
    final colors = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: EdgeInsets.only(top: 12.h),
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: colors.onSurfaceVariant.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 8.h),
            child: Row(
              children: [
                Icon(
                  Icons.category_outlined,
                  size: 20.r,
                  color: colors.primary,
                ),
                SizedBox(width: 10.w),
                Text(
                  'Produktutvalg',
                  style: TextStyle(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: colors.outlineVariant),
          ...selections.map((selection) {
            final isSelected =
                filter.releaseProductSelectionChoice == selection;
            final label = _getDisplayName(selection);

            return ListTile(
              title: Text(
                label,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? colors.primary : null,
                ),
              ),
              trailing:
                  isSelected ? Icon(Icons.check, color: colors.primary) : null,
              onTap: () {
                filter.setReleaseProductSelectionChoice(selection);
                Navigator.pop(context);
              },
            );
          }),
          SizedBox(height: 16.h),
        ],
      ),
    );
  }
}
