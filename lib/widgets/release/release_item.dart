import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';

import '../../providers/filter.dart';
import '../../screens/product_overview_tab.dart';
import '../../models/release.dart';

class ReleaseItem extends StatelessWidget {
  final Release release;

  const ReleaseItem({super.key, required this.release});

  @override
  Widget build(BuildContext context) {
    final filters = Provider.of<Filter>(context, listen: false);
    final isNew = release.releaseDate != null &&
        DateTime.now().difference(release.releaseDate!).inDays <= 14;
    final stats = release.productStats;

    return Column(
      children: [
        InkWell(
          onTap: () {
            if (filters.filterSaveSettings[12]['save'] == false) {
              filters.releaseSortBy = '-rating';
              filters.releaseSortIndex = 'Global rating - Høy til lav';
            }
            filters.releaseProductSelectionChoice = '';
            pushScreen(
              context,
              screen: ProductOverviewTab(release: release),
              withNavBar: true,
            );
          },
          child: Padding(
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.event_outlined,
                            size: 18.r,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          SizedBox(width: 8.w),
                          if (isNew)
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 6.w, vertical: 2.h),
                              margin: EdgeInsets.only(right: 8.w),
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer,
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                              child: Text(
                                'NY',
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onPrimaryContainer,
                                ),
                              ),
                            ),
                          Expanded(
                            child: Text(
                              release.releaseDate != null
                                  ? toBeginningOfSentenceCase(
                                      DateFormat.yMMMMEEEEd('nb_NO')
                                          .format(release.releaseDate!))
                                  : release.name,
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (stats != null) ...[
                        SizedBox(height: 8.h),
                        Row(
                          children: [
                            Icon(
                              Icons.local_drink_outlined,
                              size: 15.r,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              '${stats.productCount}',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                            ),
                            if (stats.beerCount > 0 ||
                                stats.ciderCount > 0 ||
                                stats.meadCount > 0)
                              Text(
                                ' (${[
                                  if (stats.beerCount > 0)
                                    '${stats.beerCount} øl',
                                  if (stats.ciderCount > 0)
                                    '${stats.ciderCount} cider',
                                  if (stats.meadCount > 0)
                                    '${stats.meadCount} mjød',
                                ].join(', ')})',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                              ),
                          ],
                        ),
                      ],
                      if (release.productSelections.isNotEmpty) ...[
                        SizedBox(height: 8.h),
                        Wrap(
                          spacing: 6.w,
                          runSpacing: 4.h,
                          children: [
                            for (var selection in release.productSelections)
                              if (selection != "Spesialbestilling")
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8.w, vertical: 3.h),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .surfaceContainerHighest,
                                    borderRadius: BorderRadius.circular(6.r),
                                  ),
                                  child: Text(
                                    _getSelectionAbbreviation(selection),
                                    style: TextStyle(
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.w500,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                                  ),
                                ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  size: 24.r,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
        const Divider(height: 1),
      ],
    );
  }

  String _getSelectionAbbreviation(String selection) {
    switch (selection) {
      case 'Basisutvalget':
        return 'Basis';
      case 'Bestillingsutvalget':
        return 'Bestilling';
      case 'Testutvalget':
        return 'Test';
      case 'Partiutvalget':
        return 'Parti';
      case 'Tilleggsutvalget':
        return 'Tillegg';
      case 'Spesialbestilling':
        return 'Spesial';
      case 'Spesialutvalg':
        return 'Spesial';
      default:
        return selection.replaceAll('utvalget', '');
    }
  }
}
