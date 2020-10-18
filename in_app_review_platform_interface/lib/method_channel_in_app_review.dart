import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:package_info/package_info.dart';
import 'package:url_launcher/url_launcher.dart';

import 'in_app_review_platform_interface.dart';

const MethodChannel _channel = MethodChannel('dev.britannio.in_app_review');

/// An implementation of [UrlLauncherPlatform] that uses method channels.
class MethodChannelInAppReview extends InAppReviewPlatform {
  @override
  Future<bool> isAvailable() => _channel.invokeMethod('isAvailable');

  @override
  Future<void> requestReview() => _channel.invokeMethod('requestReview');

  @override
  Future<void> openStoreListing({
    String appStoreId,
    String windowsProductId,
  }) async {
    final bool isIOS = Platform.isIOS;
    final bool isMacOS = Platform.isMacOS;
    final bool isAndroid = Platform.isAndroid;

    if (isIOS || isMacOS) {
      assert(appStoreId != null);

      final Uri uri = Uri(
        scheme: isIOS ? 'https' : 'macappstore',
        host: 'apps.apple.com',
        path: 'app/id$appStoreId',
        queryParameters: {'action': 'write-review'},
      );

      await _launchUrl(uri.toString());
    } else if (isAndroid) {
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();

      final String packageName = packageInfo.packageName;

      await _launchUrl(
        'https://play.google.com/store/apps/details?id=$packageName',
      );
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
