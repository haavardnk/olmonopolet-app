import 'package:flutter/material.dart' hide SearchBar;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/filter.dart';
import '../widgets/products/product_list.dart';
import '../widgets/drawer/app_drawer.dart';
import '../widgets/filters/product_filter_sheet.dart';
import '../widgets/filters/product_release_filter_sheet.dart';
import '../widgets/products/product_overview_search_bar.dart';
import '../widgets/products/product_overview_release_search_bar.dart';
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
  Filter? _filters;

  @override
  void initState() {
    super.initState();
    _release = widget.release;
    if (_release == null && widget.releaseName != null) {
      _loadReleaseByName();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_filters == null) {
      _filters = Provider.of<Filter>(context, listen: false);
      if (_release != null || widget.releaseName != null) {
        _filters!.resetReleaseFilters(notify: false);
      }
    }
  }

  @override
  void didUpdateWidget(ProductOverviewTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.release?.name != widget.release?.name ||
        oldWidget.releaseName != widget.releaseName) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _filters?.resetReleaseFilters();
      });
      _release = widget.release;
      if (_release == null && widget.releaseName != null) {
        _loadReleaseByName();
      }
    }
  }

  @override
  void dispose() {
    if (_release != null || widget.releaseName != null) {
      _filters?.resetReleaseFilters(notify: false);
    }
    super.dispose();
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
                  : ProductReleaseFilterSheet(release: release),
            ],
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(56.h),
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
                child: release != null
                    ? const ProductOverviewReleaseSearchBar()
                    : const ProductOverviewSearchBar(),
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
