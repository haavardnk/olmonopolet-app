import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/filter.dart';

String? lookupStoreName(BuildContext context, String? storeId) {
  if (storeId == null || storeId.isEmpty) return null;
  final filters = Provider.of<Filter>(context, listen: false);
  for (final store in filters.storeList) {
    if (store.id == storeId) return store.name;
  }
  return null;
}
