import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scheduling_app/main.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_core/firebase_core.dart';

// Mock classes for Firebase and Google Sign-In
class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockGoogleSignIn extends Mock implements GoogleSignIn {}
class MockFirebaseApp extends Mock implements FirebaseApp {}

void main() {
  // Mock Firebase initialization
  setUpAll(() async {
    // Skipping real Firebase initialization in tests
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Mock FirebaseAuth and GoogleSignIn
    final mockAuth = MockFirebaseAuth();
    final mockGoogleSignIn = MockGoogleSignIn();

    // Build the app with the MyHomePage widget
    await tester.pumpWidget(
      MaterialApp(
        home: MyHomePage(title: 'Test Title'),
      ),
    );

    // Verify that the counter starts at 0
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that the counter has incremented
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
