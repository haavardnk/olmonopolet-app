import 'package:flutter/material.dart';

import '../../providers/filter.dart';

Future<void> showStockChangeStoreDialog(
    BuildContext context, Filter filters) async {
  if (filters.storeList.isEmpty && !filters.storesLoading) {
    await filters.getStores();
  }

  if (!context.mounted) return;

  await showDialog(
    context: context,
    builder: (dialogContext) {
      return _StoreSelectDialog(
        filters: filters,
        dialogContext: dialogContext,
      );
    },
  );
}

class _StoreSelectDialog extends StatefulWidget {
  final Filter filters;
  final BuildContext dialogContext;

  const _StoreSelectDialog({
    required this.filters,
    required this.dialogContext,
  });

  @override
  State<_StoreSelectDialog> createState() => _StoreSelectDialogState();
}

class _StoreSelectDialogState extends State<_StoreSelectDialog> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredStores = _searchQuery.isEmpty
        ? widget.filters.storeList
        : widget.filters.storeList
            .where((s) => s.name.toLowerCase().contains(_searchQuery))
            .toList();

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 400,
          maxHeight: 550,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Søk etter butikk...',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                  });
                },
              ),
            ),
            Divider(
              height: 1,
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
            Flexible(
              child: filteredStores.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Text(
                          'Ingen butikker funnet',
                          style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      itemCount: filteredStores.length,
                      itemBuilder: (context, index) {
                        final store = filteredStores[index];
                        final isSelected =
                            widget.filters.stockChangeSelectedStore ==
                                store.name;
                        return ListTile(
                          dense: true,
                          title: Text(store.name),
                          subtitle: store.distance != null
                              ? Text(
                                  '${store.distance!.toStringAsFixed(0)} km')
                              : null,
                          trailing: isSelected
                              ? Icon(
                                  Icons.check_circle,
                                  color:
                                      Theme.of(context).colorScheme.primary,
                                )
                              : null,
                          onTap: () {
                            widget.filters.stockChangeSelectedStore =
                                store.name;
                            widget.filters.setStore(stock: true);
                            Navigator.pop(widget.dialogContext);
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
