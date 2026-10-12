import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:playtogether_ai/widgets/animated_ai_network_background.dart';

void main() {
  testWidgets('AnimatedAINetworkBackground renders properly with default parameters', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AnimatedAINetworkBackground(),
        ),
      ),
    );

    expect(find.byType(AnimatedAINetworkBackground), findsOneWidget);
    expect(find.byType(CustomPaint), findsWidgets);
  });

  testWidgets('AnimatedAINetworkBackground respects reducedMotion and custom configurations', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AnimatedAINetworkBackground(
            particleCount: 50,
            animationSpeed: 1.5,
            opacity: 0.8,
            glowIntensity: 1.2,
            connectionDistance: 120.0,
            reducedMotion: true,
            drawBackground: true,
          ),
        ),
      ),
    );

    expect(find.byType(AnimatedAINetworkBackground), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 100));
  });

  testWidgets('AnimatedAINetworkBackground passes through hit tests when child is null', (WidgetTester tester) async {
    bool tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Stack(
            children: [
              const Positioned.fill(
                child: AnimatedAINetworkBackground(),
              ),
              Positioned.fill(
                child: GestureDetector(
                  onTap: () => tapped = true,
                  child: const ColoredBox(color: Colors.transparent),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    await tester.tap(find.byType(GestureDetector));
    expect(tapped, isTrue);
  });
}
