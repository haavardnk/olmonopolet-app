import 'package:flutter/material.dart' hide SearchBar;
import 'package:intl/intl.dart';

import '../widgets/products/product_list.dart';
import '../widgets/drawer/app_drawer.dart';
import '../widgets/products/product_overview_bottom_filter_sheet.dart';
import '../widgets/products/product_overview_search_bar.dart';
import '../widgets/products/product_overview_release_sort.dart';
import '../widgets/products/product_overview_release_product_selection.dart';
import '../models/release.dart';

class ProductOverviewTab extends StatelessWidget {
  final Release? release;

  const ProductOverviewTab({super.key, this.release});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        title: release != null
            ? FittedBox(
                fit: BoxFit.contain,
                child: Text(
                  release!.releaseDate != null
                      ? toBeginningOfSentenceCase(DateFormat.yMMMMEEEEd('nb_NO')
                          .format(release!.releaseDate!))
                      : release!.name,
                ),
              )
            : const ProductOverviewSearchBar(),
        actions: [
          release == null
              ? const ProductOverviewBottomFilterSheet()
              : ProductOverviewReleaseSort(release!),
        ],
        bottom: (release != null && release!.productSelections.length > 1)
            ? PreferredSize(
                preferredSize: const Size.fromHeight(kToolbarHeight),
                child: ProductOverviewReleaseProductSelection(release: release),
              )
            : null,
      ),
      drawer: release == null ? const AppDrawer() : null,
      body: ProductList(
        release: release,
      ),
    );
  }
}
