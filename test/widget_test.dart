import 'package:flutter_test/flutter_test.dart';
import 'package:allosante_benin/main.dart';

void main() {
  testWidgets('AlloSante app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const AlloSanteApp());

    // Verify the app launches with splash screen
    expect(find.text('AlloSanté'), findsOneWidget);
    expect(find.text('Votre santé, notre affaire au quotidien'), findsOneWidget);
  });
}
