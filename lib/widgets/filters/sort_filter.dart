import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/filter.dart';
import '../../assets/constants.dart';
import 'filter_section.dart';
import 'multi_select_dropdown.dart';

class SortFilter extends StatelessWidget {
  final StateSetter parentSetState;

  const SortFilter({super.key, required this.parentSetState});

  @override
  Widget build(BuildContext context) {
    final filters = Provider.of<Filter>(context, listen: false);

    return FilterSection(
      title: 'Sortering',
      icon: Icons.sort,
      child: SingleSelectDropdown<String>(
        items: sortList.keys.toList(),
        selectedItem: filters.sortIndex,
        itemLabel: (item) => item,
        hintText: 'Velg sortering',
        onChanged: (x) {
          if (x != null) {
            parentSetState(() {
              filters.sortIndex = x;
              filters.setSortBy(x);
            });
          }
        },
      ),
    );
  }
}
