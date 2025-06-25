import 'package:flutter_dotenv/flutter_dotenv.dart';

class Environment {
  static String? get(String key) {
    return dotenv.env[key];
  }

  static String getApiUrl(String key) {
    final value = get(key);
    if (value == null || value.isEmpty) {
      throw EnvironmentException('Missing required environment variable: $key');
    }
    return value;
  }

  static String get apiBaseUrl => getApiUrl('API_BASE_URL');
  static String get facebookUrl => getApiUrl('FACEBOOK_URL');
  static String get facebookPageId => getApiUrl('FACEBOOK_PAGE_ID');
  static String get feedbackEmail => getApiUrl('FEEDBACK_EMAIL');
}

class EnvironmentException implements Exception {
  final String message;
  EnvironmentException(this.message);

  @override
  String toString() => 'EnvironmentException: $message';
}
