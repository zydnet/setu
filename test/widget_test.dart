import 'package:flutter_test/flutter_test.dart';
import 'package:setu/main.dart';

void main() {
  testWidgets('App builds without errors', (WidgetTester tester) async {
    await tester.pumpWidget(const SetuApp());
    expect(find.text('setu'), findsOneWidget);
  });
}