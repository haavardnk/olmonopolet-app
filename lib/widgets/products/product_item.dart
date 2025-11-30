import 'package:flutter/material.dart';
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
    final MediaQueryData mediaQueryData = MediaQuery.of(context);
    final tabletMode = mediaQueryData.size.shortestSide >= 600 ? true : false;
    final cart = Provider.of<Cart>(context, listen: false);
    final double boxImageSize = tabletMode
        ? 100 + mediaQueryData.textScaleFactor * 10
        : mediaQueryData.size.shortestSide / 4;
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
              margin: const EdgeInsets.fromLTRB(12, 6, 20, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(6)),
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
                              borderRadius: const BorderRadius.only(
                                  bottomRight: Radius.circular(6)),
                              child: Flag.fromString(
                                _product.countryCode!,
                                height: 20,
                                width: 20 * 4 / 3,
                              ),
                            )
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _product.name,
                          style: const TextStyle(
                            fontSize: 14,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Row(
                          children: [
                            Text(
                              'Kr ${_product.price.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              ' - Kr ${_product.pricePerVolume!.toStringAsFixed(2)} pr. liter',
                              style: const TextStyle(
                                fontSize: 11,
                              ),
                            )
                          ],
                        ),
                        Text(
                          _product.style,
                          style: const TextStyle(
                            fontSize: 12,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              _product.rating != null
                                  ? '${_product.rating!.toStringAsFixed(2)} '
                                  : '0 ',
                              style: const TextStyle(
                                fontSize: 12,
                              ),
                            ),
                            createRatingBar(
                                rating: _product.rating != null
                                    ? _product.rating!
                                    : 0,
                                size: 18,
                                color: Colors.yellow[700]!),
                            Text(
                              _product.checkins != null
                                  ? ' ${NumberFormat.compact().format(_product.checkins)}'
                                  : '',
                              style: const TextStyle(
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          height: 11,
                          margin: const EdgeInsets.only(top: 2),
                          child: Row(
                            children: [
                              if (_product.stock != null && _product.stock != 0)
                                Row(
                                  children: [
                                    Text(
                                      'På lager: ${_product.stock}',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        height: 0.9,
                                      ),
                                    ),
                                    VerticalDivider(
                                      width: 15,
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
                                    style: const TextStyle(
                                      fontSize: 11,
                                      height: 0.9,
                                    ),
                                  ),
                                  if (_product.abv != null)
                                    VerticalDivider(
                                      width: 15,
                                      thickness: 1,
                                      color: Colors.grey[300],
                                    ),
                                  Text(
                                    '${_product.volume}l',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      height: 0.9,
                                    ),
                                  ),
                                  if (widget.release != null &&
                                      widget.release!.productSelections.length >
                                          1)
                                    VerticalDivider(
                                      width: 15,
                                      thickness: 1,
                                      color: Colors.grey[300],
                                    ),
                                  if (widget.release != null &&
                                      widget.release!.productSelections.length >
                                          1)
                                    Text(
                                      '${productSelectionAbrevationList[_product.productSelection]}',
                                      style: const TextStyle(
                                        fontSize: 11,
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
              bottom: tabletMode ? null : 10,
              top: !tabletMode ? null : boxImageSize + 11 - 35,
              right: 12,
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
                    height: 35,
                    width: 50,
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 1,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      borderRadius: const BorderRadius.all(
                        Radius.circular(24),
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
                            size: 20,
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
