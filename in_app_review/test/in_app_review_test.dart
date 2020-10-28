import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:in_app_review_platform_interface/in_app_review_platform_interface.dart';
import 'package:mockito/mockito.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

void main() {
  final inAppReview = InAppReview.instance;
  MockInAppReviewPlatform platform;

  setUp(() {
    platform = MockInAppReviewPlatform();
    InAppReviewPlatform.instance = platform;
  });

  group('isAvailable', () {
    test(
      'should call InAppReviewPlatform.isAvailable()',
      () async {
        // ACT
        await inAppReview.isAvailable();

        // ASSERT
        verify(platform.isAvailable());
        verifyNoMoreInteractions(platform);
      },
    );
  });
  group('requestReview', () {
    test(
      'should call InAppReviewPlatform.requestReview()',
      () async {
        // ACT
        await inAppReview.requestReview();

        // ASSERT
        verify(platform.requestReview());
        verifyNoMoreInteractions(platform);
      },
    );
  });
  group('openStoreListing', () {
    test(
      'should call InAppReviewPlatform.openStoreListing()',
      () async {
        // ARRANGE
        final appStoreId = 'app_store_id';
        final microsoftStoreId = 'microsoft_store_id';

        // ACT
        await inAppReview.openStoreListing(
          appStoreId: appStoreId,
          microsoftStoreId: microsoftStoreId,
        );

        // ASSERT
        verify(platform.openStoreListing(
          appStoreId: appStoreId,
          microsoftStoreId: microsoftStoreId,
        ));
        verifyNoMoreInteractions(platform);
      },
    );
  });
}

class MockInAppReviewPlatform extends Mock
    with MockPlatformInterfaceMixin
    implements InAppReviewPlatform {}
