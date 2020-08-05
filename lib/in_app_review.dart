import 'dart:async';

import 'package:flutter/services.dart';

class InAppReview {
  InAppReview._();

  static final InAppReview instance = InAppReview._();

  static const MethodChannel _channel =
      const MethodChannel('dev.britannio.in_app_review');

  Future<bool> isAvailable() => _channel.invokeMethod('isAvailable');

  Future<void> requestReview() => _channel.invokeMethod('requestReview');
}
