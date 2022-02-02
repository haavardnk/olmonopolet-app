import 'package:flutter/material.dart';
import 'package:shimmer_image/shimmer_image.dart';
import 'package:flutter_fadein/flutter_fadein.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rotated_corner_decoration/rotated_corner_decoration.dart';

import '../../models/product.dart';
import '../../providers/cart.dart';
import '../../screens/product_detail_screen.dart';
import './rating_widget.dart';

class ProductItem extends StatelessWidget {
  const ProductItem({required this.product, Key? key}) : super(key: key);

  final Product product;

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context, listen: false);
    final double _boxImageSize = (MediaQuery.of(context).size.width / 4);
    return FadeIn(
      child: Container(
        foregroundDecoration: product.userRating != null
            ? const RotatedCornerDecoration(
                color: Color(0xFFFBC02D),
                geometry: BadgeGeometry(
                  width: 25,
                  height: 25,
                  cornerRadius: 0,
                  alignment: BadgeAlignment.topLeft,
                ),
              )
            : null,
        child: Stack(
          children: [
            Column(
              children: [
                Semantics(
                  label: 'Gå til detaljside',
                  button: true,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushNamed(
                        ProductDetailScreen.routeName,
                        arguments: product,
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(12, 6, 12, 6),
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(0, 8, 8, 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            ClipRRect(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(5)),
                              child: Hero(
                                tag: product.id,
                                child: product.imageUrl != null
                                    ? ProgressiveImage(
                                        image: product.imageUrl ?? '',
                                        height: _boxImageSize,
                                        width: _boxImageSize,
                                        imageError:
                                            'assets/images/placeholder.png',
                                      )
                                    : Image.asset(
                                        'assets/images/placeholder.png',
                                        height: _boxImageSize,
                                        width: _boxImageSize,
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
                                    product.name,
                                    style: const TextStyle(
                                      fontSize: 14,
                                    ),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Container(
                                    margin: const EdgeInsets.only(top: 5),
                                    child: Row(
                                      children: [
                                        Text(
                                          'Kr ${product.price.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          ' - Kr ${product.pricePerVolume!.toStringAsFixed(2)} pr. liter',
                                          style: const TextStyle(
                                            fontSize: 11,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.only(top: 5),
                                    child: Text(
                                      product.style,
                                      style: const TextStyle(
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.only(top: 5),
                                    child: product.userRating == null
                                        ? Row(
                                            children: [
                                              Text(
                                                product.rating != null
                                                    ? '${product.rating!.toStringAsFixed(2)} '
                                                    : '0 ',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                ),
                                              ),
                                              createRatingBar(
                                                  rating: product.rating != null
                                                      ? product.rating!
                                                      : 0,
                                                  size: 18),
                                              Text(
                                                product.checkins != null
                                                    ? ' ${NumberFormat.compact().format(product.checkins)}'
                                                    : '',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          )
                                        : Row(
                                            children: [
                                              Text(
                                                product.rating != null
                                                    ? 'Global: ${product.rating!.toStringAsFixed(2)}'
                                                    : '0 ',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                ),
                                              ),
                                              Icon(
                                                Icons.star,
                                                color: Colors.yellow[700],
                                                size: 18,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                product.userRating != null
                                                    ? 'Din: ${product.userRating!.toStringAsFixed(2)} '
                                                    : '0 ',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                ),
                                              ),
                                              Icon(
                                                Icons.star,
                                                color: Colors.yellow[700],
                                                size: 18,
                                              ),
                                            ],
                                          ),
                                  ),
                                  Container(
                                    height: 11,
                                    margin: const EdgeInsets.only(top: 5),
                                    child: Row(
                                      children: [
                                        if (product.stock != null &&
                                            product.stock != 0)
                                          Row(
                                            children: [
                                              Text(
                                                'På lager: ${product.stock}',
                                                style: const TextStyle(
                                                  fontSize: 11,
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
                                              product.abv != null
                                                  ? '${product.abv!.toStringAsFixed(1)}%'
                                                  : '',
                                              style: const TextStyle(
                                                fontSize: 11,
                                              ),
                                            ),
                                            if (product.abv != null)
                                              VerticalDivider(
                                                width: 15,
                                                thickness: 1,
                                                color: Colors.grey[300],
                                              ),
                                            Text(
                                              '${product.volume}l',
                                              style: const TextStyle(
                                                fontSize: 11,
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
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 14,
              right: 12,
              child: Semantics(
                button: true,
                label: 'Legg i handleliste',
                child: InkWell(
                  onTap: () {
                    cart.addItem(product.id, product);
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text(
                          'Lagt til i handlelisten!',
                          textAlign: TextAlign.center,
                        ),
                        duration: const Duration(seconds: 2),
                        action: SnackBarAction(
                          label: 'ANGRE',
                          onPressed: () {
                            cart.removeSingleItem(product.id);
                          },
                        ),
                      ),
                    );
                  },
                  child: Container(
                    height: 35,
                    width: 50,
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 1,
                        color: Theme.of(context).iconTheme.color!,
                      ),
                      borderRadius: const BorderRadius.all(
                        Radius.circular(5),
                      ),
                    ),
                    child: const Icon(
                      Icons.add_shopping_cart,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeIn,
    );
  }
}
