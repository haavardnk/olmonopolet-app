import 'package:flutter/material.dart';

import '../widgets/app_drawer.dart';
import '../widgets/products/product_list_view.dart';

class ProductOverviewScreen extends StatelessWidget {
  const ProductOverviewScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ProductListView();
  }
}
