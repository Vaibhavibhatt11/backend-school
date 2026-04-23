// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:erp_frontend/main.dart';

void main() {
  testWidgets('MyApp smoke test', (WidgetTester tester) async {
    // SplashScreen waits 2 seconds then reads the auth token from SharedPreferences.
    // In tests, SharedPreferences needs to be mocked to avoid platform-channel calls.
    SharedPreferences.setMockInitialValues({'auth_token': ''});

    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());
    // Advance time so SplashScreen's Future.delayed completes and the pending
    // timer is cleared before the widget tree gets disposed.
    await tester.pump(const Duration(seconds: 3));

    // If this builds without throwing and we have a GetMaterialApp, the app
    // setup/bindings are working for this basic test.
    expect(find.byType(GetMaterialApp), findsOneWidget);
  });
}
