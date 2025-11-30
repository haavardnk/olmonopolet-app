import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/filter.dart';
import 'filter_section.dart';
import 'multi_select_dropdown.dart';

class ReleaseFilter extends StatelessWidget {
  final StateSetter parentSetState;

  const ReleaseFilter({super.key, required this.parentSetState});

  @override
  Widget build(BuildContext context) {
    final filters = Provider.of<Filter>(context, listen: false);

    return Consumer<Filter>(
      builder: (context, flt, _) {
        final selectedReleases = filters.releaseSelectedList
            .asMap()
            .entries
            .where((e) => e.value && e.key < filters.releaseNameList.length)
            .map((e) => filters.releaseNameList[e.key])
            .toList();

        return FilterSection(
          title: 'Nyhetslansering',
          resetLabel: selectedReleases.isNotEmpty ? 'Nullstill' : null,
          onReset: selectedReleases.isNotEmpty
              ? () => parentSetState(() {
                    filters.releaseSelectedList = List<bool>.filled(filters.releaseNameList.length, false);
                    filters.release = '';
                    filters.setFilters();
                  })
              : null,
          child: MultiSelectDropdown<String>(
            items: flt.releaseNameList,
            selectedItems: selectedReleases,
            itemLabel: (item) => item,
            hintText: 'Alle lanseringer',
            searchHint: 'Søk etter lansering...',
            selectedLabel: (sel) => sel.isEmpty
                ? 'Alle lanseringer'
                : sel.length == 1
                    ? sel.first
                    : '${sel.length} lanseringer valgt',
            asyncItems: () async {
              if (flt.releaseNameList.isEmpty) await flt.getReleaseNames();
              return flt.releaseNameList;
            },
            onChanged: (sel) => parentSetState(() {
              filters.releaseSelectedList = flt.releaseNameList.map((name) => sel.contains(name)).toList();
              filters.release = sel.join(',');
              filters.setFilters();
            }),
          ),
        );
      },
    );
  }
}
