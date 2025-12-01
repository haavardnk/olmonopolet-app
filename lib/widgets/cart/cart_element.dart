import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:intl/intl.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';

import '../../providers/cart.dart';
import '../common/rating_widget.dart';
import '../common/info_chips.dart';
import '../common/stock_popup.dart';
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
                  margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Opacity(
                    opacity: !widget.cartItem.inStock &&
                            widget.cartData.greyNoStock &&
                            widget.cartData.cartStoreId.isNotEmpty
                        ? 0.3
                        : 1,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(12.r, 8.r, 12.r, 12.r),
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
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
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
                                            ),
                                            if (widget.cartItem.product
                                                .isChristmasBeer) ...[
                                              SizedBox(width: 6.w),
                                              buildChristmasChip(context),
                                            ],
                                          ],
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
                            bottom: 0,
                            right: 0,
                            child: _buildQuantityControl(
                                context, quantity, imageSize),
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

  Widget _buildQuantityControl(
      BuildContext context, int quantity, double imageSize) {
    return Container(
      height: imageSize,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              widget.cartData
                  .addItem(widget.cartItem.product.id, widget.cartItem.product);
            },
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              child: Icon(Icons.add, size: 18.r),
            ),
          ),
          Text(
            '$quantity',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
              widget.cartData.removeSingleItem(widget.cartItem.product.id);
            },
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              child: Icon(Icons.remove, size: 18.r),
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
    showStockPopup(
      context: context,
      productId: widget.cartItem.product.id,
      productName: widget.cartItem.product.name,
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
