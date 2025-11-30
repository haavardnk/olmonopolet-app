import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_fadein/flutter_fadein.dart';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flag/flag.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';

import '../../providers/cart.dart';
import '../../providers/filter.dart';
import '../../providers/http_client.dart';
import '../../services/api.dart';
import '../../models/product.dart';
import '../common/rating_widget.dart';
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
  bool _expanded = false;

  List<StockInfo> _stockList = [];
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

  @override
  Widget build(BuildContext context) {
    final filters = Provider.of<Filter>(context, listen: false);
    final client = Provider.of<HttpClient>(context, listen: false).apiClient;
    final heroTag = 'cart${widget.cartItem.product.id}';
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
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.fastOutSlowIn,
                  height: _expanded == true
                      ? widget.boxImageSize + 120.r
                      : widget.boxImageSize + 24,
                  child: Stack(
                    children: [
                      Column(
                        children: [
                          Opacity(
                            opacity: !widget.cartItem.inStock &&
                                    widget.cartData.greyNoStock &&
                                    widget.cartData.cartStoreId.isNotEmpty
                                ? 0.3
                                : 1,
                            child: Container(
                              padding: EdgeInsets.all(12.r),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  ClipRRect(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(6.r)),
                                    child: Stack(
                                      children: [
                                        Hero(
                                          tag: heroTag,
                                          child: widget.cartItem.product
                                                      .imageUrl !=
                                                  null
                                              ? FancyShimmerImage(
                                                  imageUrl: widget.cartItem
                                                      .product.imageUrl!,
                                                  height: widget.boxImageSize,
                                                  width: widget.boxImageSize,
                                                  errorWidget: Image.asset(
                                                    'assets/images/placeholder.png',
                                                    height: widget.boxImageSize,
                                                    width: widget.boxImageSize,
                                                  ),
                                                )
                                              : Image.asset(
                                                  'assets/images/placeholder.png',
                                                  height: widget.boxImageSize,
                                                  width: widget.boxImageSize,
                                                ),
                                        ),
                                        if (widget.cartItem.product
                                                    .countryCode !=
                                                null &&
                                            widget.cartItem.product.countryCode!
                                                .isNotEmpty)
                                          ClipRRect(
                                            borderRadius: BorderRadius.only(
                                                bottomRight:
                                                    Radius.circular(6.r)),
                                            child: Flag.fromString(
                                              widget.cartItem.product
                                                  .countryCode!,
                                              height: 20.r,
                                              width: 20.r * 4 / 3,
                                            ),
                                          )
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10.w,
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          widget.cartItem.product.name,
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Container(
                                          margin: EdgeInsets.only(top: 5.h),
                                          child: Row(
                                            children: [
                                              Text(
                                                'Kr ${widget.cartItem.product.price.toStringAsFixed(2)}',
                                                style: TextStyle(
                                                    fontSize: 13.sp,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              if (widget.cartItem.product
                                                      .pricePerVolume !=
                                                  null)
                                                Expanded(
                                                  child: Text(
                                                    ' - Kr ${widget.cartItem.product.pricePerVolume!.toStringAsFixed(2)} pr. liter',
                                                    style: TextStyle(
                                                        fontSize: 11.sp,
                                                        overflow: TextOverflow
                                                            .ellipsis),
                                                  ),
                                                )
                                            ],
                                          ),
                                        ),
                                        Container(
                                          margin: EdgeInsets.only(top: 5.h),
                                          child: Row(
                                            children: [
                                              Text(
                                                widget.cartItem.product
                                                            .rating !=
                                                        null
                                                    ? '${widget.cartItem.product.rating!.toStringAsFixed(2)} '
                                                    : '0 ',
                                                style: TextStyle(
                                                  fontSize: 12.sp,
                                                ),
                                              ),
                                              createRatingBar(
                                                  rating: widget.cartItem
                                                              .product.rating !=
                                                          null
                                                      ? widget.cartItem.product
                                                          .rating!
                                                      : 0,
                                                  size: 18.r,
                                                  color: Colors.yellow[700]!),
                                              Text(
                                                widget.cartItem.product
                                                            .checkins !=
                                                        null
                                                    ? ' ${NumberFormat.compact().format(widget.cartItem.product.checkins)}'
                                                    : '',
                                                style: TextStyle(
                                                  fontSize: 12.sp,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10.w,
                                  ),
                                  Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Container(
                                        height: widget.boxImageSize - 31,
                                        width: 40.w,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            width: 1,
                                            color: Colors.grey[400]!,
                                          ),
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(24.r),
                                          ),
                                        ),
                                        child: Stack(
                                          children: [
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: Semantics(
                                                    label: 'Legg til en',
                                                    button: true,
                                                    child: InkWell(
                                                      onTap: () {
                                                        widget.cartData.addItem(
                                                          widget.cartItem
                                                              .product.id,
                                                          widget
                                                              .cartItem.product,
                                                        );
                                                      },
                                                      child: Container(
                                                        padding:
                                                            EdgeInsets.fromLTRB(
                                                                10.w,
                                                                0,
                                                                10.w,
                                                                2.h),
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius.all(
                                                            Radius.circular(
                                                                5.r),
                                                          ),
                                                        ),
                                                        child: Icon(
                                                          Icons.add,
                                                          size: 18.r,
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .onSurface,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Semantics(
                                                    label: 'Fjern en',
                                                    button: true,
                                                    child: InkWell(
                                                      onTap: () {
                                                        quantity == 1
                                                            ? showPopupDelete(
                                                                widget.index,
                                                                widget
                                                                    .boxImageSize,
                                                                widget.cartItem,
                                                                widget.cartData,
                                                                context)
                                                            : widget.cartData
                                                                .removeSingleItem(
                                                                    widget
                                                                        .cartItem
                                                                        .product
                                                                        .id);
                                                      },
                                                      child: Container(
                                                        padding:
                                                            EdgeInsets.fromLTRB(
                                                                10.w,
                                                                2.h,
                                                                10.w,
                                                                0),
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius.all(
                                                            Radius.circular(
                                                                5.r),
                                                          ),
                                                        ),
                                                        child: Icon(
                                                          Icons.remove,
                                                          size: 18.r,
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .onSurface,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Center(
                                              child: Text(
                                                quantity.toString(),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        height: 3.h,
                                      ),
                                      Semantics(
                                        label:
                                            'Vis butikker med varen på lager',
                                        button: true,
                                        child: InkWell(
                                          onTap: () {
                                            setState(() {
                                              _expanded = !_expanded;
                                            });
                                          },
                                          child: Container(
                                            height: 28.r,
                                            width: 40.w,
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                width: 1,
                                                color: Colors.grey[400]!,
                                              ),
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(24.r),
                                              ),
                                            ),
                                            child: Icon(
                                              Icons.store_outlined,
                                              size: 17.r,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurface,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (_expanded == true)
                            FutureBuilder<List<StockInfo>>(
                              future: ApiHelper.getProductStock(
                                  client, widget.cartItem.product.id),
                              builder: (context, snapshot) {
                                if (snapshot.hasData &&
                                    snapshot.data!.isNotEmpty &&
                                    filters.storeList.isNotEmpty) {
                                  _stockList = _sortStockList(
                                      snapshot.data!, filters.storeList);
                                }
                                return Expanded(
                                  child: snapshot.connectionState ==
                                          ConnectionState.waiting
                                      ? const FadeIn(
                                          duration: Duration(milliseconds: 500),
                                          child: Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                        )
                                      : Padding(
                                          padding: EdgeInsets.fromLTRB(
                                              12.w, 0, 12.w, 12.h),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              if (_stockList.isNotEmpty)
                                                Expanded(
                                                  child: ListView.builder(
                                                    shrinkWrap: true,
                                                    itemCount:
                                                        _stockList.length,
                                                    itemBuilder:
                                                        (context, index) {
                                                      return Column(
                                                        children: [
                                                          FadeIn(
                                                            duration:
                                                                const Duration(
                                                                    milliseconds:
                                                                        300),
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Text(
                                                                  _stockList[
                                                                          index]
                                                                      .storeName,
                                                                ),
                                                                Text(
                                                                  'På lager: ${_stockList[index].quantity}',
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          const Divider(
                                                              height: 5),
                                                        ],
                                                      );
                                                    },
                                                  ),
                                                ),
                                              if (_stockList.isEmpty)
                                                const Expanded(
                                                  child: Center(
                                                    child: FadeIn(
                                                      duration: Duration(
                                                          milliseconds: 300),
                                                      child: Text(
                                                        'Ingen butikker har denne på lager',
                                                      ),
                                                    ),
                                                  ),
                                                )
                                            ],
                                          ),
                                        ),
                                );
                              },
                            ),
                        ],
                      ),
                    ],
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
