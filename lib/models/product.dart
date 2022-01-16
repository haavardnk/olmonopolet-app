import 'package:flutter/material.dart';

class Product {
  Product({
    required this.id,
    required this.name,
    required this.style,
    this.price,
    this.rating,
    this.checkins,
    this.imageUrl,
  });

  factory Product.fromJson(Map<String, dynamic> product) => Product(
        id: product['vmp_id'],
        name: product['vmp_name'],
        style: product['style'] ??
            product['sub_category'] ??
            product['main_category'],
        price: product['price'],
        rating: product['rating'],
        checkins: product['checkins'],
        imageUrl: product['label_sm_url'],
      );

  final int id;
  final String name;
  final String style;
  final double? price;
  final double? rating;
  final int? checkins;
  final String? imageUrl;
}
