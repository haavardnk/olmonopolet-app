import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/filter.dart';
import '../../assets/constants.dart';
import 'filter_section.dart';

class ChipFilter extends StatelessWidget {
  final String title;
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
                color: isSelected ? colors.primaryContainer : colors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
                border: isSelected ? Border.all(color: colors.primary, width: 1) : null,
              ),
              child: Text(
                options[i],
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                  color: isSelected ? colors.onPrimaryContainer : colors.onSurfaceVariant,
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
        options: excludeAllergensList.map((e) => e.keys.first).toList(),
        selectedList: filters.excludeAllergensSelectedList,
        onChanged: filters.setExcludeAllergensSelection,
        parentSetState: parentSetState,
        onToggleAll: () => parentSetState(() {
          filters.excludeAllergensSelectedList = List<bool>.filled(excludeAllergensList.length, false);
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
        options: productSelectionList.map((e) => e.keys.first).toList(),
        selectedList: filters.productSelectionSelectedList,
        onChanged: filters.setProductSelection,
        parentSetState: parentSetState,
        onToggleAll: () => parentSetState(() {
          filters.productSelectionSelectedList = List<bool>.filled(productSelectionList.length, false);
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
        subtitle: '(Ikke filtrer på butikklager)',
        options: deliveryList,
        selectedList: filters.deliverySelectedList,
        onChanged: filters.setDeliverySelection,
        parentSetState: parentSetState,
      ),
    );
  }
}
