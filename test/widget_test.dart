// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:doodle_disaster/main.dart';

void main() {
  testWidgets('Home screen displays correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: DoodleDisasterApp()));

    // Verify the app title is displayed
    expect(find.text('Doodle'), findsOneWidget);
    expect(find.text('Disaster'), findsOneWidget);

    // Verify the tagline
    expect(find.text('Draw it. Pass it. Watch it fall apart!'), findsOneWidget);

    // Verify the main buttons
    expect(find.text('Create Game'), findsOneWidget);
    expect(find.text('Join Game'), findsOneWidget);

    // Verify the test canvas button
    expect(find.text('Test Canvas'), findsOneWidget);
  });
}
