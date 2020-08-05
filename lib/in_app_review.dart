import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:package_info/package_info.dart';
import 'package:url_launcher/url_launcher.dart';

class InAppReview {
  InAppReview._();

  static final InAppReview instance = InAppReview._();

  static const MethodChannel _channel =
      const MethodChannel('dev.britannio.in_app_review');

  Future<bool> isAvailable() => _channel.invokeMethod('isAvailable');

  Future<void> requestReview() => _channel.invokeMethod('requestReview');

  Future<void> openStoreListing({String iOSAppStoreId}) async {
    if (Platform.isIOS) {
      assert(iOSAppStoreId != null);

      _launchUrl(
        'https://apps.apple.com/app/id$iOSAppStoreId?action=write-review',
      );
    } else if (Platform.isAndroid) {
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();

      final String packageName = packageInfo.packageName;

      _launchUrl('https://play.google.com/store/apps/details?id=$packageName');
    } else {
      throw UnsupportedError('Platform not supported');
    }
  }

  Future<void> _launchUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    }
  }
}
