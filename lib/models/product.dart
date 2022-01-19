import 'package:flutter/material.dart';

class Product {
  Product(
      {required this.id,
      required this.name,
      required this.style,
      this.stock,
      this.price,
      this.rating,
      this.checkins,
      this.abv,
      this.imageUrl,
      this.userRating});

  factory Product.fromJson(Map<String, dynamic> product) => Product(
        id: product['vmp_id'],
        name: product['vmp_name'],
        style: product['style'] ??
            product['sub_category'] ??
            product['main_category'],
        stock: product['stock'],
        price: product['price'],
        rating: product['rating'],
        checkins: product['checkins'],
        abv: product['abv'],
        imageUrl: product['label_sm_url'],
        userRating: product['user_checked_in'] != null &&
                product['user_checked_in'].isNotEmpty
            ? product['user_checked_in'][0]['rating']
            : null,
      );

  final int id;
  final String name;
  final String style;
  final int? stock;
  final double? price;
  final double? rating;
  final int? checkins;
  final double? abv;
  final String? imageUrl;
  final double? userRating;
}
