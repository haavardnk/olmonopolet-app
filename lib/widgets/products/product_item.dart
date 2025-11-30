import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flag/flag.dart';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';

import '../../models/product.dart';
import '../../models/release.dart';
import '../../providers/cart.dart';
import '../../screens/product_detail_screen.dart';
import '../common/rating_widget.dart';
import '../../assets/constants.dart';

class ProductItem extends StatefulWidget {
  const ProductItem({required this.product, super.key, this.release});

  final Product product;
  final Release? release;

  @override
  State<ProductItem> createState() => _ProductItemState();
}

class _ProductItemState extends State<ProductItem> {
  late Product _product;

  @override
  void initState() {
    super.initState();
    _product = widget.product;
  }

  @override
  Widget build(BuildContext context) {
    final shortestSide = 1.sw < 1.sh ? 1.sw : 1.sh;
    final tabletMode = shortestSide >= 600;
    final cart = Provider.of<Cart>(context, listen: false);
    final double boxImageSize = tabletMode ? 110.r : shortestSide / 4;
    final heroTag = widget.release != null
        ? 'release${_product.id}'
        : 'products${_product.id}';
    final displayImageUrl = _product.labelHdUrl ?? _product.imageUrl;

    return Semantics(
      label: _product.name,
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          pushScreen(
            context,
            settings: RouteSettings(
                name: ProductDetailScreen.routeName,
                arguments: <String, dynamic>{
                  'product': _product,
                  'herotag': heroTag
                }),
            screen: const ProductDetailScreen(),
            pageTransitionAnimation: PageTransitionAnimation.cupertino,
            withNavBar: true,
          ).then((result) {
            if (result != null && result is Product) {
              setState(() {
                _product = result;
              });
            }
          });
        },
        child: Stack(
          children: [
            Container(
              margin: EdgeInsets.fromLTRB(12.w, 6.h, 20.w, 10.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(top: 4.h),
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(6.r)),
                      child: Stack(
                        children: [
                          Hero(
                            tag: heroTag,
                            child: displayImageUrl != null &&
                                    displayImageUrl.isNotEmpty
                                ? FancyShimmerImage(
                                    imageUrl: displayImageUrl,
                                    height: boxImageSize,
                                    width: boxImageSize,
                                    errorWidget: Image.asset(
                                      'assets/images/placeholder.png',
                                      height: boxImageSize,
                                      width: boxImageSize,
                                    ),
                                  )
                                : Image.asset(
                                    'assets/images/placeholder.png',
                                    height: boxImageSize,
                                    width: boxImageSize,
                                  ),
                          ),
                          if (_product.countryCode != null &&
                              _product.countryCode!.isNotEmpty)
                            ClipRRect(
                              borderRadius: BorderRadius.only(
                                  bottomRight: Radius.circular(6.r)),
                              child: Flag.fromString(
                                _product.countryCode!,
                                height: 20.r,
                                width: 20.r * 4 / 3,
                              ),
                            )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10.w,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _product.name,
                          style: TextStyle(
                            fontSize: 14.sp,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Row(
                          children: [
                            Text(
                              'Kr ${_product.price.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              ' - Kr ${_product.pricePerVolume!.toStringAsFixed(2)} pr. liter',
                              style: TextStyle(
                                fontSize: 11.sp,
                              ),
                            )
                          ],
                        ),
                        Text(
                          _product.style,
                          style: TextStyle(
                            fontSize: 12.sp,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              _product.rating != null
                                  ? '${_product.rating!.toStringAsFixed(2)} '
                                  : '0 ',
                              style: TextStyle(
                                fontSize: 12.sp,
                              ),
                            ),
                            createRatingBar(
                                rating: _product.rating != null
                                    ? _product.rating!
                                    : 0,
                                size: 18.r,
                                color: Colors.yellow[700]!),
                            Text(
                              _product.checkins != null
                                  ? ' ${NumberFormat.compact().format(_product.checkins)}'
                                  : '',
                              style: TextStyle(
                                fontSize: 12.sp,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          height: 11.h,
                          margin: EdgeInsets.only(top: 2.h),
                          child: Row(
                            children: [
                              if (_product.stock != null && _product.stock != 0)
                                Row(
                                  children: [
                                    Text(
                                      'På lager: ${_product.stock}',
                                      style: TextStyle(
                                        fontSize: 11.sp,
                                        height: 0.9,
                                      ),
                                    ),
                                    VerticalDivider(
                                      width: 15.w,
                                      thickness: 1,
                                      color: Colors.grey[300],
                                    ),
                                  ],
                                ),
                              Row(
                                children: [
                                  Text(
                                    _product.abv != null
                                        ? '${_product.abv!.toStringAsFixed(1)}%'
                                        : '',
                                    style: TextStyle(
                                      fontSize: 11.sp,
                                      height: 0.9,
                                    ),
                                  ),
                                  if (_product.abv != null)
                                    VerticalDivider(
                                      width: 15.w,
                                      thickness: 1,
                                      color: Colors.grey[300],
                                    ),
                                  Text(
                                    '${_product.volume}l',
                                    style: TextStyle(
                                      fontSize: 11.sp,
                                      height: 0.9,
                                    ),
                                  ),
                                  if (widget.release != null &&
                                      widget.release!.productSelections.length >
                                          1)
                                    VerticalDivider(
                                      width: 15.w,
                                      thickness: 1,
                                      color: Colors.grey[300],
                                    ),
                                  if (widget.release != null &&
                                      widget.release!.productSelections.length >
                                          1)
                                    Text(
                                      '${productSelectionAbrevationList[_product.productSelection]}',
                                      style: TextStyle(
                                        fontSize: 11.sp,
                                        height: 0.9,
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: tabletMode ? null : 10.h,
              top: !tabletMode ? null : boxImageSize + 11.h - 35.r,
              right: 12.w,
              child: Semantics(
                button: true,
                label: 'Legg i handleliste',
                child: InkWell(
                  onTap: () {
                    cart.addItem(_product.id, _product);
                    cart.updateCartItemsData();
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Lagt til i handlelisten!',
                          textAlign: TextAlign.center,
                        ),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  onLongPress: () {
                    if (cart.items.keys.contains(_product.id)) {
                      cart.removeSingleItem(_product.id);
                      cart.updateCartItemsData();
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            cart.items.keys.contains(_product.id)
                                ? 'Fjernet en fra handlelisten!'
                                : 'Fjernet helt fra handlelisten!',
                            textAlign: TextAlign.center,
                          ),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  child: Container(
                    height: 35.r,
                    width: 50.r,
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 1,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      borderRadius: BorderRadius.all(
                        Radius.circular(24.r),
                      ),
                    ),
                    child: Consumer<Cart>(
                      builder: (_, cart, __) => Center(
                        child: Badge(
                          isLabelVisible: cart.items.keys.contains(_product.id),
                          label: Text(cart.items.keys.contains(_product.id)
                              ? cart.items[_product.id]!.quantity.toString()
                              : ''),
                          child: Icon(
                            Icons.shopping_cart_outlined,
                            size: 20.r,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
