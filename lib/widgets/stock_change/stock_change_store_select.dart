import 'package:flutter/material.dart';

import '../../providers/filter.dart';
import '../common/store_picker.dart';

Future<void> showStockChangeStoreDialog(
    BuildContext context, Filter filters) async {
  if (filters.storeList.isEmpty && !filters.storesLoading) {
    await filters.getStores();
  }

  if (!context.mounted) return;

  final selected = await showStorePicker(
    context,
    stores: filters.storeList,
    selectedStoreId: filters.storeList
        .where((s) => s.name == filters.stockChangeSelectedStore)
        .map((s) => s.id)
        .firstOrNull,
  );

  if (selected != null) {
    filters.stockChangeSelectedStore = selected.name;
    filters.setStore(stock: true);
  }
}
