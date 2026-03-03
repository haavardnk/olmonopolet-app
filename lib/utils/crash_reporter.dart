import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

import 'exceptions.dart';

class CrashReporter {
  static FirebaseCrashlytics get _instance => FirebaseCrashlytics.instance;

  static Future<void> recordError(
    dynamic error,
    StackTrace? stackTrace, {
    String? reason,
    bool fatal = false,
  }) async {
    if (kDebugMode) {
      debugPrint('CrashReporter: $error');
      return;
    }
    if (error is NetworkException ||
        error is NotFoundException ||
        error is UnauthorizedException) {
      log(error.toString());
      return;
    }
    if (error is ApiException) {
      if (error.endpoint != null) {
        _instance.setCustomKey('endpoint', error.endpoint!);
      }
      if (error.statusCode != null) {
        _instance.setCustomKey('statusCode', error.statusCode!);
      }
    }
    await _instance.recordError(
      error,
      stackTrace,
      reason: reason ?? error.toString(),
      fatal: fatal,
    );
  }

  static void log(String message) {
    if (kDebugMode) {
      debugPrint('CrashReporter: $message');
      return;
    }
    _instance.log(message);
  }

  static void setUserId(String? uid) {
    _instance.setUserIdentifier(uid ?? '');
  }
}
