import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flag/flag.dart';

import '../../providers/filter.dart';
import '../../models/country.dart';
import 'filter_section.dart';
import 'multi_select_dropdown.dart';

class CountryFilter extends StatelessWidget {
  final StateSetter parentSetState;

  const CountryFilter({super.key, required this.parentSetState});

  @override
  Widget build(BuildContext context) {
    final filters = Provider.of<Filter>(context, listen: false);
    final colors = Theme.of(context).colorScheme;

    return Consumer<Filter>(
      builder: (context, flt, _) => FilterSection(
        title: 'Land',
        icon: Icons.public,
        resetLabel: filters.selectedCountries.isNotEmpty ? 'Nullstill' : null,
        onReset: filters.selectedCountries.isNotEmpty
            ? () => parentSetState(() {
                  filters.selectedCountries = [];
                  filters.setCountry();
                })
            : null,
        child: MultiSelectDropdown<Country>(
          items: flt.countryList,
          selectedItems: filters.selectedCountries
              .map((name) => flt.countryList.firstWhere((c) => c.name == name,
                  orElse: () => Country(name: name)))
              .toList(),
          itemLabel: (c) => c.name,
          itemLeading: (c) => c.isoCode?.isNotEmpty == true
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: Flag.fromString(c.isoCode!, height: 18, width: 24),
                )
              : const SizedBox(width: 24),
          hintText: 'Alle land',
          searchHint: 'Søk etter land...',
          selectedLabel: (sel) => sel.isEmpty
              ? 'Alle land'
              : sel.length == 1
                  ? sel.first.name
                  : '${sel.length} land valgt',
          selectedDisplayBuilder: (context, sel) {
            if (sel.isEmpty || sel.length > 1) return null;
            final item = sel.first;
            return Row(
              children: [
                if (item.isoCode?.isNotEmpty == true)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child:
                          Flag.fromString(item.isoCode!, height: 14, width: 20),
                    ),
                  ),
                Flexible(
                  child: Text(
                    item.name,
                    style: TextStyle(fontSize: 13, color: colors.onSurface),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            );
          },
          asyncItems: () async {
            if (flt.countryList.isEmpty && !flt.countriesLoading)
              await flt.getCountries();
            return flt.countryList;
          },
          onChanged: (sel) => parentSetState(() {
            filters.selectedCountries = sel.map((c) => c.name).toList();
            filters.setCountry();
          }),
        ),
      ),
    );
  }
}
