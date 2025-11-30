import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/filter.dart';

class FilterSettingsDialog extends StatelessWidget {
  const FilterSettingsDialog({super.key});

  static Future<void> show(BuildContext context) =>
      showDialog(context: context, builder: (_) => const FilterSettingsDialog());

  @override
  Widget build(BuildContext context) {
    final filters = Provider.of<Filter>(context, listen: false);
    final colors = Theme.of(context).colorScheme;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Husk filter', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  Consumer<Filter>(
                    builder: (context, flt, _) {
                      final allSelected = flt.filterSaveSettings.every((e) => e['save'] == true);
                      return TextButton(
                        onPressed: () {
                          for (var e in flt.filterSaveSettings) {
                            e['save'] = !allSelected;
                          }
                          flt.saveFilterSettings();
                        },
                        child: Text(allSelected ? 'Nullstill' : 'Velg alle'),
                      );
                    },
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: colors.outlineVariant),
            Flexible(
              child: Consumer<Filter>(
                builder: (context, flt, _) => ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  itemCount: flt.filterSaveSettings.length,
                  itemBuilder: (context, i) {
                    final setting = flt.filterSaveSettings[i];
                    return ListTile(
                      dense: true,
                      title: Text(setting['text']),
                      trailing: setting['save']
                          ? Icon(Icons.check_circle, color: colors.primary)
                          : null,
                      onTap: () {
                        setting['save'] = !setting['save'];
                        flt.saveFilterSettings();
                      },
                    );
                  },
                ),
              ),
            ),
            Divider(height: 1, color: colors.outlineVariant),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(
                children: [
                  const Spacer(),
                  FilledButton(
                    onPressed: () {
                      filters.saveFilters();
                      Navigator.pop(context);
                    },
                    child: const Text('Ferdig'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
