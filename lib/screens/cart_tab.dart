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
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
              ),
              child: Column(
                children: [
                  _buildStatsRow(context, cartData),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context, Cart cartData) {
    final visibleItems = _getVisibleItems(cartData);
    final avgPricePerLiter = _calculateAvgPricePerLiter(visibleItems);
    final avgRating = _calculateAvgRating(visibleItems);
    final totalVolume = _calculateTotalVolume(visibleItems);
    final visibleTotal = visibleItems.fold<double>(
      0,
      (sum, item) => sum + (item.product.price * item.quantity),
    );

    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Kr ${visibleTotal.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (visibleItems.length != cartData.itemCount)
              Text(
                '${visibleItems.length} av ${cartData.itemCount} produkter',
                style: TextStyle(
                  fontSize: 10.sp,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Wrap(
            spacing: 6.w,
            runSpacing: 4.h,
            alignment: WrapAlignment.end,
            children: [
              _buildMiniChip(context, Icons.water_drop_outlined,
                  '${totalVolume.toStringAsFixed(1)}L'),
              _buildMiniChip(
                  context,
                  Icons.attach_money,
                  avgPricePerLiter != null
                      ? '${avgPricePerLiter.toStringAsFixed(0)}/l'
                      : '-'),
              _buildMiniChip(context, Icons.star_outline,
                  avgRating != null ? avgRating.toStringAsFixed(2) : '-'),
            ],
          ),
        ),
        SizedBox(width: 8.w),
        IconButton(
          onPressed: () => cartData.clear(),
          icon: Icon(Icons.delete_sweep_outlined, size: 24.r),
          tooltip: 'Tøm handleliste',
          padding: EdgeInsets.all(10.r),
          constraints: const BoxConstraints(),
          style: IconButton.styleFrom(
            backgroundColor:
                Theme.of(context).colorScheme.surfaceContainerHighest,
            foregroundColor: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildMiniChip(BuildContext context, IconData icon, String value) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.r, color: Theme.of(context).colorScheme.primary),
          SizedBox(width: 3.w),
          Text(
            value,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  List<CartItem> _getVisibleItems(Cart cartData) {
    if (cartData.hideNoStock && cartData.cartStoreId.isNotEmpty) {
      return cartData.items.values.where((item) => item.inStock).toList();
    }
    return cartData.items.values.toList();
  }

  double? _calculateAvgPricePerLiter(List<CartItem> items) {
    if (items.isEmpty) return null;
    final itemsWithPrice =
        items.where((i) => i.product.pricePerVolume != null).toList();
    if (itemsWithPrice.isEmpty) return null;

    double totalPricePerLiter = 0;
    int totalQuantity = 0;
    for (var item in itemsWithPrice) {
      totalPricePerLiter += item.product.pricePerVolume! * item.quantity;
      totalQuantity += item.quantity;
    }
    return totalPricePerLiter / totalQuantity;
  }

  double? _calculateAvgRating(List<CartItem> items) {
    if (items.isEmpty) return null;
    final itemsWithRating =
        items.where((i) => i.product.rating != null).toList();
    if (itemsWithRating.isEmpty) return null;

    double totalRating = 0;
    int totalQuantity = 0;
    for (var item in itemsWithRating) {
      totalRating += item.product.rating! * item.quantity;
      totalQuantity += item.quantity;
    }
    return totalRating / totalQuantity;
  }

  double _calculateTotalVolume(List<CartItem> items) {
    return items.fold<double>(
      0,
      (sum, item) => sum + (item.product.volume * item.quantity),
    );
  }
}
