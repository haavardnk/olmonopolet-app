import 'dart:io' show Platform;

import 'package:url_launcher/url_launcher.dart';

import '../models/product.dart';
import '../utils/crash_reporter.dart';
import '../utils/environment.dart';

class AppLauncher {
  static Future<void> launchUntappd(Product product) async {
    try {
      final appUri = Uri.parse('untappd://beer/${product.untappdId}');
      if (await canLaunchUrl(appUri)) {
        await launchUrl(appUri);
      } else {
        await launchUrl(
          Uri.parse(product.untappdUrl!),
          mode: LaunchMode.externalApplication,
        );
      }
    } catch (e, st) {
      CrashReporter.recordError(e, st, reason: 'launchUntappd failed');
    }
  }

  static Future<void> launchFacebook() async {
    try {
      final pageId = Environment.facebookPageId;
      final appUri = Uri.parse(
        Platform.isIOS ? 'fb://profile/$pageId' : 'fb://page/$pageId',
      );
      if (await canLaunchUrl(appUri)) {
        await launchUrl(appUri);
      } else {
        await launchUrl(
          Uri.parse(Environment.facebookUrl),
          mode: LaunchMode.externalApplication,
        );
      }
    } catch (e, st) {
      CrashReporter.recordError(e, st, reason: 'launchFacebook failed');
    }
  }
}
