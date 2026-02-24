import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../utils/exceptions.dart';

T handleApiResponse<T>({
  required http.Response response,
  required T Function(dynamic json) parser,
  required String endpoint,
  bool expectResultsKey = false,
  Map<int, ApiException> customErrors = const {},
}) {
  final statusCode = response.statusCode;

  if (statusCode >= 200 && statusCode < 300) {
    if (response.body.isEmpty) return parser(null);
    final decoded = json.decode(utf8.decode(response.bodyBytes));
    final data = expectResultsKey ? decoded['results'] : decoded;
    return parser(data);
  }

  if (customErrors.containsKey(statusCode)) {
    throw customErrors[statusCode]!;
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

Future<T> handleApiRequest<T>({
  required Future<http.Response> Function() request,
  required T Function(dynamic json) parser,
  required String endpoint,
  bool expectResultsKey = false,
  Map<int, ApiException> customErrors = const {},
}) async {
  try {
    final response = await request();
    return handleApiResponse(
      response: response,
      parser: parser,
      endpoint: endpoint,
      expectResultsKey: expectResultsKey,
      customErrors: customErrors,
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
