import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/user_list.dart';
import '../utils/environment.dart';
import '../utils/exceptions.dart';

class ListApi {
  static String get _baseUrl => Environment.apiBaseUrl;

  static Map<String, String> _headers(String token) => {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

  static T _handleResponse<T>({
    required http.Response response,
    required T Function(dynamic json) parser,
    required String endpoint,
  }) {
    final statusCode = response.statusCode;

    if (statusCode >= 200 && statusCode < 300) {
      if (response.body.isEmpty) return parser(null);
      final decoded = json.decode(utf8.decode(response.bodyBytes));
      return parser(decoded);
    }

    switch (statusCode) {
      case 401:
        throw UnauthorizedException(endpoint: endpoint);
      case 404:
        throw NotFoundException(endpoint: endpoint);
      case 409:
        throw const ApiException(
          message: 'Produktet finnes allerede i listen',
          statusCode: 409,
        );
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

  static Future<List<UserList>> fetchLists(
    http.Client client,
    String token,
  ) async {
    const endpoint = 'lists/';
    try {
      final response = await client.get(
        Uri.parse('$_baseUrl$endpoint'),
        headers: _headers(token),
      );
      return _handleResponse(
        response: response,
        parser: (json) {
          final list = json is List ? json : (json['results'] as List);
          return list
              .map((e) => UserList.fromJson(e as Map<String, dynamic>))
              .toList();
        },
        endpoint: endpoint,
      );
    } on SocketException {
      throw const NetworkException();
    }
  }

  static Future<UserList> fetchList(
    http.Client client,
    String token,
    int listId,
  ) async {
    final endpoint = 'lists/$listId/';
    try {
      final response = await client.get(
        Uri.parse('$_baseUrl$endpoint'),
        headers: _headers(token),
      );
      return _handleResponse(
        response: response,
        parser: (json) =>
            UserList.fromJson(json as Map<String, dynamic>),
        endpoint: endpoint,
      );
    } on SocketException {
      throw const NetworkException();
    }
  }

  static Future<UserList> createList(
    http.Client client,
    String token, {
    required String name,
    String? description,
    required ListType listType,
    DateTime? eventDate,
  }) async {
    const endpoint = 'lists/';
    final body = <String, dynamic>{
      'name': name,
      'list_type': listType.apiValue,
    };
    if (description != null) body['description'] = description;
    if (eventDate != null) {
      body['event_date'] =
          '${eventDate.year}-${eventDate.month.toString().padLeft(2, '0')}-${eventDate.day.toString().padLeft(2, '0')}';
    }

    try {
      final response = await client.post(
        Uri.parse('$_baseUrl$endpoint'),
        headers: _headers(token),
        body: json.encode(body),
      );
      return _handleResponse(
        response: response,
        parser: (json) =>
            UserList.fromJson(json as Map<String, dynamic>),
        endpoint: endpoint,
      );
    } on SocketException {
      throw const NetworkException();
    }
  }

  static Future<UserList> updateList(
    http.Client client,
    String token,
    int listId, {
    String? name,
    String? description,
    ListType? listType,
    String? selectedStoreId,
    DateTime? eventDate,
  }) async {
    final endpoint = 'lists/$listId/';
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (description != null) body['description'] = description;
    if (listType != null) body['list_type'] = listType.apiValue;
    if (selectedStoreId != null) {
      body['selected_store_id'] = int.tryParse(selectedStoreId);
    }
    if (eventDate != null) {
      body['event_date'] =
          '${eventDate.year}-${eventDate.month.toString().padLeft(2, '0')}-${eventDate.day.toString().padLeft(2, '0')}';
    }

    try {
      final response = await client.patch(
        Uri.parse('$_baseUrl$endpoint'),
        headers: _headers(token),
        body: json.encode(body),
      );
      return _handleResponse(
        response: response,
        parser: (json) =>
            UserList.fromJson(json as Map<String, dynamic>),
        endpoint: endpoint,
      );
    } on SocketException {
      throw const NetworkException();
    }
  }

  static Future<void> deleteList(
    http.Client client,
    String token,
    int listId,
  ) async {
    final endpoint = 'lists/$listId/';
    try {
      final response = await client.delete(
        Uri.parse('$_baseUrl$endpoint'),
        headers: _headers(token),
      );
      _handleResponse(
        response: response,
        parser: (_) => null,
        endpoint: endpoint,
      );
    } on SocketException {
      throw const NetworkException();
    }
  }

  static Future<void> reorderLists(
    http.Client client,
    String token,
    List<int> listIds,
  ) async {
    const endpoint = 'lists/reorder/';
    try {
      final response = await client.patch(
        Uri.parse('$_baseUrl$endpoint'),
        headers: _headers(token),
        body: json.encode({'list_ids': listIds}),
      );
      _handleResponse(
        response: response,
        parser: (_) => null,
        endpoint: endpoint,
      );
    } on SocketException {
      throw const NetworkException();
    }
  }

  static Future<ListItem> addItem(
    http.Client client,
    String token,
    int listId, {
    required String productId,
    int quantity = 1,
    int? year,
    String? notes,
  }) async {
    final endpoint = 'lists/$listId/items/';
    final body = <String, dynamic>{
      'product_id': int.tryParse(productId) ?? productId,
      'quantity': quantity,
    };
    if (year != null) body['year'] = year;
    if (notes != null) body['notes'] = notes;

    try {
      final response = await client.post(
        Uri.parse('$_baseUrl$endpoint'),
        headers: _headers(token),
        body: json.encode(body),
      );
      return _handleResponse(
        response: response,
        parser: (json) =>
            ListItem.fromJson(json as Map<String, dynamic>),
        endpoint: endpoint,
      );
    } on SocketException {
      throw const NetworkException();
    }
  }

  static Future<ListItem> updateItem(
    http.Client client,
    String token,
    int listId,
    int itemId, {
    int? quantity,
    int? year,
    String? notes,
  }) async {
    final endpoint = 'lists/$listId/items/$itemId/';
    final body = <String, dynamic>{};
    if (quantity != null) body['quantity'] = quantity;
    if (year != null) body['year'] = year;
    if (notes != null) body['notes'] = notes;

    try {
      final response = await client.patch(
        Uri.parse('$_baseUrl$endpoint'),
        headers: _headers(token),
        body: json.encode(body),
      );
      return _handleResponse(
        response: response,
        parser: (json) =>
            ListItem.fromJson(json as Map<String, dynamic>),
        endpoint: endpoint,
      );
    } on SocketException {
      throw const NetworkException();
    }
  }

  static Future<void> removeItem(
    http.Client client,
    String token,
    int listId,
    int itemId,
  ) async {
    final endpoint = 'lists/$listId/items/$itemId/';
    try {
      final response = await client.delete(
        Uri.parse('$_baseUrl$endpoint'),
        headers: _headers(token),
      );
      _handleResponse(
        response: response,
        parser: (_) => null,
        endpoint: endpoint,
      );
    } on SocketException {
      throw const NetworkException();
    }
  }

  static Future<void> reorderItems(
    http.Client client,
    String token,
    int listId,
    List<int> itemIds,
  ) async {
    final endpoint = 'lists/$listId/items/reorder/';
    try {
      final response = await client.patch(
        Uri.parse('$_baseUrl$endpoint'),
        headers: _headers(token),
        body: json.encode({'item_ids': itemIds}),
      );
      _handleResponse(
        response: response,
        parser: (_) => null,
        endpoint: endpoint,
      );
    } on SocketException {
      throw const NetworkException();
    }
  }

  static Future<SharedUserList> fetchSharedList(
    http.Client client,
    String shareToken,
  ) async {
    final endpoint = 'lists/shared/$shareToken/';
    try {
      final response = await client.get(
        Uri.parse('$_baseUrl$endpoint'),
      );
      return _handleResponse(
        response: response,
        parser: (json) =>
            SharedUserList.fromJson(json as Map<String, dynamic>),
        endpoint: endpoint,
      );
    } on SocketException {
      throw const NetworkException();
    }
  }
}
