import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../models/release.dart';
import '../../providers/filter.dart';
import '../../assets/constants.dart';

class ProductOverviewReleaseSort extends StatefulWidget {
  final Release release;
  const ProductOverviewReleaseSort(this.release, {super.key});

  @override
  State<ProductOverviewReleaseSort> createState() => _ReleaseSortState();
}

class _ReleaseSortState extends State<ProductOverviewReleaseSort> {
  late final filters = Provider.of<Filter>(context, listen: false).filters;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => _showSortSheet(context),
      icon: const Icon(
        Icons.sort,
        semanticLabel: "Sortering",
      ),
    );
  }

  void _showSortSheet(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Center(
              child: Container(
                margin: EdgeInsets.only(top: 12.h, bottom: 8.h),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.onSurfaceVariant.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: Row(
                children: [
                  Icon(Icons.sort, size: 20.r, color: colors.primary),
                  SizedBox(width: 8.w),
                  Text(
                    'Sortering',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Consumer<Filter>(
                    builder: (context, _, __) => Row(
                      children: [
                        Text(
                          'Husk valg',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Transform.scale(
                          scale: 0.8,
                          child: Switch(
                            value: filters.filterSaveSettings[12]['save'],
                            onChanged: (bool newValue) {
                              filters.filterSaveSettings[12]['save'] = newValue;
                              filters.saveFilterSettings();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: colors.outlineVariant),
            // Sort options
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.symmetric(vertical: 8.h),
                itemCount: sortList.length,
                itemBuilder: (context, index) {
                  final key = sortList.keys.toList()[index];
                  final isSelected = filters.releaseSortIndex == key;
                  return ListTile(
                    dense: true,
                    title: Text(key),
                    trailing: isSelected
                        ? Icon(Icons.check_circle, color: colors.primary)
                        : null,
                    onTap: () {
                      filters.releaseSortIndex = key;
                      filters.setSortBy(key, true);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 8.h),
          ],
        ),
      ),
    );
  }
}
