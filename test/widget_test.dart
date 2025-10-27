import 'package:flutter_test/flutter_test.dart';

import 'package:number_game_app/main.dart';

void main() {
  testWidgets('Game selection page shows correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the game selection page is shown
    expect(find.text('ゲーム選択'), findsOneWidget);
    expect(find.text('ヌメロン'), findsOneWidget);
    expect(find.text('4桁の数字を当てよう！'), findsOneWidget);
  });

  testWidgets('Can navigate to Numeron game', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Tap the Numeron game button
    await tester.tap(find.text('ヌメロン'));
    await tester.pumpAndSettle();

    // Verify that we navigated to the Numeron game page
    expect(find.text('ルール説明'), findsOneWidget);
    expect(find.text('試行回数: 0'), findsOneWidget);
  });
}
