import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/product.dart';

class ApiHelper {
  static Future<List<Product>> getProductList(int page) async {
    const fields =
        "vmp_id,vmp_name,price,rating,checkins,label_sm_url,main_category,sub_category,style";
    try {
      final response = await http.get(_apiUrlBuilder(fields, page));
      if (response.statusCode == 200) {
        final jsonResponse =
            json.decode(utf8.decode(response.bodyBytes))['results'];
        List<Product> products = List<Product>.from(
          jsonResponse.map(
            (product) => Product.fromJson(product),
          ),
        );
        return products;
      } else {
        throw GenericHttpException();
      }
    } on SocketException {
      throw NoConnectionException();
    }
  }
}

Uri _apiUrlBuilder(String fields, int page) {
  const _baseUrl = 'http://127.0.0.1:8000/beers/';
  //const _baseUrl = 'https://api.beermonopoly.com/beers/';
  final url = Uri.parse(
      '$_baseUrl?fields=$fields&active=true&ordering=-rating&page=$page');
  return url;
}

class GenericHttpException implements Exception {}

class NoConnectionException implements Exception {}
