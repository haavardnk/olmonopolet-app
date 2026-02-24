import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../providers/auth.dart';
import '../../providers/filter.dart';
import '../../assets/constants.dart';
import '../../utils/date_utils.dart';
import 'filter_section.dart';

class ChipFilter extends StatelessWidget {
  final String title;
  final IconData? icon;
  final String? subtitle;
  final List<String> options;
  final List<bool> selectedList;
  final Function(int, bool) onChanged;
  final StateSetter parentSetState;
  final VoidCallback? onToggleAll;
  final bool useShortLabels;

  const ChipFilter({
    super.key,
    required this.title,
    this.icon,
    this.subtitle,
    required this.options,
    required this.selectedList,
    required this.onChanged,
    required this.parentSetState,
    this.onToggleAll,
    this.useShortLabels = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final hasSelection = selectedList.contains(true);

    return FilterSection(
      title: title,
      icon: icon,
      subtitle: subtitle,
      resetLabel: onToggleAll != null && hasSelection ? 'Nullstill' : null,
      onReset: onToggleAll,
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        children: List.generate(options.length, (i) {
          final isSelected = selectedList[i];
          return GestureDetector(
            onTap: () => parentSetState(() => onChanged(i, !isSelected)),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? colors.primaryContainer
                    : colors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
                border: isSelected
                    ? Border.all(color: colors.primary, width: 1)
                    : null,
              ),
              child: Text(
                options[i],
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                  color: isSelected
                      ? colors.onPrimaryContainer
                      : colors.onSurfaceVariant,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class AllergensFilter extends StatelessWidget {
  final StateSetter parentSetState;

  const AllergensFilter({super.key, required this.parentSetState});

  @override
  Widget build(BuildContext context) {
    final filters = Provider.of<Filter>(context, listen: false);

    return Consumer<Filter>(
      builder: (context, flt, _) => ChipFilter(
        title: 'Ekskluder allergener',
        icon: Icons.no_food_outlined,
        options: excludeAllergensList.map((e) => e.keys.first).toList(),
        selectedList: filters.excludeAllergensSelectedList,
        onChanged: filters.setExcludeAllergensSelection,
        parentSetState: parentSetState,
        onToggleAll: () => parentSetState(() {
          filters.excludeAllergensSelectedList =
              List<bool>.filled(excludeAllergensList.length, false);
          filters.setFilters();
        }),
      ),
    );
  }
}

class ProductSelectionFilter extends StatelessWidget {
  final StateSetter parentSetState;

  const ProductSelectionFilter({super.key, required this.parentSetState});

  @override
  Widget build(BuildContext context) {
    final filters = Provider.of<Filter>(context, listen: false);

    return Consumer<Filter>(
      builder: (context, flt, _) => ChipFilter(
        title: 'Produktutvalg',
        icon: Icons.category_outlined,
        options: productSelectionList.map((e) => e.keys.first).toList(),
        selectedList: filters.productSelectionSelectedList,
        onChanged: filters.setProductSelection,
        parentSetState: parentSetState,
        onToggleAll: () => parentSetState(() {
          filters.productSelectionSelectedList =
              List<bool>.filled(productSelectionList.length, false);
          filters.setFilters();
        }),
      ),
    );
  }
}

class ChristmasBeerFilter extends StatelessWidget {
  final StateSetter parentSetState;

  const ChristmasBeerFilter({super.key, required this.parentSetState});

  @override
  Widget build(BuildContext context) {
    // Only show in November and December (holiday season)
    if (!isHolidaySeason()) {
      return const SizedBox.shrink();
    }

    final filters = Provider.of<Filter>(context, listen: false);
    final colors = Theme.of(context).colorScheme;

    return Consumer<Filter>(
      builder: (context, flt, _) => Padding(
        padding: EdgeInsets.symmetric(vertical: 6.h),
        child: Row(
          children: [
            Text(
              '🎄',
              style: TextStyle(fontSize: 16.sp),
            ),
            SizedBox(width: 6.w),
            Expanded(
              child: Text(
                'Kun juleøl',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: colors.primary,
                ),
              ),
            ),
            Transform.scale(
              scale: 0.8,
              child: Switch(
                value: flt.christmasBeerOnly,
                onChanged: (value) {
                  filters.setChristmasBeerOnly(value);
                  parentSetState(() {});
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MainCategoryFilter extends StatelessWidget {
  final StateSetter parentSetState;

  const MainCategoryFilter({super.key, required this.parentSetState});

  @override
  Widget build(BuildContext context) {
    final filters = Provider.of<Filter>(context, listen: false);

    return Consumer<Filter>(
      builder: (context, flt, _) => ChipFilter(
        title: 'Kategori',
        icon: Icons.local_drink_outlined,
        options: mainCategoryList.map((e) => e.keys.first).toList(),
        selectedList: filters.mainCategorySelectedList,
        onChanged: filters.setMainCategory,
        parentSetState: parentSetState,
        onToggleAll: () => parentSetState(() {
          filters.mainCategorySelectedList =
              List<bool>.filled(mainCategoryList.length, false);
          filters.setFilters();
        }),
      ),
    );
  }
}

class DeliveryFilter extends StatelessWidget {
  final StateSetter parentSetState;

  const DeliveryFilter({super.key, required this.parentSetState});

  @override
  Widget build(BuildContext context) {
    final filters = Provider.of<Filter>(context, listen: false);

    return Consumer<Filter>(
      builder: (context, flt, _) => ChipFilter(
        title: 'Bestilling',
        icon: Icons.local_shipping_outlined,
        subtitle: '(Ikke filtrer på butikklager)',
        options: deliveryList,
        selectedList: filters.deliverySelectedList,
        onChanged: filters.setDeliverySelection,
        parentSetState: parentSetState,
      ),
    );
  }
}

class TastedFilter extends StatelessWidget {
  final StateSetter parentSetState;

  const TastedFilter({super.key, required this.parentSetState});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<Auth>(context);
    if (!auth.isSignedIn) return const SizedBox.shrink();

    final filters = Provider.of<Filter>(context, listen: false);
    final colors = Theme.of(context).colorScheme;

    return Consumer<Filter>(
      builder: (context, flt, _) {
        final value = flt.userTasted;
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 6.h),
          child: Row(
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 18.sp,
                color: colors.primary,
              ),
              SizedBox(width: 6.w),
              Expanded(
                child: Text(
                  'Smakt',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: colors.primary,
                  ),
                ),
              ),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: '', label: Text('Alle')),
                  ButtonSegment(value: 'true', label: Text('Ja')),
                  ButtonSegment(value: 'false', label: Text('Nei')),
                ],
                selected: {value},
                onSelectionChanged: (selected) {
                  filters.setUserTasted(selected.first);
                  parentSetState(() {});
                },
                style: ButtonStyle(
                  visualDensity: VisualDensity.compact,
                  textStyle: WidgetStatePropertyAll(
                    TextStyle(fontSize: 11.sp),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
