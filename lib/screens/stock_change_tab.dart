import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/drawer/app_drawer.dart';
import '../widgets/stock_change/stock_change_list.dart';
import '../widgets/stock_change/stock_change_store_select.dart';
import '../providers/filter.dart';

class StockChangeTab extends StatefulWidget {
  const StockChangeTab({super.key});

  @override
  State<StockChangeTab> createState() => _StockChangeTabState();
}

class _StockChangeTabState extends State<StockChangeTab> {
  @override
  Widget build(BuildContext context) {
    late Filter filters = Provider.of<Filter>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        title: Consumer<Filter>(
          builder: (context, filter, _) => FittedBox(
            fit: BoxFit.contain,
            child: Text(filters.stockChangeStoreId.isNotEmpty
                ? filter.stockChangeSelectedStore
                : 'Lagerendringer'),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              showStockChangeStoreDialog(context, filters);
            },
            icon: const Icon(
              Icons.store,
              semanticLabel: "Velg butikk",
            ),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: Consumer<Filter>(
        builder: (context, _, __) {
          return filters.stockChangeStoreId.isNotEmpty
              ? const StockChangeList()
              : Center(
                  child: FilledButton.tonalIcon(
                    label: const Text('Velg butikk'),
                    icon: const Icon(Icons.store),
                    onPressed: () {
                      showStockChangeStoreDialog(context, filters);
                    },
                  ),
                );
        },
      ),
    );
  }
}
