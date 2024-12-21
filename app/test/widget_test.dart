import 'package:flutter_test/flutter_test.dart';
import 'package:app/app.dart'; // Verweis auf die neue Datei

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp());
  });
}
