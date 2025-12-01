import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';

import '../../models/product.dart';
import '../../models/release.dart';
import '../../providers/cart.dart';
import '../../screens/product_detail_screen.dart';
import '../common/rating_widget.dart';
import '../common/info_chips.dart';
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
    final cart = Provider.of<Cart>(context, listen: false);
    final double imageSize = 85.r;
    final heroTag = widget.release != null
        ? 'release${_product.id}'
        : 'products${_product.id}';
    final displayImageUrl = _product.labelHdUrl ?? _product.imageUrl;

    return Semantics(
      label: _product.name,
      button: true,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: InkWell(
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
          borderRadius: BorderRadius.circular(12.r),
          child: Padding(
            padding: EdgeInsets.fromLTRB(12.r, 8.r, 12.r, 12.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _product.name,
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
                          borderRadius: BorderRadius.circular(8.r),
                          child: Hero(
                            tag: heroTag,
                            child: displayImageUrl != null &&
                                    displayImageUrl.isNotEmpty
                                ? FancyShimmerImage(
                                    imageUrl: displayImageUrl,
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
                          child: _buildCartButton(context, cart),
                        ),
                      ],
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Kr ${_product.price.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.bold,
                                  height: 1.0,
                                ),
                              ),
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
                                '${_product.pricePerVolume!.toStringAsFixed(0)} kr/l',
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            _product.style,
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
                                  rating: _product.rating ?? 0,
                                  size: 16.r,
                                  color: Colors.amber),
                              SizedBox(width: 4.w),
                              Text(
                                _product.rating?.toStringAsFixed(1) ?? '-',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              if (_product.checkins != null) ...[
                                SizedBox(width: 4.w),
                                Text(
                                  '(${NumberFormat.compact().format(_product.checkins)})',
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
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              buildInfoChip('${_product.volume}L', context,
                                  icon: Icons.water_drop_outlined),
                              if (_product.abv != null)
                                buildInfoChip(
                                    '${_product.abv!.toStringAsFixed(1)}%',
                                    context,
                                    icon: Icons.percent),
                              if (_product.country != null &&
                                  _product.country!.isNotEmpty)
                                buildInfoChipWithFlag(
                                  _product.country!,
                                  _product.countryCode,
                                  context,
                                ),
                              if (_product.stock != null && _product.stock! > 0)
                                buildInfoChip('${_product.stock} stk', context,
                                    highlight: true,
                                    icon: Icons.inventory_2_outlined),
                              if (widget.release != null &&
                                  widget.release!.productSelections.length > 1)
                                buildInfoChip(
                                    productSelectionAbbreviationList[
                                            _product.productSelection] ??
                                        '',
                                    context),
                            ],
                          ),
                        ],
                      ),
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

  Widget _buildCartButton(BuildContext context, Cart cart) {
    return Consumer<Cart>(
      builder: (_, cartData, __) {
        final inCart = cartData.items.keys.contains(_product.id);
        final quantity = inCart ? cartData.items[_product.id]!.quantity : 0;

        return GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            cart.addItem(_product.id, _product);
            cart.updateCartItemsData();
          },
          onLongPress: () {
            if (inCart) {
              HapticFeedback.mediumImpact();
              cart.removeSingleItem(_product.id);
              cart.updateCartItemsData();
            }
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
            child: Badge(
              isLabelVisible: inCart,
              label: Text(
                quantity.toString(),
                style: TextStyle(fontSize: 9.sp),
              ),
              child: Icon(
                inCart ? Icons.shopping_cart : Icons.add_shopping_cart_outlined,
                size: 18.r,
                color: Colors.white,
              ),
            ),
          ),
        );
      },
    );
  }
}
