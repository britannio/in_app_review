import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_review_platform_interface/method_channel_in_app_review.dart';
import 'package:platform/platform.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late MethodChannelInAppReview methodChannelInAppReview;
  late List<MethodCall> log = [];
  const MethodChannel channel = MethodChannel('dev.britannio.in_app_review');

  setUp(() {
    methodChannelInAppReview = MethodChannelInAppReview();
    methodChannelInAppReview.channel = channel;
    log = <MethodCall>[];
  });

  tearDown(() {
    log.clear();
  });

  Future<Object?> mockMethodCallHandler(MethodCall call) async {
    log.add(call);

    switch (call.method) {
      case 'isAvailable':
        return true;
      case 'requestReview':
      case 'openStoreListing':
        return null;
      default:
        assert(false);
        return null;
    }
  }

  // Converts a nullable type to its non-nullable equivalent (backwards compatibility)
  (<T>(T? o) => o!)(TestDefaultBinaryMessengerBinding.instance)
      .defaultBinaryMessenger
      .setMockMethodCallHandler(channel, mockMethodCallHandler);

  group('isAvailable', () {
    test(
      'should invoke the isAvailable method channel',
      () async {
        // ACT
        final result = await methodChannelInAppReview.isAvailable();

        // ASSERT
        expect(log, <Matcher>[isMethodCall('isAvailable', arguments: null)]);
        expect(result, isTrue);
      },
    );

    test(
      'should return false when method channel throws',
      () async {
        // ARRANGE
        (<T>(T? o) => o!)(TestDefaultBinaryMessengerBinding.instance)
            .defaultBinaryMessenger
            .setMockMethodCallHandler(
              channel,
              (MethodCall call) async => throw PlatformException(code: 'error'),
            );

        // ACT
        final result = await methodChannelInAppReview.isAvailable();

        // ASSERT
        expect(result, isFalse);

        // RESET
        (<T>(T? o) => o!)(TestDefaultBinaryMessengerBinding.instance)
            .defaultBinaryMessenger
            .setMockMethodCallHandler(channel, mockMethodCallHandler);
      },
    );
  });

  group('requestReview', () {
    test(
      'should invoke the requestReview method channel',
      () async {
        // ACT
        await methodChannelInAppReview.requestReview();

        // ASSERT
        expect(log, <Matcher>[isMethodCall('requestReview', arguments: null)]);
      },
    );
  });

  group('openStoreListing', () {
    test(
      'should invoke the openStoreListing method channel on Android',
      () async {
        // ARRANGE
        methodChannelInAppReview.platform =
            FakePlatform(operatingSystem: 'android');

        // ACT
        await methodChannelInAppReview.openStoreListing();

        // ASSERT
        expect(
          log,
          <Matcher>[isMethodCall('openStoreListing', arguments: null)],
        );
      },
    );
    test(
      'should invoke the openStoreListing method channel on iOS',
      () async {
        // ARRANGE
        methodChannelInAppReview.platform =
            FakePlatform(operatingSystem: 'ios');
        final appStoreId = "store_id";

        // ACT
        await methodChannelInAppReview.openStoreListing(appStoreId: appStoreId);

        // ASSERT
        expect(log,
            <Matcher>[isMethodCall('openStoreListing', arguments: appStoreId)]);
      },
    );

    test(
      'should throw when appStoreId is missing on iOS',
      () async {
        // ARRANGE
        methodChannelInAppReview.platform =
            FakePlatform(operatingSystem: 'ios');

        // ACT + ASSERT
        expect(
          methodChannelInAppReview.openStoreListing(),
          throwsA(isA<ArgumentError>()),
        );
      },
    );

    test(
      'should invoke the openStoreListing method channel on MacOS',
      () async {
        // ARRANGE
        methodChannelInAppReview.platform =
            FakePlatform(operatingSystem: 'macos');
        final appStoreId = "store_id";

        // ACT
        await methodChannelInAppReview.openStoreListing(appStoreId: appStoreId);

        // ASSERT
        expect(log,
            <Matcher>[isMethodCall('openStoreListing', arguments: appStoreId)]);
      },
    );

    test(
      'should throw when appStoreId is missing on MacOS',
      () async {
        // ARRANGE
        methodChannelInAppReview.platform =
            FakePlatform(operatingSystem: 'macos');

        // ACT + ASSERT
        expect(
          methodChannelInAppReview.openStoreListing(),
          throwsA(isA<ArgumentError>()),
        );
      },
    );

    test(
      'should invoke the openStoreListing method channel on Windows',
      () async {
        // ARRANGE
        methodChannelInAppReview.platform =
            FakePlatform(operatingSystem: 'windows');
        final microsoftStoreId = 'store_id';

        // ACT
        await methodChannelInAppReview.openStoreListing(
          microsoftStoreId: microsoftStoreId,
        );

        // ASSERT
        expect(log, <Matcher>[
          isMethodCall('openStoreListing', arguments: microsoftStoreId)
        ]);
      },
      skip:
          'The windows uwp implementation still uses the url_launcher package',
    );

    test(
      'should throw when microsoftStoreId is missing on Windows',
      () async {
        // ARRANGE
        methodChannelInAppReview.platform =
            FakePlatform(operatingSystem: 'windows');

        // ACT + ASSERT
        expect(
          methodChannelInAppReview.openStoreListing(),
          throwsA(isA<ArgumentError>()),
        );
      },
    );

    test(
      'should throw UnsupportedError on unsupported platform',
      () async {
        // ARRANGE
        methodChannelInAppReview.platform =
            FakePlatform(operatingSystem: 'linux');

        // ACT + ASSERT
        expect(
          methodChannelInAppReview.openStoreListing(),
          throwsA(isA<UnsupportedError>()),
        );
      },
    );
  });
}
