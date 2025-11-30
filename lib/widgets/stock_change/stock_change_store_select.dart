import 'package:flutter/material.dart';

import '../../providers/filter.dart';

Future<void> showStockChangeStoreDialog(
    BuildContext context, Filter filters) async {
  TextEditingController? searchController;
  String searchQuery = '';

  if (filters.storeList.isEmpty && !filters.storesLoading) {
    await filters.getStores();
  }

  if (!context.mounted) return;

  await showDialog(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          searchController ??= TextEditingController();

          final filteredStores = searchQuery.isEmpty
              ? filters.storeList
              : filters.storeList
                  .where((s) => s.name.toLowerCase().contains(searchQuery))
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
                  // Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                    child: TextField(
                      controller: searchController,
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
                        searchQuery = value.toLowerCase();
                        setDialogState(() {});
                      },
                    ),
                  ),
                  Divider(
                    height: 1,
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                  // List
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
                                  filters.stockChangeSelectedStore ==
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
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      )
                                    : null,
                                onTap: () {
                                  filters.stockChangeSelectedStore = store.name;
                                  filters.setStore(stock: true);
                                  Navigator.pop(dialogContext);
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
  searchController?.dispose();
}
