import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:playtogether_ai/main.dart';

void main() {
  testWidgets('PlayTogether AI App loads smoke test', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const PlayTogetherApp());
    expect(find.text('PlayTogether AI'), findsWidgets);
  });
}
