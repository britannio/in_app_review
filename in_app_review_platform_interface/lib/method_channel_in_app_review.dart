import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:platform/platform.dart';
import 'package:url_launcher/url_launcher.dart';

import 'in_app_review_platform_interface.dart';

/// An implementation of [UrlLauncherPlatform] that uses method channels.
class MethodChannelInAppReview extends InAppReviewPlatform {
  MethodChannel _channel = MethodChannel('dev.britannio.in_app_review');
  Platform _platform = const LocalPlatform();

  @visibleForTesting
  set channel(MethodChannel channel) => _channel = channel;

  @visibleForTesting
  set platform(Platform platform) => _platform = platform;

  @override
  Future<bool> isAvailable() => _channel.invokeMethod('isAvailable');

  @override
  Future<void> requestReview() => _channel.invokeMethod('requestReview');

  @override
  Future<void> openStoreListing({
    String appStoreId,
    String microsoftStoreId,
  }) async {
    final bool isIOS = _platform.isIOS;
    final bool isMacOS = _platform.isMacOS;
    final bool isAndroid = _platform.isAndroid;
    final bool isWindows = _platform.isWindows;

    if (isIOS || isMacOS) {
      assert(appStoreId != null);
      await _channel.invokeMethod('openStoreListing', appStoreId);
    } else if (isAndroid) {
      await _channel.invokeMethod('openStoreListing');
    } else if (isWindows) {
      assert(microsoftStoreId != null);

      await _launchUrl(
        'ms-windows-store://review/?ProductId=$microsoftStoreId',
      );
    } else {
      throw UnsupportedError('Platform not supported');
    }
  }

  Future<void> _launchUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url, forceSafariVC: false, forceWebView: false);
    }
  }
}
