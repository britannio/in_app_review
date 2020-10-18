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

  /// Check's if the device is able to show a review dialog.
  ///
  /// On Android the Google Play Store must be installed and the device must be
  /// running **Android 5 Lollipop(API 21)** or higher.
  ///
  /// IOS devices must be running **IOS version 10.3** or higher.
  ///
  /// MacOS devices must be running **MacOS version 10.14** or higher
  Future<bool> isAvailable() => _channel.invokeMethod('isAvailable');

  /// Attempts to show the review dialog. It's recommended to first check if
  /// this cannot be done via [isAvailable]. If it is not available then
  /// you can open the store listing via [openStoreListing].
  ///
  /// To improve the users experience, IOS and Android enforce limitations
  /// that might prevent this from working after a few tries. IOS & MacOS users
  /// can also disable this feature entirely in the App Store settings.
  ///
  /// More info and guidance:
  /// https://developer.android.com/guide/playcore/in-app-review#when-to-request
  /// https://developer.apple.com/design/human-interface-guidelines/ios/system-capabilities/ratings-and-reviews/
  /// https://developer.apple.com/design/human-interface-guidelines/macos/system-capabilities/ratings-and-reviews/
  Future<void> requestReview() => _channel.invokeMethod('requestReview');

  /// Opens the Play Store on Android and opens the App Store with a review
  /// screen on IOS & MacOS. [appStoreId] is required for IOS & MacOS.
  Future<void> openStoreListing({
    /// Required for IOS & MacOS.
    String appStoreId,

    /// Required for Windows.
    String windowsProductId,
  }) async {
    final bool isIOS = Platform.isIOS;
    final bool isMacOS = Platform.isMacOS;
    final bool isAndroid = Platform.isAndroid;
    final bool isWindows = Platform.isWindows;

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
    } else if (isWindows) {
      assert(windowsProductId != null);

      await _launchUrl(
        'ms-windows-store://review/?ProductId=$windowsProductId',
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
