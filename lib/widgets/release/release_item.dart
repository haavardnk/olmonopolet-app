import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../assets/constants.dart';
import '../../providers/filter.dart';
import '../../models/release.dart';
import '../common/info_chips.dart';

class ReleaseItem extends StatelessWidget {
  final Release release;

  const ReleaseItem({super.key, required this.release});

  @override
  Widget build(BuildContext context) {
    final filters = Provider.of<Filter>(context, listen: false);
    final isNew = release.releaseDate != null &&
        DateTime.now().difference(release.releaseDate!).inDays <= 14;
    final stats = release.productStats;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12.r),
        onTap: () {
          if (filters.filterSaveSettings[12]['save'] == false) {
            filters.releaseSortBy = '-rating';
            filters.releaseSortIndex = 'Global rating - Høy til lav';
          }
          filters.releaseProductSelectionChoice = '';
          context.go(
            '/releases/${release.name.replaceAll(' ', '-')}',
            extra: release,
          );
        },
        child: Padding(
          padding: EdgeInsets.fromLTRB(12.r, 10.r, 12.r, 10.r),
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
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
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
                          if (release.isChristmasRelease) ...[
                            SizedBox(width: 8.w),
                            buildChristmasChip(context),
                          ],
                        ],
                      ),
                    ],
                    if (release.productSelections.isNotEmpty) ...[
                      SizedBox(height: 8.h),
                      Wrap(
                        spacing: 6.w,
                        runSpacing: 4.h,
                        children: [
                          for (var abbreviation in release.productSelections
                              .map(_getSelectionAbbreviation)
                              .toSet())
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
                                abbreviation,
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
    );
  }

  String _getSelectionAbbreviation(String selection) {
    return productSelectionReleaseAbbreviationList[selection] ??
        selection.replaceAll('utvalget', '');
  }
}
