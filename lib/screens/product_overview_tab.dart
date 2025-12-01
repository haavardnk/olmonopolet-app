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

class ProductOverviewTab extends StatefulWidget {
  final Release? release;
  final String? releaseName;

  const ProductOverviewTab({super.key, this.release, this.releaseName});

  @override
  State<ProductOverviewTab> createState() => _ProductOverviewTabState();
}

class _ProductOverviewTabState extends State<ProductOverviewTab> {
  Release? _release;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _release = widget.release;
    if (_release == null && widget.releaseName != null) {
      _loadReleaseByName();
    }
  }

  void _loadReleaseByName() {
    setState(() => _isLoading = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final filters = Provider.of<Filter>(context, listen: false);
      Release? release;
      try {
        release = filters.releaseList.firstWhere(
          (r) => r.name == widget.releaseName,
        );
      } catch (e) {
        // Release not found, create a minimal one
        release = Release(name: widget.releaseName!, productSelections: []);
      }
      setState(() {
        _release = release;
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final release = _release;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.releaseName ?? 'Lansering'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

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
                      release.releaseDate != null
                          ? toBeginningOfSentenceCase(
                              DateFormat.yMMMMEEEEd('nb_NO')
                                  .format(release.releaseDate!))
                          : release.name,
                    ),
                  )
                : Text(storeName),
            actions: [
              release == null
                  ? const ProductFilterSheet()
                  : ProductOverviewReleaseSort(release),
            ],
            bottom: release != null
                ? (release.productSelections.length > 1)
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
