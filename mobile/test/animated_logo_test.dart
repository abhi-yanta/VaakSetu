import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vaaksetu_mobile/ui/core/animated_logo.dart';

void main() {
  testWidgets('AnimatedLogo renders in startup pulse mode', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AnimatedLogo(size: 100, isLoading: false),
        ),
      ),
    );

    expect(find.byType(AnimatedLogo), findsOneWidget);
  });

  testWidgets('AnimatedLogo renders in loading scanner mode', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AnimatedLogo(size: 80, isLoading: true),
        ),
      ),
    );

    expect(find.byType(AnimatedLogo), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
