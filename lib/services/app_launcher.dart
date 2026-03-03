import 'dart:io' show Platform;

import 'package:external_app_launcher/external_app_launcher.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/product.dart';
import '../utils/crash_reporter.dart';
import '../utils/environment.dart';

class AppLauncher {
  static Future<void> launchUntappd(Product product) async {
    try {
      var untappdInstalled = await LaunchApp.isAppInstalled(
        iosUrlScheme: 'untappd://',
        androidPackageName: 'com.untappdllc.app',
      );
      if (untappdInstalled == true || untappdInstalled == 1) {
        await launchUrl(Uri.parse('untappd://beer/${product.untappdId}'));
      } else {
        await launchUrl(Uri.parse(product.untappdUrl!));
      }
    } catch (e, st) {
      CrashReporter.recordError(e, st, reason: 'launchUntappd failed');
    }
  }

  static Future<void> launchFacebook() async {
    try {
      var facebookInstalled = await LaunchApp.isAppInstalled(
        iosUrlScheme: 'fb://',
        androidPackageName: 'com.facebook.katana',
      );
      final pageId = Environment.facebookPageId;
      if (facebookInstalled == true || facebookInstalled == 1) {
        if (Platform.isAndroid) {
          await launchUrl(Uri.parse('fb://page/$pageId'));
        }
        if (Platform.isIOS) {
          await launchUrl(Uri.parse('fb://profile/$pageId'));
        }
      } else {
        await launchUrl(Uri.parse(Environment.facebookUrl));
      }
    } catch (e, st) {
      CrashReporter.recordError(e, st, reason: 'launchFacebook failed');
    }
  }
}
