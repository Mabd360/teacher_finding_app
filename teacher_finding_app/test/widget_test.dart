// Basic smoke test for Teacher Finder App
import 'package:flutter_test/flutter_test.dart';
import 'package:teacher_finding_app/main.dart';

void main() {
  testWidgets('App should build without errors', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const TeacherFinderApp());

    // Verify the app renders (splash screen shows Teacher Finder text)
    expect(find.text('Teacher Finder'), findsOneWidget);
  });
}
