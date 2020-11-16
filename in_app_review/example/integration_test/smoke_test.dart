import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets("smoke test", (WidgetTester tester) async {
    final inAppReview = InAppReview.instance;
    expect(await inAppReview.isAvailable(), isNotNull);
  });
}
