import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paejae_pick_2_app/main.dart';
import 'package:paejae_pick_2_app/smart_mobility.dart';

void main() {
  testWidgets('smart mobility hub exposes all three MVP flows', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: SmartMobilityHubScreen())),
    );

    expect(find.text('3D 실내지도'), findsOneWidget);
    expect(find.text('자율주행 픽업'), findsOneWidget);
    expect(find.text('자율배송'), findsOneWidget);
  });

  testWidgets('indoor map can search by room number', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: IndoorMapScreen()));

    await tester.enterText(find.byType(TextField), 'J408');
    await tester.pump();

    expect(find.textContaining('J408'), findsOneWidget);
  });

  testWidgets('main navigation opens the smart mobility hub', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: MainShell()));

    await tester.tap(find.text('스마트맵'));
    await tester.pump();

    expect(find.text('스마트 이동'), findsOneWidget);
  });
}
