import 'package:flutter/material.dart';
import 'package:shimmer_image/shimmer_image.dart';

import '../../models/product.dart';
import './rating_widget.dart';

class ProductItem extends StatelessWidget {
  const ProductItem({required this.product, Key? key}) : super(key: key);

  final Product product;

  @override
  Widget build(BuildContext context) {
    final double _boxImageSize = (MediaQuery.of(context).size.width / 4);
    return Column(
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
                    borderRadius: const BorderRadius.all(Radius.circular(4)),
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
                          child: Text('Kr ${product.price!.toStringAsFixed(2)}',
                              style: const TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.bold)),
                        ),
                        Container(
                            margin: const EdgeInsets.only(top: 5),
                            child: Text(product.style,
                                style: const TextStyle(
                                    fontSize: 12, color: Color(0xFFaaaaaa)))),
                        Container(
                          margin: const EdgeInsets.only(top: 5),
                          child: Row(
                            children: [
                              Text(
                                  product.rating != null
                                      ? product.rating!.toStringAsFixed(2)
                                      : '0',
                                  style: const TextStyle(
                                      fontSize: 12, color: Color(0xFFaaaaaa))),
                              createRatingBar(
                                  rating: product.rating != null
                                      ? product.rating!
                                      : 0,
                                  size: 18),
                              Text('(${product.checkins.toString()})',
                                  style: const TextStyle(
                                      fontSize: 12, color: Color(0xFFaaaaaa)))
                            ],
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 5),
                          child: const Text('På lager: 10',
                              style: TextStyle(
                                  fontSize: 11, color: Color(0xFFaaaaaa))),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
