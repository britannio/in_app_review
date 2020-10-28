import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_review_platform_interface/method_channel_in_app_review.dart';
import 'package:mockito/mockito.dart';

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
}

class MockMethodChannel extends Mock implements MethodChannel {}
