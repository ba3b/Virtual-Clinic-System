// This is a basic Flutter widget test.
//
// Verifies that the app starts without crashing.

import 'package:flutter_test/flutter_test.dart';

import 'package:virtual_clinic_system/localization/locale_provider.dart';
import 'package:virtual_clinic_system/main.dart';

void main() {
  testWidgets('App starts without crashing', (WidgetTester tester) async {
    final localeProvider = LocaleProvider();
    await tester.pumpWidget(MyApp(localeProvider: localeProvider));
    // Just verify it builds without throwing.
    expect(find.byType(MyApp), findsOneWidget);
  });
}
