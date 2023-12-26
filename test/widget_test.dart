import 'package:ai_image_analysis/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('AI Image Analysis App Test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const App());
  });
}
