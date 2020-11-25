import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_review_platform_interface/method_channel_in_app_review.dart';
import 'package:mockito/mockito.dart';
import 'package:platform/platform.dart';

void main() {
  final MethodChannelInAppReview methodChannelInAppReview =
      MethodChannelInAppReview();
  MethodChannel channel;

  setUp(() {
    channel = MockMethodChannel();
    methodChannelInAppReview.channel = channel;
  });

  group('isAvailable', () {
    test(
      'should invoke the isAvailable channel method',
      () async {
        // ACT
        await methodChannelInAppReview.isAvailable();

        // ASSERT
        verify(channel.invokeMethod('isAvailable'));
        verifyNoMoreInteractions(channel);
      },
    );
  });
  group('requestReview', () {
    test(
      'should invoke the requestReview channel method',
      () async {
        // ACT
        await methodChannelInAppReview.requestReview();

        // ASSERT
        verify(channel.invokeMethod('requestReview'));
        verifyNoMoreInteractions(channel);
      },
    );
  });

  group('openStoreListing', () {
    test(
      'should invoke the openStoreListing channel method on Android',
      () async {
        // ARRANGE
        methodChannelInAppReview.platform =
            FakePlatform(operatingSystem: 'android');

        // ACT
        await methodChannelInAppReview.openStoreListing();

        // ASSERT
        verify(channel.invokeMethod('openStoreListing'));
        verifyNoMoreInteractions(channel);
      },
    );
    test(
      'should invoke the openStoreListing channel method on IOS',
      () async {
        // ARRANGE
        methodChannelInAppReview.platform =
            FakePlatform(operatingSystem: 'ios');
        final appStoreId = "store_id";

        // ACT
        await methodChannelInAppReview.openStoreListing(appStoreId: appStoreId);

        // ASSERT
        verify(channel.invokeMethod('openStoreListing', appStoreId));
        verifyNoMoreInteractions(channel);
      },
    );
    test(
      'should invoke the openStoreListing channel method on MacOS',
      () async {
        // ARRANGE
        methodChannelInAppReview.platform =
            FakePlatform(operatingSystem: 'macos');
        final appStoreId = "store_id";

        // ACT
        await methodChannelInAppReview.openStoreListing(appStoreId: appStoreId);

        // ASSERT
        verify(channel.invokeMethod('openStoreListing', appStoreId));
        verifyNoMoreInteractions(channel);
      },
    );
    test(
      'should invoke the openStoreListing channel method on Windows',
      () async {
        // ARRANGE
        methodChannelInAppReview.platform =
            FakePlatform(operatingSystem: 'windows');
        final microsoftStoreId = 'store_id';

        // ACT
        await methodChannelInAppReview.openStoreListing(
            microsoftStoreId: microsoftStoreId);

        // ASSERT
        verify(channel.invokeMethod('openStoreListing', microsoftStoreId));
        verifyNoMoreInteractions(channel);
      },
      skip:
          'The windows uwp implementation still uses the url_launcher package',
    );
  });
}

class MockMethodChannel extends Mock implements MethodChannel {}
