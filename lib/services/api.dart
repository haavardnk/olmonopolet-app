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

  static Map<String, String> _authHeaders(String? token) {
    if (token == null) return {};
    return {'Authorization': 'Bearer $token'};
  }

  static Future<Product> getProductDetails(
    http.Client client,
    Product product, {
    String? token,
  }) async {
    const fields =
        'vmp_id,vmp_name,style,sub_category,main_category,stock,price,volume,'
        'price_per_volume,price_per_alcohol_unit,rating,checkins,abv,label_sm_url,vmp_url,untpd_url,'
        'untpd_id,country,country_code,product_selection,label_hd_url,ibu,'
        'description,brewery,year,color,aroma,taste,storable,food_pairing,'
        'raw_materials,fullness,sweetness,freshness,bitterness,sugar,acid,'
        'method,allergens,alcohol_units,all_stock,value_score,is_christmas_beer,user_tasted';
    final endpoint = 'beers/?beers=${product.id}&fields=$fields&all_stock=true';
    return _handleRequest(
      request: () => client.get(
        Uri.parse('$_baseUrl$endpoint'),
        headers: _authHeaders(token),
      ),
      parser: (json) => Product.fromJson(
        (json as List).first as Map<String, dynamic>,
      ),
      endpoint: endpoint,
    );
  }

  static Future<Product> getProductById(
    http.Client client,
    int productId, {
    String? token,
  }) async {
    final endpoint = 'beers/?beers=$productId&all_stock=true';
    return _handleRequest(
      request: () => client.get(
        Uri.parse('$_baseUrl$endpoint'),
        headers: _authHeaders(token),
      ),
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
    String? token,
  }) async {
    final endpoint = 'stockchange/?store=$store&page=$page&page_size=$pageSize';
    return _handleRequest(
      request: () => client.get(
        Uri.parse('$_baseUrl$endpoint'),
        headers: _authHeaders(token),
      ),
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
    String? token,
  }) async {
    final url = release == null
        ? _buildProductUrl(page, filter, pageSize)
        : _buildReleaseProductUrl(page, filter, release, pageSize);

    return _handleRequest(
      request: () => client.get(url, headers: _authHeaders(token)),
      parser: (json) =>
          (json as List).map((item) => Product.fromJson(item)).toList(),
      endpoint: url.path,
    );
  }

  static Future<void> markTasted(
    http.Client client,
    int productId,
    String token,
  ) async {
    final endpoint = 'beers/$productId/mark_tasted/';
    try {
      final response = await client.post(
        Uri.parse('$_baseUrl$endpoint'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ApiException(
          message: 'Kunne ikke markere som smakt',
          statusCode: response.statusCode,
          endpoint: endpoint,
        );
      }
    } on SocketException {
      throw const NetworkException();
    }
  }

  static Future<void> unmarkTasted(
    http.Client client,
    int productId,
    String token,
  ) async {
    final endpoint = 'beers/$productId/mark_tasted/';
    try {
      final response = await client.delete(
        Uri.parse('$_baseUrl$endpoint'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ApiException(
          message: 'Kunne ikke fjerne smakt-markering',
          statusCode: response.statusCode,
          endpoint: endpoint,
        );
      }
    } on SocketException {
      throw const NetworkException();
    }
  }

  static Future<List<Product>?> getProductsByIds(
    http.Client client,
    String productIds, {
    String? token,
  }) async {
    const fields =
        'vmp_id,vmp_name,price,rating,checkins,label_sm_url,main_category,'
        'sub_category,style,stock,abv,volume,price_per_volume,price_per_alcohol_unit,'
        'vmp_url,untpd_url,untpd_id,country,country_code,is_christmas_beer,user_tasted';
    final endpoint = 'beers/?beers=$productIds&fields=$fields';

    return _handleRequest(
      request: () => client.get(
        Uri.parse('$_baseUrl$endpoint'),
        headers: _authHeaders(token),
      ),
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
        'release/?fields=name,release_date,product_selections,product_stats,is_christmas_release&page=$page&page_size=$pageSize';
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

  static Future<List<Country>> getReleaseCountries(
    http.Client client,
    String releaseName,
  ) async {
    final encodedName = Uri.encodeComponent(releaseName);
    final endpoint = 'release/$encodedName/countries/';
    return _handleRequest(
      request: () => client.get(Uri.parse('$_baseUrl$endpoint')),
      parser: (json) =>
          (json as List).map((item) => Country.fromJson(item)).toList(),
      endpoint: endpoint,
      expectResultsKey: false,
    );
  }

  static Future<List<String>> getReleaseStyles(
    http.Client client,
    String releaseName,
  ) async {
    final encodedName = Uri.encodeComponent(releaseName);
    final endpoint = 'release/$encodedName/styles/';
    return _handleRequest(
      request: () => client.get(Uri.parse('$_baseUrl$endpoint')),
      parser: (json) => List<String>.from(json),
      endpoint: endpoint,
      expectResultsKey: false,
    );
  }

  static Uri _buildProductUrl(int page, Filter filter, int pageSize) {
    const fields =
        'vmp_id,vmp_name,price,rating,checkins,label_sm_url,main_category,'
        'sub_category,style,stock,abv,volume,price_per_volume,price_per_alcohol_unit,vmp_url,'
        'untpd_url,untpd_id,country,country_code,product_selection,is_christmas_beer,user_tasted';

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
      'main_category': filter.mainCategory,
      'page': page.toString(),
      'page_size': pageSize.toString(),
    };

    if (filter.storeId.isNotEmpty) {
      params['store'] = filter.storeId;
    }
    if (filter.deliverySelectedList[0]) {
      params['store_delivery'] = 'True';
    }
    if (filter.deliverySelectedList[1]) {
      params['post_delivery'] = 'True';
    }
    if (filter.christmasBeerOnly) {
      params['is_christmas_beer'] = 'true';
    }
    if (filter.userTasted.isNotEmpty) {
      params['user_tasted'] = filter.userTasted;
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
        'sub_category,style,stock,abv,volume,price_per_volume,price_per_alcohol_unit,vmp_url,'
        'untpd_url,untpd_id,country,country_code,product_selection,is_christmas_beer,user_tasted';

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

    if (filter.releasePriceLow.isNotEmpty) {
      params['price_low'] = filter.releasePriceLow;
    }
    if (filter.releasePriceHigh.isNotEmpty) {
      params['price_high'] = filter.releasePriceHigh;
    }
    if (filter.releaseAbvLow.isNotEmpty) {
      params['abv_low'] = filter.releaseAbvLow;
    }
    if (filter.releaseAbvHigh.isNotEmpty) {
      params['abv_high'] = filter.releaseAbvHigh;
    }
    if (filter.releaseStyle.isNotEmpty) {
      params['style'] = filter.releaseStyle;
    }
    if (filter.releaseCountry.isNotEmpty) {
      params['country'] = filter.releaseCountry;
    }
    if (filter.releaseMainCategory.isNotEmpty) {
      params['main_category'] = filter.releaseMainCategory;
    }
    if (filter.releaseExcludeAllergens.isNotEmpty) {
      params['exclude_allergen'] = filter.releaseExcludeAllergens;
    }
    if (filter.releaseSearch.isNotEmpty) {
      params['search'] = filter.releaseSearch;
    }
    if (filter.releaseChristmasBeerOnly) {
      params['is_christmas_beer'] = 'true';
    }

    return Uri.parse('${_baseUrl}beers/').replace(queryParameters: params);
  }
}
