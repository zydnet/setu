import 'package:flutter_test/flutter_test.dart';
import 'package:snapgive/main.dart';

void main() {
  testWidgets('App builds without errors', (WidgetTester tester) async {
    await tester.pumpWidget(const SnapGiveApp());
    expect(find.text('SnapGive'), findsOneWidget);
  });
}