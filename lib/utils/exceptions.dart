class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? endpoint;

  const ApiException({
    required this.message,
    this.statusCode,
    this.endpoint,
  });

  @override
  String toString() =>
      'ApiException: $message${statusCode != null ? ' (Status: $statusCode)' : ''}${endpoint != null ? ' [Endpoint: $endpoint]' : ''}';
}

class NetworkException implements Exception {
  final String message;

  const NetworkException([this.message = 'Ingen internettforbindelse']);

  @override
  String toString() => 'NetworkException: $message';
}

class ServerException extends ApiException {
  const ServerException({
    required super.message,
    super.statusCode,
    super.endpoint,
  });
}

class NotFoundException extends ApiException {
  const NotFoundException({
    super.message = 'Ressurs ikke funnet',
    super.statusCode = 404,
    super.endpoint,
  });
}

class UnauthorizedException extends ApiException {
  const UnauthorizedException({
    super.message = 'Ikke autorisert',
    super.statusCode = 401,
    super.endpoint,
  });
}
