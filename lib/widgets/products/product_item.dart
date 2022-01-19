import 'package:flutter/material.dart';
import 'package:shimmer_image/shimmer_image.dart';
import 'package:flutter_fadein/flutter_fadein.dart';
import 'package:intl/intl.dart';

import '../../models/product.dart';
import './rating_widget.dart';

class ProductItem extends StatelessWidget {
  const ProductItem({required this.product, Key? key}) : super(key: key);

  final Product product;

  @override
  Widget build(BuildContext context) {
    final double _boxImageSize = (MediaQuery.of(context).size.width / 4);
    return FadeIn(
      child: Stack(
        children: [
          Column(
            children: [
              GestureDetector(
                onTap: () {},
                child: Container(
                  margin: const EdgeInsets.fromLTRB(12, 6, 12, 6),
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        ClipRRect(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(4)),
                          child: product.imageUrl != null
                              ? ProgressiveImage(
                                  image: product.imageUrl!,
                                  height: _boxImageSize,
                                  width: _boxImageSize)
                              : Image.asset(
                                  'assets/images/placeholder.png',
                                  width: _boxImageSize,
                                  height: _boxImageSize,
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
                                    fontSize: 14, color: Color(0xFF515151)),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Container(
                                margin: const EdgeInsets.only(top: 5),
                                child: Text(
                                    'Kr ${product.price!.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold)),
                              ),
                              Container(
                                  margin: const EdgeInsets.only(top: 5),
                                  child: Text(
                                      product.abv != null
                                          ? '${product.style} - ${product.abv!.toStringAsFixed(1)}%'
                                          : product.style,
                                      style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFFaaaaaa)))),
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
                                                color: Color(0xFFaaaaaa)),
                                          ),
                                          createRatingBar(
                                              rating: product.rating != null
                                                  ? product.rating!
                                                  : 0,
                                              size: 18),
                                          Text(
                                            ' ${NumberFormat.compact().format(product.checkins)}',
                                            style: const TextStyle(
                                                fontSize: 12,
                                                color: Color(0xFFaaaaaa)),
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
                                                color: Color(0xFFaaaaaa)),
                                          ),
                                          Icon(
                                            Icons.star,
                                            color: Colors.yellow[700],
                                            size: 18,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            product.rating != null
                                                ? 'Din: ${product.userRating!.toStringAsFixed(2)} '
                                                : '0 ',
                                            style: const TextStyle(
                                                fontSize: 12,
                                                color: Color(0xFFaaaaaa)),
                                          ),
                                          Icon(
                                            Icons.star,
                                            color: Colors.yellow[700],
                                            size: 18,
                                          ),
                                        ],
                                      ),
                              ),
                              if (product.stock != null && product.stock != 0)
                                Container(
                                  margin: const EdgeInsets.only(top: 5),
                                  child: Text('På lager: ${product.stock}',
                                      style: const TextStyle(
                                          fontSize: 11,
                                          color: Color(0xFFaaaaaa))),
                                ),
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            const SizedBox(
                              height: 25,
                            ),
                            IconButton(
                              icon: const Icon(Icons.shopping_cart),
                              color: Colors.pink,
                              onPressed: () {},
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (product.userRating != null)
            Stack(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 1, 0, 0),
                    child: Container(
                      height: 30,
                      width: 30,
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        border: Border.all(
                          color: Colors.grey[50]!,
                        ),
                        borderRadius: const BorderRadius.only(
                          bottomRight: Radius.circular(30),
                        ),
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    child: const Icon(
                      Icons.check,
                      color: Colors.pink,
                      size: 25,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeIn,
    );
  }
}
