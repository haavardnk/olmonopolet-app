import 'package:flutter/material.dart' hide SearchBar;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/filter.dart';
import '../widgets/products/product_list.dart';
import '../widgets/drawer/app_drawer.dart';
import '../widgets/filters/product_filter_sheet.dart';
import '../widgets/products/product_overview_search_bar.dart';
import '../widgets/products/product_overview_release_sort.dart';
import '../widgets/products/product_overview_release_product_selection.dart';
import '../models/release.dart';

class ProductOverviewTab extends StatelessWidget {
  final Release? release;

  const ProductOverviewTab({super.key, this.release});

  @override
  Widget build(BuildContext context) {
    return Consumer<Filter>(
      builder: (context, filters, child) {
        final storeName = filters.selectedStores.isNotEmpty
            ? filters.selectedStores.first
            : 'Oversikt';

        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: release != null
                ? FittedBox(
                    fit: BoxFit.contain,
                    child: Text(
                      release!.releaseDate != null
                          ? toBeginningOfSentenceCase(
                              DateFormat.yMMMMEEEEd('nb_NO')
                                  .format(release!.releaseDate!))
                          : release!.name,
                    ),
                  )
                : Text(storeName),
            actions: [
              release == null
                  ? const ProductFilterSheet()
                  : ProductOverviewReleaseSort(release!),
            ],
            bottom: release != null
                ? (release!.productSelections.length > 1)
                    ? PreferredSize(
                        preferredSize: const Size.fromHeight(kToolbarHeight),
                        child: ProductOverviewReleaseProductSelection(
                            release: release),
                      )
                    : null
                : PreferredSize(
                    preferredSize: Size.fromHeight(56.h),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
                      child: const ProductOverviewSearchBar(),
                    ),
                  ),
          ),
          drawer: release == null ? const AppDrawer() : null,
          body: ProductList(
            release: release,
          ),
        );
      },
    );
  }
}
