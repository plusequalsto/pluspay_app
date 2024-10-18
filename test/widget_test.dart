import 'package:fluro/fluro.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pluspay/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    final router = FluroRouter();
    // Build our app and trigger a frame.
    await tester.pumpWidget(Main(
      title: '+Pay',
      router: router,
    ));
  });
}
