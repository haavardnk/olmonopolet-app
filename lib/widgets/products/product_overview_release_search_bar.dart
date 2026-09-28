import 'package:material_ui/material_ui.dart';

import './product_overview_search_bar.dart';

class ProductOverviewReleaseSearchBar extends StatelessWidget {
  const ProductOverviewReleaseSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProductOverviewSearchBar(isRelease: true);
  }
}
