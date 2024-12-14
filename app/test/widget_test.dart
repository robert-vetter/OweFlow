import 'package:flutter_test/flutter_test.dart';
import 'package:app/app.dart'; // Verweis auf die neue Datei

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verifiziere, dass der Text "Hallo, Welt!" angezeigt wird.
    expect(find.text('Hallo, Welt!'), findsOneWidget);
  });
}
