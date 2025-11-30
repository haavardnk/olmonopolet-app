import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/filter.dart';
import '../../models/store.dart';
import 'filter_section.dart';
import 'multi_select_dropdown.dart';

class StoreFilter extends StatelessWidget {
  final StateSetter parentSetState;

  const StoreFilter({super.key, required this.parentSetState});

  @override
  Widget build(BuildContext context) {
    final filters = Provider.of<Filter>(context, listen: false);

    return Consumer<Filter>(
      builder: (context, flt, _) => FilterSection(
        title: 'Butikklager',
        resetLabel: filters.selectedStores.isNotEmpty ? 'Nullstill' : null,
        onReset: filters.selectedStores.isNotEmpty
            ? () => parentSetState(() {
                  filters.selectedStores = [];
                  filters.setStore();
                })
            : null,
        child: MultiSelectDropdown<Store>(
          items: flt.storeList,
          selectedItems: flt.storeList.where((s) => filters.selectedStores.contains(s.name)).toList(),
          itemLabel: (s) => s.name,
          itemSubtitle: (s) => s.distance != null ? '${s.distance!.toStringAsFixed(0)} km' : null,
          hintText: 'Alle butikker',
          searchHint: 'Søk etter butikk...',
          selectedLabel: (sel) => sel.isEmpty
              ? 'Alle butikker'
              : sel.length == 1
                  ? sel.first.name
                  : '${sel.length} butikker valgt',
          asyncItems: () async {
            if (flt.storeList.isEmpty && !flt.storesLoading) await flt.getStores();
            return flt.storeList;
          },
          onChanged: (sel) => parentSetState(() {
            filters.selectedStores = sel.map((s) => s.name).toList();
            filters.setStore();
          }),
        ),
      ),
    );
  }
}
