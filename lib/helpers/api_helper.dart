import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/product.dart';
import '../models/store.dart';
import '../models/release.dart';
import '../models/stock_change.dart';
import '../providers/filter.dart';
import '../utils/environment.dart';

class ApiHelper {
  static Future<Map<String, dynamic>> getDetailedProductInfo(
      http.Client http, int productId, String fields) async {
    final url = Uri.parse(
        '${Environment.apiBaseUrl}beers/?beers=$productId&fields=$fields&all_stock=true');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse =
            json.decode(utf8.decode(response.bodyBytes))['results'][0];
        return jsonResponse;
      } else {
        throw GenericHttpException();
      }
    } on SocketException {
      throw NoConnectionException();
    }
  }

  static Future<List<dynamic>> checkStock(
      http.Client http, String productIds, String store) async {
    final url = Uri.parse(
        '${Environment.apiBaseUrl}beers/?beers=$productIds&store=$store&fields=vmp_id,stock');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse =
            json.decode(utf8.decode(response.bodyBytes))['results'];
        return jsonResponse;
      } else {
        throw GenericHttpException();
      }
    } on SocketException {
      throw NoConnectionException();
    }
  }

  static Future<List<StockChange>> getStockChangeList(
      http.Client http, int page, int pageSize, String store) async {
    try {
      final response = await http.get(
        _apiStockChangeUrlBuilder(page, pageSize, store),
      );

      if (response.statusCode == 200) {
        final jsonResponse =
            json.decode(utf8.decode(response.bodyBytes))['results'];
        List<StockChange> stockChange = List<StockChange>.from(
          jsonResponse.map(
            (stockChange) => StockChange.fromJson(stockChange),
          ),
        );
        return stockChange;
      } else {
        throw GenericHttpException();
      }
    } on SocketException {
      throw NoConnectionException();
    }
  }

  static Future<List<Product>> getProductList(
      http.Client http, int page, Filter filter, int pageSize,
      [Release? release]) async {
    const fields =
        'vmp_id,vmp_name,price,rating,checkins,label_sm_url,main_category,'
        'sub_category,style,stock,abv,volume,price_per_volume,vmp_url,'
        'untpd_url,untpd_id,country,product_selection';
    try {
      final response = await http.get(
        release == null
            ? _apiProductUrlBuilder(fields, page, filter, pageSize)
            : _apiReleaseProductUrlBuilder(
                fields, page, filter, release, pageSize),
      );
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

  static Future<List<Product>> getProductsData(
      http.Client http, String productIds) async {
    const fields =
        'vmp_id,vmp_name,price,rating,checkins,label_sm_url,main_category,'
        'sub_category,style,stock,abv,volume,price_per_volume,'
        'vmp_url,untpd_url,untpd_id,country';
    final url = Uri.parse(
        '${Environment.apiBaseUrl}beers/?beers=$productIds&fields=$fields');
    try {
      final response = await http.get(url);
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

  static Future<void> submitUntappdMatch(
      http.Client http, int productId, String untappdUrl) async {
    final jsonBody = json.encode({
      'beer': productId,
      'suggested_url': untappdUrl,
    });
    try {
      final response = await http.post(
        Uri.parse('${Environment.apiBaseUrl}wrongmatch/'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonBody,
      );
      if (response.statusCode == 201) {
        return;
      } else {
        throw GenericHttpException();
      }
    } on SocketException {
      throw NoConnectionException();
    }
  }

  static Future<List<Store>> getStoreList(http.Client http) async {
    const fields = "store_id,name,gps_lat,gps_long";
    try {
      final response = await http.get(_apiStoreUrlBuilder(fields));
      if (response.statusCode == 200) {
        final jsonResponse =
            json.decode(utf8.decode(response.bodyBytes))['results'];
        List<Store> stores = List<Store>.from(
          jsonResponse.map(
            (store) => Store.fromJson(store),
          ),
        );
        return stores;
      } else {
        throw GenericHttpException();
      }
    } on SocketException {
      throw NoConnectionException();
    }
  }

  static Future<List<Release>> getReleaseList(http.Client http) async {
    const fields = "name,release_date,beer_count,product_selections";

    final response = await http.get(_apiReleaseUrlBuilder(fields));
    if (response.statusCode == 200) {
      final jsonResponse =
          json.decode(utf8.decode(response.bodyBytes))['results'];
      List<Release> releases = List<Release>.from(
        jsonResponse.map(
          (release) => Release.fromJson(release),
        ),
      );
      return releases;
    } else {
      throw GenericHttpException();
    }
  }

  static Future<void> updateFcmToken(http.Client http, String fcmToken) async {
    try {
      // Since this endpoint usually requires authentication, we do nothing
      // as authentication is being removed from the app
      return;
    } on SocketException {
      throw NoConnectionException();
    }
  }
}

Uri _apiProductUrlBuilder(
    String fields, int page, Filter filter, int pageSize) {
  var string = ('${Environment.apiBaseUrl}'
      'beers/'
      '?fields=$fields'
      '&active=True'
      '&price_low=${filter.priceLow}'
      '&price_high=${filter.priceHigh}'
      '&ppv_high=${filter.ppvHigh}'
      '&ppv_low=${filter.ppvLow}'
      '&abv_high=${filter.abvHigh}'
      '&abv_low=${filter.abvLow}'
      '&ordering=${filter.sortBy}'
      '&style=${filter.style}'
      '&country=${filter.country}'
      '&product_selection=${filter.productSelection}'
      '&search=${filter.search}'
      '&release=${filter.release}'
      '&exclude_allergen=${filter.excludeAllergens}'
      '&page=$page'
      '&page_size=$pageSize');
  if (filter.storeId.isNotEmpty) {
    string = string + '&store=${filter.storeId}';
  }
  if (filter.checkIn == 1 || filter.sortBy.contains('checkin__rating')) {
    string = string + '&user_checkin=True';
  } else if (filter.checkIn == 2) {
    string = string + '&user_checkin=False';
  }
  if (filter.wishlisted == 1) {
    string = string + '&user_wishlisted=True';
  } else if (filter.wishlisted == 2) {
    string = string + '&user_wishlisted=False';
  }
  if (filter.deliverySelectedList[0] == true) {
    string = string + '&store_delivery=True';
  }
  if (filter.deliverySelectedList[1] == true) {
    string = string + '&post_delivery=True';
  }

  final url = Uri.parse(string);
  return url;
}

Uri _apiReleaseProductUrlBuilder(
    String fields, int page, Filter filter, Release release, int pageSize) {
  var string = ('${Environment.apiBaseUrl}'
      'beers/'
      '?fields=$fields'
      '&release=${release.name}'
      '&ordering=${filter.releaseSortBy}'
      '&page=$page'
      '&page_size=$pageSize');

  if (release.productSelections.length > 1) {
    string += '&product_selection=${filter.releaseProductSelectionChoice}';
  }

  final url = Uri.parse(string);
  return url;
}

Uri _apiStockChangeUrlBuilder(int page, int pageSize, String store) {
  var string = ('${Environment.apiBaseUrl}'
      'stockchange/'
      '?store=$store'
      '&page=$page'
      '&page_size=$pageSize');

  final url = Uri.parse(string);
  return url;
}

Uri _apiStoreUrlBuilder(String fields) {
  final url = Uri.parse(
    '${Environment.apiBaseUrl}'
    'stores/'
    '?fields=$fields'
    '&page_size=500',
  );
  return url;
}

Uri _apiReleaseUrlBuilder(String fields) {
  final url = Uri.parse(
    '${Environment.apiBaseUrl}'
    'release/'
    '?fields=$fields',
  );
  return url;
}

class GenericHttpException implements Exception {}

class NoConnectionException implements Exception {}
