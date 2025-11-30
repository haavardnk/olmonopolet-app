import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_fadein/flutter_fadein.dart';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';

import '../../providers/cart.dart';
import '../../providers/filter.dart';
import '../../providers/http_client.dart';
import '../../services/api.dart';
import '../../models/product.dart';
import '../common/rating_widget.dart';
import '../common/info_chips.dart';
import '../../screens/product_detail_screen.dart';

class CartElement extends StatefulWidget {
  final int index;
  final double boxImageSize;
  final CartItem cartItem;
  final Cart cartData;

  const CartElement(this.index, this.boxImageSize, this.cartItem, this.cartData,
      {super.key});

  @override
  CartElementState createState() => CartElementState();
}

class CartElementState extends State<CartElement> {
  List<StockInfo> _stockList = [];

  @override
  Widget build(BuildContext context) {
    final heroTag = 'cart${widget.cartItem.product.id}';
    final double imageSize = 85.r;
    int quantity = widget.cartItem.quantity;

    return !widget.cartItem.inStock &&
            widget.cartData.hideNoStock &&
            widget.cartData.cartStoreId.isNotEmpty
        ? const Wrap()
        : Dismissible(
            key: Key(widget.cartItem.product.id.toString()),
            direction: DismissDirection.startToEnd,
            confirmDismiss: (direction) async {
              final countBefore = widget.cartData.itemCount;
              await showPopupDelete(widget.index, widget.boxImageSize,
                  widget.cartItem, widget.cartData, context);
              final countAfter = widget.cartData.itemCount;
              if (countBefore == countAfter) {
                return false;
              } else {
                return true;
              }
            },
            background: Container(
              color: Colors.pink,
              padding: EdgeInsets.only(left: 50.w),
              child: const Row(
                children: <Widget>[
                  Icon(
                    Icons.delete,
                  )
                ],
              ),
            ),
            child: Semantics(
              label: widget.cartItem.product.name,
              button: true,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  pushScreen(
                    context,
                    settings: RouteSettings(
                      name: ProductDetailScreen.routeName,
                      arguments: <String, dynamic>{
                        'product': widget.cartItem.product,
                        'herotag': heroTag
                      },
                    ),
                    screen: const ProductDetailScreen(),
                    pageTransitionAnimation: PageTransitionAnimation.cupertino,
                    withNavBar: true,
                  );
                },
                child: Container(
                  height: imageSize + 42.h,
                  child: Opacity(
                    opacity: !widget.cartItem.inStock &&
                            widget.cartData.greyNoStock &&
                            widget.cartData.cartStoreId.isNotEmpty
                        ? 0.3
                        : 1,
                    child: Container(
                      padding: EdgeInsets.fromLTRB(16.w, 6.h, 16.w, 6.h),
                      child: Stack(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.cartItem.product.name,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 6.h),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(8.r),
                                        child: Hero(
                                          tag: heroTag,
                                          child: widget.cartItem.product
                                                      .imageUrl !=
                                                  null
                                              ? FancyShimmerImage(
                                                  imageUrl: widget.cartItem
                                                      .product.imageUrl!,
                                                  height: imageSize,
                                                  width: imageSize,
                                                  boxFit: BoxFit.cover,
                                                  errorWidget: Image.asset(
                                                    'assets/images/placeholder.png',
                                                    height: imageSize,
                                                    width: imageSize,
                                                    fit: BoxFit.cover,
                                                  ),
                                                )
                                              : Image.asset(
                                                  'assets/images/placeholder.png',
                                                  height: imageSize,
                                                  width: imageSize,
                                                  fit: BoxFit.cover,
                                                ),
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 0,
                                        right: 0,
                                        child: _buildStoreButton(context),
                                      ),
                                    ],
                                  ),
                                  SizedBox(width: 12.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              'Kr ${widget.cartItem.product.price.toStringAsFixed(2)}',
                                              style: TextStyle(
                                                fontSize: 15.sp,
                                                fontWeight: FontWeight.bold,
                                                height: 1.0,
                                              ),
                                            ),
                                            if (widget.cartItem.product
                                                    .pricePerVolume !=
                                                null) ...[
                                              SizedBox(width: 6.w),
                                              Text(
                                                '·',
                                                style: TextStyle(
                                                  fontSize: 13.sp,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onSurfaceVariant,
                                                ),
                                              ),
                                              SizedBox(width: 6.w),
                                              Text(
                                                '${widget.cartItem.product.pricePerVolume!.toStringAsFixed(0)} kr/l',
                                                style: TextStyle(
                                                  fontSize: 11.sp,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onSurfaceVariant,
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                        SizedBox(height: 4.h),
                                        Text(
                                          widget.cartItem.product.style,
                                          style: TextStyle(
                                            fontSize: 12.sp,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurfaceVariant,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        SizedBox(height: 4.h),
                                        Row(
                                          children: [
                                            createRatingBar(
                                              rating: widget.cartItem.product
                                                      .rating ??
                                                  0,
                                              size: 16.r,
                                              color: Colors.amber,
                                            ),
                                            SizedBox(width: 4.w),
                                            Text(
                                              widget.cartItem.product.rating
                                                      ?.toStringAsFixed(1) ??
                                                  '-',
                                              style: TextStyle(
                                                fontSize: 12.sp,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            if (widget.cartItem.product
                                                    .checkins !=
                                                null) ...[
                                              SizedBox(width: 4.w),
                                              Text(
                                                '(${NumberFormat.compact().format(widget.cartItem.product.checkins)})',
                                                style: TextStyle(
                                                  fontSize: 11.sp,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onSurfaceVariant,
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                        SizedBox(height: 6.h),
                                        Wrap(
                                          spacing: 6.w,
                                          runSpacing: 4.h,
                                          crossAxisAlignment:
                                              WrapCrossAlignment.center,
                                          children: [
                                            buildInfoChip(
                                              '${widget.cartItem.product.volume}L',
                                              context,
                                              icon: Icons.water_drop_outlined,
                                            ),
                                            if (widget.cartItem.product.abv !=
                                                null)
                                              buildInfoChip(
                                                '${widget.cartItem.product.abv!.toStringAsFixed(1)}%',
                                                context,
                                                icon: Icons.percent,
                                              ),
                                            if (widget.cartItem.product
                                                        .country !=
                                                    null &&
                                                widget.cartItem.product.country!
                                                    .isNotEmpty)
                                              buildInfoChipWithFlag(
                                                widget
                                                    .cartItem.product.country!,
                                                widget.cartItem.product
                                                    .countryCode,
                                                context,
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Positioned(
                            bottom: 4.h,
                            right: 0,
                            child: _buildQuantityControl(context, quantity),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
  }

  List<StockInfo> _sortStockList(List<StockInfo> stockList, List storeList) {
    final storeNames = storeList.map((e) => e.name).toList();
    Map<String, int> order = {
      for (var key in storeNames) key: storeNames.indexOf(key)
    };
    final filteredList =
        stockList.where((s) => order.containsKey(s.storeName)).toList();
    filteredList
        .sort((a, b) => order[a.storeName]!.compareTo(order[b.storeName]!));
    return filteredList;
  }

  Widget _buildQuantityControl(BuildContext context, int quantity) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
              widget.cartData.removeSingleItem(widget.cartItem.product.id);
            },
            child: Padding(
              padding: EdgeInsets.all(6.r),
              child: Icon(Icons.remove, size: 16.r),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 6.w),
            child: Text(
              '$quantity',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              widget.cartData
                  .addItem(widget.cartItem.product.id, widget.cartItem.product);
            },
            child: Padding(
              padding: EdgeInsets.all(6.r),
              child: Icon(Icons.add, size: 16.r),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoreButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _showStockModal(context);
      },
      child: Container(
        padding: EdgeInsets.all(5.r),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.6),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(8.r),
            bottomRight: Radius.circular(8.r),
          ),
        ),
        child: Icon(
          Icons.store_outlined,
          size: 18.r,
          color: Colors.white,
        ),
      ),
    );
  }

  void _showStockModal(BuildContext context) {
    final filters = Provider.of<Filter>(context, listen: false);
    final client = Provider.of<HttpClient>(context, listen: false).apiClient;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      builder: (context) => GestureDetector(
        onTap: () => Navigator.pop(context),
        behavior: HitTestBehavior.opaque,
        child: GestureDetector(
          onTap: () {},
          child: DraggableScrollableSheet(
            initialChildSize: 0.4,
            minChildSize: 0.2,
            maxChildSize: 0.8,
            builder: (context, scrollController) => Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
              ),
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 12.h),
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurfaceVariant
                          .withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(16.r),
                    child: Row(
                      children: [
                        Icon(Icons.store_outlined, size: 20.r),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Lagerstatus',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                widget.cartItem.product.name,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Icon(
                            Icons.close,
                            size: 24.r,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(
                      height: 1,
                      color: Theme.of(context).colorScheme.outlineVariant),
                  Expanded(
                    child: FutureBuilder<List<StockInfo>>(
                      future: ApiHelper.getProductStock(
                          client, widget.cartItem.product.id),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                            child: SizedBox(
                              width: 24.r,
                              height: 24.r,
                              child: const CircularProgressIndicator(
                                  strokeWidth: 2),
                            ),
                          );
                        }

                        if (snapshot.hasData &&
                            snapshot.data!.isNotEmpty &&
                            filters.storeList.isNotEmpty) {
                          _stockList =
                              _sortStockList(snapshot.data!, filters.storeList);
                        }

                        if (_stockList.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.inventory_2_outlined,
                                  size: 48.r,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                                SizedBox(height: 12.h),
                                Text(
                                  'Ikke på lager i dine butikker',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return ListView.separated(
                          controller: scrollController,
                          padding: EdgeInsets.all(16.r),
                          itemCount: _stockList.length,
                          separatorBuilder: (_, __) => SizedBox(height: 8.h),
                          itemBuilder: (context, index) {
                            final stock = _stockList[index];
                            return FadeIn(
                              duration:
                                  Duration(milliseconds: 150 + (index * 30)),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 14.w, vertical: 12.h),
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.location_on_outlined,
                                      size: 18.r,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                                    SizedBox(width: 10.w),
                                    Expanded(
                                      child: Text(
                                        stock.storeName,
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 10.w, vertical: 4.h),
                                      decoration: BoxDecoration(
                                        color: stock.quantity > 5
                                            ? Colors.green
                                                .withValues(alpha: 0.15)
                                            : stock.quantity > 0
                                                ? Colors.orange
                                                    .withValues(alpha: 0.15)
                                                : Colors.red
                                                    .withValues(alpha: 0.15),
                                        borderRadius:
                                            BorderRadius.circular(12.r),
                                      ),
                                      child: Text(
                                        '${stock.quantity} stk',
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.w600,
                                          color: stock.quantity > 5
                                              ? Colors.green.shade700
                                              : stock.quantity > 0
                                                  ? Colors.orange.shade700
                                                  : Colors.red.shade700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> showPopupDelete(int index, double boxImageSize, CartItem cartItem,
    Cart cartData, BuildContext context) async {
  Widget cancelButton = FilledButton.tonal(
    onPressed: () {
      Navigator.of(context, rootNavigator: true).pop();
    },
    child: const Text('Nei'),
  );
  Widget continueButton = FilledButton.tonal(
    onPressed: () {
      cartData.removeItem(cartItem.product.id);
      Navigator.of(context, rootNavigator: true).pop();
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(bottom: 80.0),
          content: Text(
            'Produktet har blitt fjernet fra handlelisten din.',
            textAlign: TextAlign.center,
          ),
          duration: Duration(seconds: 2),
        ),
      );
    },
    child: const Text('Ja'),
  );

  AlertDialog alert = AlertDialog(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
    title: const Text(
      'Fjern fra handleliste',
      style: TextStyle(fontSize: 18),
    ),
    content: const Text(
      'Er du sikker på at du vil fjerne dette produktet fra handlelisten?',
      style: TextStyle(
        fontSize: 13,
      ),
    ),
    actions: [
      cancelButton,
      continueButton,
    ],
  );

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}
