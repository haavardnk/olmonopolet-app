import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../providers/filter.dart';
import 'store_filter.dart';
import 'range_filters.dart';
import 'sort_filter.dart';
import 'style_filter.dart';
import 'country_filter.dart';
import 'release_filter.dart';
import 'chip_filters.dart';
import 'filter_settings_dialog.dart';

class ProductFilterSheet extends StatelessWidget {
  const ProductFilterSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => _showFilterSheet(context),
      icon: const Icon(Icons.tune, semanticLabel: "Filter"),
    );
  }

  void _showFilterSheet(BuildContext context) {
    final filters = Provider.of<Filter>(context, listen: false);

    showModalBottomSheet<void>(
      isScrollControlled: true,
      context: context,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      builder: (_) => GestureDetector(
        onTap: () => Navigator.pop(context),
        behavior: HitTestBehavior.opaque,
        child: GestureDetector(
          onTap: () {},
          child: DraggableScrollableSheet(
            initialChildSize: 0.7,
            minChildSize: 0.4,
            maxChildSize: 0.9,
            builder: (context, scrollController) => Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
              ),
              child: _FilterSheetContent(scrollController: scrollController),
            ),
          ),
        ),
      ),
    ).whenComplete(() => filters.setFilters());
  }
}

class _FilterSheetContent extends StatefulWidget {
  final ScrollController scrollController;

  const _FilterSheetContent({required this.scrollController});

  @override
  State<_FilterSheetContent> createState() => _FilterSheetContentState();
}

class _FilterSheetContentState extends State<_FilterSheetContent> {
  @override
  Widget build(BuildContext context) {
    final filters = Provider.of<Filter>(context, listen: false);
    final colors = Theme.of(context).colorScheme;
    final orientation = MediaQuery.of(context).orientation;
    final isWide = 1.sw > 600 && orientation == Orientation.landscape;

    return Column(
      children: [
        _buildHandle(colors),
        _buildHeader(context, filters, colors),
        Divider(height: 1, color: colors.outlineVariant),
        Expanded(
          child: ListView(
            controller: widget.scrollController,
            padding: isWide
                ? EdgeInsets.symmetric(vertical: 8.h, horizontal: 0.15.sw)
                : EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
            children: [
              SortFilter(parentSetState: setState),
              StoreFilter(parentSetState: setState),
              const Divider(height: 16),
              PriceRangeFilter(parentSetState: setState),
              AlcoholRangeFilter(parentSetState: setState),
              const Divider(height: 16),
              StyleFilter(parentSetState: setState),
              CountryFilter(parentSetState: setState),
              ReleaseFilter(parentSetState: setState),
              const Divider(height: 16),
              ProductSelectionFilter(parentSetState: setState),
              AllergensFilter(parentSetState: setState),
              DeliveryFilter(parentSetState: setState),
              SizedBox(height: 8.h),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHandle(ColorScheme colors) {
    return Center(
      child: Container(
        margin: EdgeInsets.only(top: 12.h, bottom: 8.h),
        width: 36,
        height: 4,
        decoration: BoxDecoration(
          color: colors.onSurfaceVariant.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Filter filters, ColorScheme colors) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton.icon(
            onPressed: () => FilterSettingsDialog.show(context),
            icon: const Icon(Icons.settings_outlined, size: 20),
            label: const Text('Innstillinger'),
            style: TextButton.styleFrom(foregroundColor: colors.onSurfaceVariant),
          ),
          Row(
            children: [
              TextButton(
                onPressed: () {
                  filters.resetFilters();
                  setState(() {});
                  Navigator.pop(context);
                },
                child: const Text('Nullstill alle'),
              ),
              const SizedBox(width: 8),
              FilledButton.tonal(
                onPressed: () => Navigator.pop(context),
                child: const Text('Bruk'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
