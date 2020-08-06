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
  /// running Android Lollipop(API 21) or higher.
  ///
  /// IOS devices must be running IOS version 10.3 or higher.
  Future<bool> isAvailable() => _channel.invokeMethod('isAvailable');

  /// Attempts to show the review dialog. It's recommended to first check if
  /// this cannot be done via [isAvailable]. If it is not available then
  /// you can open the store listing via [openStoreListing].
  ///
  /// To improve the users experience, IOS and Android enforce limitations
  /// that might prevent this from working after a few tries. IOS users can also
  /// disable this feature entirely in settings.
  ///
  /// More info and guidance:
  /// https://developer.apple.com/design/human-interface-guidelines/ios/system-capabilities/ratings-and-reviews/
  /// https://developer.android.com/guide/playcore/in-app-review#when-to-request
  Future<void> requestReview() => _channel.invokeMethod('requestReview');

  /// Opens the Play Store on Android and opens the App Store with a review
  /// screen on IOS. [iOSAppStoreId] is required on IOS.
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
