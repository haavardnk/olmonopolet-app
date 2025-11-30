import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../providers/cart.dart';
import '../widgets/cart/cart_element.dart';
import '../widgets/cart/cart_bottom_store_sheet.dart';
import '../widgets/drawer/app_drawer.dart';

class CartTab extends StatelessWidget {
  const CartTab({super.key});

  @override
  Widget build(BuildContext context) {
    final cartData = Provider.of<Cart>(context);
    final shortestSide = 1.sw < 1.sh ? 1.sw : 1.sh;
    final tabletMode = 1.sw >= 600;
    final double boxImageSize = tabletMode ? 110.r : shortestSide / 4;

    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        title: const FittedBox(
          fit: BoxFit.contain,
          child: Text(
            'Handleliste',
          ),
        ),
        actions: const [
          CartBottomStoreSheet(),
        ],
      ),
      drawer: const AppDrawer(),
      body: SizedBox(
        height: 1.sh,
        child: Column(
          children: [
            Expanded(
              child: cartData.itemCount > 0
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        Column(
                          children: List.generate(
                            cartData.itemCount,
                            (index) {
                              return Column(
                                children: [
                                  if (index != 0)
                                    const Divider(
                                      height: 1,
                                    ),
                                  CartElement(
                                    index,
                                    boxImageSize,
                                    cartData.items.values.elementAt(index),
                                    cartData,
                                  ),
                                  if (index == cartData.itemCount - 1 &&
                                      cartData.hideNoStock &&
                                      cartData.cartStoreId.isNotEmpty &&
                                      (cartData.itemsInStock.length !=
                                          cartData.itemCount))
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Center(
                                        child: Text(
                                            '${cartData.itemCount - cartData.itemsInStock.length} skjulte produkter'),
                                      ),
                                    )
                                ],
                              );
                            },
                          ),
                        ),
                      ],
                    )
                  : const Center(
                      child: Text('Handelisten er tom'),
                    ),
            ),
            Container(
              padding: const EdgeInsets.all(12),
              color: Theme.of(context).colorScheme.surface,
              child: Column(
                children: [
                  _createTotalPrice(cartData),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _createTotalPrice(Cart cartData) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Totalt',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            Text(
              'Kr ${cartData.totalAmount.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        FilledButton.tonalIcon(
          onPressed: () {
            cartData.clear();
          },
          label: const Text('Tøm'),
          icon: const Icon(Icons.delete_sweep_outlined),
        )
      ],
    );
  }
}
