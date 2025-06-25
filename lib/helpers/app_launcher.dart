import 'package:external_app_launcher/external_app_launcher.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io' show Platform;

import '../models/product.dart';
import '../utils/environment.dart';

class AppLauncher {
  static Future<void> launchUntappd(Product product) async {
    var untappdInstalled = await LaunchApp.isAppInstalled(
      iosUrlScheme: 'untappd://',
      androidPackageName: 'com.untappdllc.app',
    );
    if (untappdInstalled == true || untappdInstalled == 1) {
      launchUrl(Uri.parse('untappd://beer/${product.untappdId}'));
    } else {
      launchUrl(Uri.parse(product.untappdUrl!));
    }
  }

  static Future<void> launchFacebook() async {
    var facebookInstalled = await LaunchApp.isAppInstalled(
      iosUrlScheme: 'fb://',
      androidPackageName: 'com.facebook.katana',
    );
    final pageId = Environment.facebookPageId;
    if (facebookInstalled == true || facebookInstalled == 1) {
      if (Platform.isAndroid) {
        launchUrl(Uri.parse('fb://page/$pageId'));
      }
      if (Platform.isIOS) {
        launchUrl(Uri.parse('fb://profile/$pageId'));
      }
    } else {
      launchUrl(Uri.parse(Environment.facebookUrl));
    }
  }
}
