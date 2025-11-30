import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/product.dart';
import '../models/store.dart';
import '../models/release.dart';
import '../models/stock_change.dart';
import '../models/country.dart';
import '../providers/filter.dart';
import '../utils/environment.dart';
import '../utils/exceptions.dart';

class ApiHelper {
  static String get _baseUrl => Environment.apiBaseUrl;

  static Future<T> _handleRequest<T>({
    required Future<http.Response> Function() request,
    required T Function(dynamic json) parser,
    required String endpoint,
    bool expectResultsKey = true,
  }) async {
    try {
      final response = await request();
      return _handleResponse(
        response: response,
        parser: parser,
        endpoint: endpoint,
        expectResultsKey: expectResultsKey,
      );
    } on SocketException {
      throw const NetworkException();
    } on FormatException catch (e) {
      throw ApiException(
        message: 'Ugyldig responsformat: ${e.message}',
        endpoint: endpoint,
      );
    }
  }

  static T _handleResponse<T>({
    required http.Response response,
    required T Function(dynamic json) parser,
    required String endpoint,
    bool expectResultsKey = true,
  }) {
    final statusCode = response.statusCode;

    if (statusCode >= 200 && statusCode < 300) {
      final decoded = json.decode(utf8.decode(response.bodyBytes));
      final data = expectResultsKey ? decoded['results'] : decoded;
      return parser(data);
    }

    switch (statusCode) {
      case 401:
        throw UnauthorizedException(endpoint: endpoint);
      case 404:
        throw NotFoundException(endpoint: endpoint);
      case >= 500:
        throw ServerException(
          message: 'Serverfeil',
          statusCode: statusCode,
          endpoint: endpoint,
        );
      default:
        throw ApiException(
          message: 'Forespørsel feilet',
          statusCode: statusCode,
          endpoint: endpoint,
        );
    }
  }

  static Future<Product> getProductDetails(
    http.Client client,
    Product product,
  ) async {
    const fields =
        'vmp_id,vmp_name,style,sub_category,main_category,stock,price,volume,'
        'price_per_volume,rating,checkins,abv,label_sm_url,vmp_url,untpd_url,'
        'untpd_id,country,country_code,product_selection,label_hd_url,ibu,'
        'description,brewery,year,color,aroma,taste,storable,food_pairing,'
        'raw_materials,fullness,sweetness,freshness,bitterness,sugar,acid,'
        'method,allergens,alcohol_units,all_stock';
    final endpoint = 'beers/?beers=${product.id}&fields=$fields&all_stock=true';
    return _handleRequest(
      request: () => client.get(Uri.parse('$_baseUrl$endpoint')),
      parser: (json) => Product.fromJson(
        (json as List).first as Map<String, dynamic>,
      ),
      endpoint: endpoint,
    );
  }

  static Future<List<StockInfo>> getProductStock(
    http.Client client,
    int productId,
  ) async {
    final endpoint = 'beers/?beers=$productId&fields=all_stock&all_stock=true';
    return _handleRequest(
      request: () => client.get(Uri.parse('$_baseUrl$endpoint')),
      parser: (json) {
        final data = (json as List).first as Map<String, dynamic>;
        if (data['all_stock'] == null) return <StockInfo>[];
        return (data['all_stock'] as List)
            .map((s) => StockInfo.fromJson(s))
            .toList();
      },
      endpoint: endpoint,
    );
  }

  static Future<List<dynamic>> checkStock(
    http.Client client,
    String productIds,
    String store,
  ) async {
    final endpoint =
        'beers/?beers=$productIds&store=$store&fields=vmp_id,stock';
    return _handleRequest(
      request: () => client.get(Uri.parse('$_baseUrl$endpoint')),
      parser: (json) => json as List<dynamic>,
      endpoint: endpoint,
    );
  }

  static Future<List<StockChange>> getStockChangeList(
    http.Client client, {
    required String store,
    required int page,
    required int pageSize,
  }) async {
    final endpoint = 'stockchange/?store=$store&page=$page&page_size=$pageSize';
    return _handleRequest(
      request: () => client.get(Uri.parse('$_baseUrl$endpoint')),
      parser: (json) =>
          (json as List).map((item) => StockChange.fromJson(item)).toList(),
      endpoint: endpoint,
    );
  }

  static Future<List<Product>> getProductList(
    http.Client client, {
    required Filter filter,
    required int page,
    required int pageSize,
    Release? release,
  }) async {
    final url = release == null
        ? _buildProductUrl(page, filter, pageSize)
        : _buildReleaseProductUrl(page, filter, release, pageSize);

    return _handleRequest(
      request: () => client.get(url),
      parser: (json) =>
          (json as List).map((item) => Product.fromJson(item)).toList(),
      endpoint: url.path,
    );
  }

  static Future<List<Product>> getProductsData(
    http.Client client,
    String productIds,
  ) async {
    const fields =
        'vmp_id,vmp_name,price,rating,checkins,label_sm_url,main_category,'
        'sub_category,style,stock,abv,volume,price_per_volume,'
        'vmp_url,untpd_url,untpd_id,country,country_code';
    final endpoint = 'beers/?beers=$productIds&fields=$fields';

    return _handleRequest(
      request: () => client.get(Uri.parse('$_baseUrl$endpoint')),
      parser: (json) =>
          (json as List).map((item) => Product.fromJson(item)).toList(),
      endpoint: endpoint,
    );
  }

  static Future<void> submitUntappdMatch(
    http.Client client,
    int productId,
    String untappdUrl,
  ) async {
    const endpoint = 'wrongmatch/';
    final body = json.encode({
      'beer': productId,
      'suggested_url': untappdUrl,
    });

    try {
      final response = await client.post(
        Uri.parse('$_baseUrl$endpoint'),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode != 201) {
        throw ApiException(
          message: 'Kunne ikke sende inn forslag',
          statusCode: response.statusCode,
          endpoint: endpoint,
        );
      }
    } on SocketException {
      throw const NetworkException();
    }
  }

  static Future<List<Store>> getStoreList(http.Client client) async {
    const endpoint =
        'stores/?fields=store_id,name,gps_lat,gps_long&page_size=500';
    return _handleRequest(
      request: () => client.get(Uri.parse('$_baseUrl$endpoint')),
      parser: (json) =>
          (json as List).map((item) => Store.fromJson(item)).toList(),
      endpoint: endpoint,
    );
  }

  static Future<List<Country>> getActiveCountries(http.Client client) async {
    const endpoint = 'countries/active/';
    return _handleRequest(
      request: () => client.get(Uri.parse('$_baseUrl$endpoint')),
      parser: (json) =>
          (json as List).map((item) => Country.fromJson(item)).toList(),
      endpoint: endpoint,
      expectResultsKey: false,
    );
  }

  static Future<List<String>> getActiveStyles(http.Client client) async {
    const endpoint = 'beers/styles/';
    return _handleRequest(
      request: () => client.get(Uri.parse('$_baseUrl$endpoint')),
      parser: (json) => List<String>.from(json),
      endpoint: endpoint,
      expectResultsKey: false,
    );
  }

  static Future<List<Release>> getReleaseList(
    http.Client client, {
    required int page,
    required int pageSize,
  }) async {
    final endpoint =
        'release/?fields=name,release_date,product_selections,product_stats&page=$page&page_size=$pageSize';
    return _handleRequest(
      request: () => client.get(Uri.parse('$_baseUrl$endpoint')),
      parser: (json) =>
          (json as List).map((item) => Release.fromJson(item)).toList(),
      endpoint: endpoint,
    );
  }

  static Future<List<String>> getReleaseNames(http.Client client) async {
    const endpoint = 'release/?fields=name';
    return _handleRequest(
      request: () => client.get(Uri.parse('$_baseUrl$endpoint')),
      parser: (json) =>
          (json as List).map((item) => item['name'] as String).toList(),
      endpoint: endpoint,
    );
  }

  static Uri _buildProductUrl(int page, Filter filter, int pageSize) {
    const fields =
        'vmp_id,vmp_name,price,rating,checkins,label_sm_url,main_category,'
        'sub_category,style,stock,abv,volume,price_per_volume,vmp_url,'
        'untpd_url,untpd_id,country,country_code,product_selection';

    final params = <String, String>{
      'fields': fields,
      'active': 'True',
      'price_low': filter.priceLow,
      'price_high': filter.priceHigh,
      'ppv_high': filter.ppvHigh,
      'ppv_low': filter.ppvLow,
      'abv_high': filter.abvHigh,
      'abv_low': filter.abvLow,
      'ordering': filter.sortBy,
      'style': filter.style,
      'country': filter.country,
      'product_selection': filter.productSelection,
      'search': filter.search,
      'release': filter.release,
      'exclude_allergen': filter.excludeAllergens,
      'page': page.toString(),
      'page_size': pageSize.toString(),
    };

    if (filter.storeId.isNotEmpty) {
      params['store'] = filter.storeId;
    }
    if (filter.checkIn == 1 || filter.sortBy.contains('checkin__rating')) {
      params['user_checkin'] = 'True';
    } else if (filter.checkIn == 2) {
      params['user_checkin'] = 'False';
    }
    if (filter.wishlisted == 1) {
      params['user_wishlisted'] = 'True';
    } else if (filter.wishlisted == 2) {
      params['user_wishlisted'] = 'False';
    }
    if (filter.deliverySelectedList[0]) {
      params['store_delivery'] = 'True';
    }
    if (filter.deliverySelectedList[1]) {
      params['post_delivery'] = 'True';
    }

    return Uri.parse('${_baseUrl}beers/').replace(queryParameters: params);
  }

  static Uri _buildReleaseProductUrl(
    int page,
    Filter filter,
    Release release,
    int pageSize,
  ) {
    const fields =
        'vmp_id,vmp_name,price,rating,checkins,label_sm_url,main_category,'
        'sub_category,style,stock,abv,volume,price_per_volume,vmp_url,'
        'untpd_url,untpd_id,country,country_code,product_selection';

    final params = <String, String>{
      'fields': fields,
      'release': release.name,
      'ordering': filter.releaseSortBy,
      'page': page.toString(),
      'page_size': pageSize.toString(),
    };

    if (release.productSelections.length > 1) {
      params['product_selection'] = filter.releaseProductSelectionChoice;
    }

    return Uri.parse('${_baseUrl}beers/').replace(queryParameters: params);
  }
}
