import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../models/user_list.dart';
import '../providers/auth.dart';
import '../providers/http_client.dart';
import '../services/api.dart';

Future<Map<String, Product>?> loadProductsForItems(
  BuildContext context,
  List<ListItem> items,
) async {
  if (items.isEmpty) return null;

  final productIds = items.map((i) => i.productId).toSet().toList();
  final idsStr = productIds.join(',');

  final client = Provider.of<HttpClient>(context, listen: false).apiClient;
  final auth = Provider.of<Auth>(context, listen: false);
  final token = auth.isSignedIn ? await auth.getIdToken() : null;
  final products = await ApiHelper.getProductsByIds(
    client,
    idsStr,
    token: token,
  );
  if (products == null) return null;

  final map = <String, Product>{};
  for (final p in products) {
    map[p.id.toString()] = p;
  }
  return map;
}

double calculateListTotal({
  required List<ListItem> items,
  required Map<String, Product> products,
  double? precomputedTotal,
}) {
  if (precomputedTotal != null) return precomputedTotal;
  double total = 0;
  for (final item in items) {
    final product = products[item.productId];
    if (product != null) {
      total += product.price * item.quantity;
    }
  }
  return total;
}
